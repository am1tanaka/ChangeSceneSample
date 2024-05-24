class_name Title
extends Node

const COVER_FADE := preload("res://am1/change_scene/scenes/cover_fade.tscn")

@export var _game_scenes: LoadSceneArray

static var _cover_fade: ScreenCoverBase
var _game_started := false

func _ready() -> void:
	$Button.disabled = true
	SceneChanger.all_scenes_loaded.connect(_init_title)

	if _cover_fade == null:
		_cover_fade = COVER_FADE.instantiate()

func _init_title() -> void:
	SceneChanger.uncover(0.5)
	SceneChanger.uncovered.connect(_start_title)

## タイトルの操作開始
func _start_title() -> void:
	UserSettings.delete_destroyed_characters()
	UserSettings.set_and_save_last_scene(UserSettings.SceneType.TITLE)
	SceneChanger.uncovered.disconnect(_start_title)
	$Button.disabled = false

func _on_game_start() -> void:
	if _game_started:
		return
	
	_game_started = true
	$Button.disabled = true
	SceneChanger.cover_and_change_scene(_cover_fade, 0.5, Color.WHITE, _game_scenes)
