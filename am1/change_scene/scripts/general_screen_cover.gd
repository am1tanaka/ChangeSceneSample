class_name GeneralScreenCover
extends Node

## 基本的なカバー用スクリプト。
## start_cover(秒数)でカバー開始。
## start_uncover(秒数)でカバー解除の開始。

## 画面を隠す処理が完了したら、発行するシグナル。
signal covered

## 画面の覆いを外し終えたら、発行するシグナル
signal uncovered

const ANIM_COVERING := "covering"
const ANIM_COVERED := "covered"
const ANIM_UNCOVERING := "uncovering"
const ANIM_UNCOVERED := "uncovered"

## デフォルトのカバーの色
const DEFAULT_COVER_COLOR := Color.BLACK

@onready var _animation_player := $AnimationPlayer
@onready var _color_rect := $ColorRect

## 指定の秒数で、カバーを開始する。引数を省略したり、0にすると、瞬時に隠し終える。
func cover(sec: float = 0.0, color: Color = DEFAULT_COVER_COLOR) -> void:
	# 色設定
	_color_rect.modulate = color
	
	# 0なら即時
	if is_zero_approx(sec):
		_animation_player.play(ANIM_COVERED)
		covered.emit()
		return
	
	# 再生速度設定
	_animation_player.speed_scale = 1.0 / sec
	_animation_player.play(ANIM_COVERING)
	
## 指定の秒数で、カバーを解除する。引数を省略したり、0にすると、瞬時に表示。
func uncover(sec: float = 0.0) ->void:
	# 0なら即時
	if is_zero_approx(sec):
		_animation_player.play(ANIM_UNCOVERED)
		uncovered.emit()
		return
	
	# 再生速度設定
	_animation_player.speed_scale = 1.0 / sec
	_animation_player.play(ANIM_UNCOVERING)

## カバーが完了したら、アニメから呼ぶ	
func _covered():
	covered.emit()

## カバーを解除したら、アニメから呼ぶ
func _uncovered():
	uncovered.emit()
