extends Node

@onready var _animation_player := $AnimationPlayer as AnimationPlayer

func _ready():
	_animation_player.play("show", -1, 3)

## スプラッシュ画面の表示が完了したらアニメーションから呼ばれる。
func _on_showed():
	# 設定を読み込む
	print("設定を読み込む")
	
	# 次のシーンを起動へ
	print("設定に従って、次のシーンを起動する")
	
	pass

