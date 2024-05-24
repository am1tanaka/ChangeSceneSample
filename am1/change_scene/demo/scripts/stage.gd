extends Node

## デモ用ステージスクリプト

func _ready() -> void:
	SceneChanger.all_scenes_loaded.connect(_init_stage)

func _init_stage() -> void:
	_apply_destroyed()
	
	SceneChanger.uncover(0.5)
	SceneChanger.uncovered.connect(_start_game)

func _start_game() -> void:
	get_node("/root/GameUi").init_game_ui()
	SceneChanger.uncovered.disconnect(_start_game)

## 敵の撃破データがあれば、反映させる
func _apply_destroyed() -> void:
	for destroyed_index in UserSettings.get_destroyed_characters():
		if destroyed_index == 0:
			get_node("/root/Stage/Clickable").queue_free()
		else:
			get_node("/root/Stage/Clickable%d" % (destroyed_index + 1)).queue_free()
