extends Node

## デモ用ステージスクリプト

func _ready() -> void:
	SceneChanger.all_scenes_loaded.connect(_start_stage)

func _start_stage() -> void:
	SceneChanger.uncover(0.5)
