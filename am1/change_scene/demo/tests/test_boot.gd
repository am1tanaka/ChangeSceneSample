extends GutTest

## 起動動作のテスト

const BOOT_SCENE := preload("res://am1/change_scene/demo/scenes/boot.tscn")

func before_all():
	UserSettings.debug_set_postfix("_test")
	SceneChanger.append_ignore_scene_name("GutRunner")

func after_all():
	UserSettings.delete_save_data()
	SceneChanger.remove_ignore_scene_name("GutRunner")

func before_each():
	UserSettings.delete_save_data()
	UserSettings.load_settings()

## 保存データに応じて、起動するシーンが切り替わることを確認
func test_boot_scene():
	# まずはタイトルシーンへ
	var boot := BOOT_SCENE.instantiate()
	get_tree().root.add_child(boot)
	await wait_for_signal(SceneChanger.uncovered, 5, "タイトル起動")
	assert_true(_assert_scene("Title"), "タイトル起動")

	# ゲームを保存
	UserSettings.set_and_save_last_scene(UserSettings.SceneType.GAME)
	get_node("/root/Title").queue_free()
	await wait_frames(2)
	UserSettings.load_settings()
	boot = BOOT_SCENE.instantiate()
	get_tree().root.add_child(boot)
	await SceneChanger.uncovered
	assert_true(_assert_scene("GameUi"), "ゲーム起動")
	assert_true(_assert_scene("Stage"), "ステージ起動")
	
	# タイトルへ戻す
	get_node("/root/GameUi").queue_free()
	get_node("/root/Stage").queue_free()
	await wait_frames(2)
	UserSettings.set_and_save_last_scene(UserSettings.SceneType.TITLE)
	UserSettings.load_settings()
	boot = BOOT_SCENE.instantiate()
	get_tree().root.add_child(boot)
	await SceneChanger.uncovered
	assert_true(_assert_scene("Title"), "タイトル起動")
	
	# タイトル解放
	get_node("/root/Title").queue_free()
	await wait_frames(2)
	

## シーンが切り替わった時の設定の保存を確認
func test_title_boot():
	# タイトルシーンへ
	var boot := BOOT_SCENE.instantiate()
	get_tree().root.add_child(boot)
	await SceneChanger.uncovered
	assert_true(_assert_scene("Title"), "タイトル起動")
	
	# ゲーム開始
	await wait_frames(5)
	get_node("/root/Title")._on_game_start()
	await wait_frames(2)
	await SceneChanger.uncovered
	await wait_frames(2)
	
	# キャラを消す
	_click(get_node("/root/Stage/Clickable2"))
	await wait_frames(1)
	_click(get_node("/root/Stage/Clickable4"))
	await wait_frames(1)
	_click(get_node("/root/Stage/Clickable6"))
	await wait_seconds(2)
	
	# 再起動
	get_node("/root/GameUi").queue_free()
	get_node("/root/Stage").queue_free()
	await _boot()

	assert_true(_assert_scene("GameUi"), "ゲーム起動")	
	assert_true(_assert_scene("Stage"), "ステージ起動")
	assert_not_null(get_node("/root/Stage/Clickable"), "Clickableあり")
	assert_not_null(get_node("/root/Stage/Clickable3"), "Clickable3あり")
	assert_not_null(get_node("/root/Stage/Clickable5"), "Clickable5あり")
	assert_not_null(get_node("/root/Stage/Clickable7"), "Clickable7あり")
	assert_not_null(get_node("/root/Stage/Clickable8"), "Clickable8あり")

	assert_not_null(get_node("/root/Stage/Clickable2"), "Clickable2なし")
	assert_not_null(get_node("/root/Stage/Clickable4"), "Clickable4なし")
	assert_not_null(get_node("/root/Stage/Clickable6"), "Clickable6なし")

	# リトライ
	get_node("/root/GameUi")._on_retry()
	await wait_frames(2)
	await SceneChanger.uncovered
	
	# 再起動
	get_node("/root/GameUi").queue_free()
	get_node("/root/Stage").queue_free()
	await _boot()
	
	# ゲームがまっさらな状態で開始
	assert_true(_assert_scene("GameUi"), "ゲーム起動")	
	assert_true(_assert_scene("Stage"), "ステージ起動")
	assert_not_null(get_node("/root/Stage/Clickable"), "Clickableあり")
	assert_not_null(get_node("/root/Stage/Clickable2"), "Clickable2あり")
	assert_not_null(get_node("/root/Stage/Clickable3"), "Clickable3あり")
	assert_not_null(get_node("/root/Stage/Clickable4"), "Clickable4あり")
	assert_not_null(get_node("/root/Stage/Clickable5"), "Clickable5あり")
	assert_not_null(get_node("/root/Stage/Clickable6"), "Clickable6あり")
	assert_not_null(get_node("/root/Stage/Clickable7"), "Clickable7あり")
	assert_not_null(get_node("/root/Stage/Clickable8"), "Clickable8あり")
	
	# タイトルへ
	await wait_frames(2)
	get_node("/root/GameUi")._on_to_title()
	await wait_frames(2)
	await SceneChanger.uncovered
	assert_true(_assert_scene("Title"), "タイトル起動")
	
	# 再起動
	get_node("/root/Title").queue_free()
	await _boot()

	# タイトルチェック
	assert_true(_assert_scene("Title"), "タイトル起動")	


func _boot() -> void:
	await wait_frames(2)
	UserSettings.load_settings()

	var boot = BOOT_SCENE.instantiate()
	get_tree().root.add_child(boot)
	await SceneChanger.uncovered


## 指定のオブジェクトをクリックする。
func _click(target: Area2D) -> void:
	var sender = InputSender.new(target)
	sender.mouse_left_button_down(target.position)
	sender.mouse_left_button_up(target.position)


## 指定のシーンがあるなら、trueを返す。
func _assert_scene(check_name: String) -> bool:
	return get_tree().root.get_children().any(func(value): return value.name == check_name)

