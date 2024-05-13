extends GutTest

## シーン切り替えテスト

const TITLE_SCENE := preload("res://am1/change_scene/demo/scenes/title.tscn")

@onready var _title

var _all_scenes_loaded_count := 0
var _all_scenes_unloaded_count := 0

func before_each():
	_title = TITLE_SCENE.instantiate()
	get_tree().root.add_child(_title)
	SceneChanger.append_ignore_scene_name("GutRunner")

func after_each():
	if _title != null:
		_title.free()
	_title = null

func test_fundamental() -> void:

	SceneChanger.all_scenes_loaded.connect(_all_scenes_loaded)
	SceneChanger.all_scenes_unloaded.connect(_all_scenes_loaded)
	var title = _title as Title
	title._on_game_start()

	# ゲーム開始のシーンの読み込み完了待ち
	await wait_for_signal(SceneChanger.all_scenes_loaded, 2)
	assert_signal_emitted(SceneChanger, "all_scenes_loaded", "シーン読み込み完了シグナル")
	assert_eq(_all_scenes_loaded_count, 1, "ゲームシーンの読み込み完了")
	
	# ゲームの起動を確認
	await SceneChanger.uncovered

	# いくつか、消す
	var clickable = get_node("/root/Stage/Clickable")
	clickable.queue_free()
	
	clickable = get_node("/root/Stage/Clickable3")
	clickable.queue_free()

	clickable = get_node("/root/Stage/Clickable5")
	clickable.queue_free()

	clickable = get_node("/root/Stage/Clickable7")
	clickable.queue_free()
	await wait_seconds(0.5)

	assert_eq(get_node("/root/Stage").get_child_count(), 4, "4つ消した")
	
	# リトライ
	var game_ui = get_node("/root/GameUi")
	assert_not_null(game_ui, "GameUi")
	game_ui._on_retry()
	
	# カバー解除待ち
	await SceneChanger.uncovered
	var stage = get_node("/root/Stage")
	assert_not_null(stage, "Stageシーン")
	assert_eq(stage.get_child_count(), 8, "8つに復活")
	
	# タイトルヘ
	game_ui = get_node("/root/GameUi")
	assert_not_null(game_ui, "GameUi")
	game_ui._on_to_title()

	# カバー解除待ち
	await SceneChanger.uncovered

	# タイトル
	title = get_node("/root/Title")
	assert_null(get_node("root/GameUi"))
	assert_not_null(title, "タイトル読み込み")
	title._on_game_start()
		
	# カバー解除待ち
	await SceneChanger.uncovered

	# ゲームシーン
	assert_not_null(get_node("/root/GameUi"))
	stage = get_node("/root/Stage")
	assert_not_null(stage)
	assert_eq(stage.get_child_count(), 8, "子供が8つ")


func _all_scenes_loaded() ->void :
	_all_scenes_loaded_count += 1
	
func _all_scenes_unloaded() ->void :
	_all_scenes_unloaded_count += 1
