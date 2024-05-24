extends Node

@export var _retry_scenes: LoadSceneArray
@export var _title_scene: LoadSceneArray

var _change_started := true

func init_game_ui():
	UserSettings.set_and_save_last_scene(UserSettings.SceneType.GAME)
	_change_started = false

func _on_retry():
	if _change_started:
		return
	_change_started = true

	UserSettings.delete_destroyed_characters()
	SceneChanger.cover_and_change_scene(SceneChanger.get_current_cover_instance(), 0.5, Color.BLACK, _retry_scenes)

func _on_to_title():
	if _change_started:
		return
	_change_started = true

	SceneChanger.cover_and_change_scene(SceneChanger.get_current_cover_instance(), 1, Color.BLACK, _title_scene)
