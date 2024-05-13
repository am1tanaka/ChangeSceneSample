class_name Title
extends Node

const COVER_FADE := preload("res://am1/change_scene/scenes/cover_fade.tscn")

@export var _game_scenes: LoadSceneArray

static var _cover_fade: ScreenCoverBase

func _ready() -> void:
	if _cover_fade == null:
		_cover_fade = COVER_FADE.instantiate()
		get_tree().root.add_child(_cover_fade)

func _on_game_start() -> void:
	SceneChanger.cover_and_change_scene(_cover_fade, 0.5, Color.WHITE, _game_scenes)
