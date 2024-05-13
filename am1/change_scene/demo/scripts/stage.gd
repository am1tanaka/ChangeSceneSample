extends Node

## デモ用ステージスクリプト

func _ready() -> void:
	SceneChanger.all_scenes_loaded.connect(_init_stage)
	

func _init_stage() -> void:
	SceneChanger.uncover(0.5)
	SceneChanger.uncovered.connect(_start_game)

func _start_game() -> void:
	get_node("/root/GameUi").init_game_ui()
	SceneChanger.uncovered.disconnect(_start_game)

