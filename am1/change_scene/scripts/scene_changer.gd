extends Node

## シーン切り替えを実行するクラス。
## 自動読み込みに設定して利用する。
## 画面を隠す演出とシーンを切り替えたいとき、cover_and_change_scene関数。
## シーンの切り替えだけ必要なら、change_scene関数。
## 初期化が必要なシーンは、_ready内で、SceneChanger.all_scenes_loadedシグナルに処理を登録する。
## シーンリストにない、自動読み込みではないシーンは、画面を隠したあとに自動的に解放する。
## 読み込み終えたら、all_scenes_loadedシグナルを発行する。
## すべてのシーンが解放されたら、all_scenes_unloadedシグナルを発行する。
## 画面をカバーしたら、coveredシグナルを発行。
## 画面のカバーが解除したら、uncoveredシグナルを発行。これでゲームを開始。
## Gutなどの、児童読み込み以外で、解放してはいけないシーンは、名前をappend_ignore_scene_name関数で登録。
## 解放を禁じるシーン名は、remove_ignore_scene_name関数で削除できる。
## (保留)load_scenes_async関数で、配列で渡したシーンを読み込む。すでに読み込み済みのシーンは何もしない。
## (保留)unload_scene関数で、指定のシーンを解放する。シーンがないときは何もしない。

## すべてのシーンの読み込みが完了したら発行するシグナル。
signal all_scenes_loaded

## すべてのシーンをシーンツリーから解除したら実行するシグナル。
signal all_scenes_unloaded

## カバーが完了したときのシグナル。カバーがないときは、読み込み終わったときに発生。
signal covered

## カバーを解除したときのシグナル。カバーがないときは、uncoverした瞬間に発行。
signal uncovered

## シーンの解放が完了したシグナル
signal all_scenes_freed

## 画面を隠す処理のインスタンス
var _cover: ScreenCoverBase
## 設定されているカバーのインスタンスを返す。
func get_current_cover_instance():
	return _cover

var _async_loading_scenes: Array[LoadSceneData]

## 再読み込み候補のシーン
var _reload_scenes: Array[LoadSceneData]

## 解放中のノードリスト
var _free_scenes_count :int = 0

## 非同期読み込み中のシーンの数。readyが送られてきたら、減らす
var _async_load_count : int = 0

## 解放しないシーンの名前。
var _ignore_scene_names: Dictionary = {}

## 指定秒数でシーンをカバーして、指定のシーンを読み込む。
func cover_and_change_scene(cover: ScreenCoverBase, cover_seconds: float, cover_color: Color, load_scenes: LoadSceneArray):

	# 画面を覆う処理の開始
	_cover = cover
	if _cover.get_parent() == null:
		add_child(_cover)
		await get_tree().process_frame
	elif _cover.get_parent() != self:
		_cover.reparent(self)
	_cover.cover(cover_seconds, cover_color)
	
	# 非同期読み込み開始
	_async_loading_scenes.clear()
	_reload_scenes.clear()
	if load_scenes == null:
		push_error("シーンが未設定です。")
		return
	for scene in load_scenes.load_scene_array:
		_start_async_load_scene(scene)

	#　カバーの完了を待つ
	await _cover.covered
	covered.emit()
	
	# 不要なシーンを解放
	_unload_unnecessary_scenes(load_scenes)
	if _free_scenes_count > 0:
		await all_scenes_freed

	# シーンのリロード
	for scene in _reload_scenes:
		_async_loading_scenes.append(scene)
		ResourceLoader.load_threaded_request(scene.scene_path)

	# シーンの読み込みとシーン追加の完了待ち
	await _wait_async_loaded_and_ready()
	
	# 読み込み完了
	all_scenes_loaded.emit()

## 非同期読み込みのシーンの読み込み開始。
func _wait_async_loaded_and_ready():
	var loaded_scenes : Array[LoadSceneData] = []
	var root := get_tree().root
	var added_scenes : Array[Node] = []
	
	# 読み込みが完了したシーンを、ルートに組み込む
	while (_async_loading_scenes.size() > 0) || (_async_load_count > 0):
		loaded_scenes.clear()

		# 読み込み完了を確認
		for scene in _async_loading_scenes:
			var status = ResourceLoader.load_threaded_get_status(scene.scene_path) as ResourceLoader.ThreadLoadStatus
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				# 読み込み完了
				loaded_scenes.append(scene)
			elif status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				push_error("シーンの読み込みエラー %s" % scene.scene_path)
				return
		
		# 読み込みが完了していたシーンをルートへ追加する
		for scene in loaded_scenes:
			_async_loading_scenes.erase(scene)
			var scene_node := ResourceLoader.load_threaded_get(scene.scene_path).instantiate() as Node
			added_scenes.append(scene_node)
			_async_load_count += 1
			scene_node.ready.connect(_on_scene_ready)
			root.add_child(scene_node)

	# readyの接続を解除
	for added_scene in added_scenes:
		added_scene.ready.disconnect(_on_scene_ready)
	
## シーンのreadyが完了したときに実行して、カウンターを減らす。
func _on_scene_ready():
	_async_load_count -= 1


## ルートにあるシーンのうち、自動読み込みのものか、読み込み候補のうちのリロードではないもの以外を解放する。
func _unload_unnecessary_scenes(load_scenes: LoadSceneArray) -> void:
	_free_scenes_count = 0
	
	var root_scenes = get_tree().root.get_children()
	for root_scene in root_scenes:
		if !_is_necessary_scene(root_scene, load_scenes):
			_free_scenes_count += 1
			root_scene.tree_exited.connect(_on_free_tree_exited)	
			root_scene.queue_free()

## シーンが解放されたときに呼び出して、解放数を減らす
func _on_free_tree_exited() -> void:
	_free_scenes_count -= 1
	if _free_scenes_count == 0:
		all_scenes_freed.emit()

## 指定のルートのシーンが必要ならtrueを返す。
func _is_necessary_scene(root_scene: Node, load_scenes: LoadSceneArray) -> bool:
	# 自動読み込みなら必要
	if SceneChanger.is_autoload_scene(root_scene.name):
		return true
	
	# 無効なシーン名なら必要
	if _ignore_scene_names.has(root_scene.name):
		return true

	# 読み込みリストにある場合、is_reloadがfalseなら必要
	for scene in load_scenes.load_scene_array:
		if root_scene.scene_file_path == scene.scene_path:
			return !scene.is_reload

	# 該当しなければ不要
	return false

## 指定のシーン名が、自動読み込みのとき、trueを返す。
func is_autoload_scene(scene_name: String) -> bool:
	return ProjectSettings.has_setting("autoload/%s" % scene_name)

## 指定の読み込むシーンデータの読み込み開始の確認と開始。
## 読み込まれていなければ、非同期読み込みを開始して、読み込み中配列に記録。
## 読み込まれていて、リロードのものは、リロード配列に追加。
## 読み込まれていて、リロードしないものは処理なし。
func _start_async_load_scene(scene: LoadSceneData) -> void:
	# 読み込み済みかを確認
	var node_instance := get_root_scene_with_file_path(scene.scene_path)
	
	# なければ、非同期読み込み開始
	if node_instance == null:
		_async_loading_scenes.append(scene)
		ResourceLoader.load_threaded_request(scene.scene_path)
	elif scene.is_reload:
		# あれば、リロードならリロード候補へ追加
		_reload_scenes.append(scene)

## 指定のシーンパスから生成したシーンがルートから検索して、見つけたらノードのインスタンスを返す。
func get_root_scene_with_file_path(path: String) -> Node:
	var root_scenes = get_tree().root.get_children()
	
	for root_scene in root_scenes:
		if root_scene.scene_file_path == path:
			return root_scene
	
	return null

## 画面を隠していたら、指定の秒数で解除する。
func uncover(uncover_seconds: float):
	if _cover == null:
		uncovered.emit()
		return

	if !_cover.uncovered.is_connected(_on_uncovered):
		_cover.uncovered.connect(_on_uncovered)
	_cover.uncover(uncover_seconds)

## カバーが解除されたときの処理
func _on_uncovered():
	_cover.uncovered.disconnect(_on_uncovered)
	uncovered.emit()

## 自動解放しないシーンを名前で設定。
func append_ignore_scene_name(scene_name: String):
	if !_ignore_scene_names.has(scene_name):
		_ignore_scene_names[scene_name] = true

## 自動解放しないシーン名を解除。
func remove_ignore_scene_name(scene_name: String)->void:
	_ignore_scene_names.erase(scene_name)

