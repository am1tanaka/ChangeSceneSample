class_name ScreenCoverBase
extends Node

## 画面を覆う処理のベースクラス。
## cover(秒数, 色)でカバー開始。
## uncover(秒数)でカバー解除の開始。

## 画面を隠す処理が完了したら、発行するシグナル。
signal covered

## 画面の覆いを外し終えたら、発行するシグナル
signal uncovered

## デフォルトのカバーの色
const DEFAULT_COVER_COLOR := Color.WHITE

const ANIM_COVERING := "covering"
const ANIM_COVERED := "covered"
const ANIM_UNCOVERING := "uncovering"
const ANIM_UNCOVERED := "uncovered"

## 指定の秒数で、カバーを開始する。引数を省略したり、0にすると、瞬時に隠し終える。
func cover(_sec: float = 0.0, _color: Color = DEFAULT_COVER_COLOR) -> void:
	pass

## 指定の秒数で、カバーを解除する。引数を省略したり、0にすると、瞬時に表示。
func uncover(_sec: float = 0.0) ->void:
	pass

## カバーが完了したら、アニメから呼ぶ	
func _covered() -> void:
	covered.emit()

## カバーを解除したら、アニメから呼ぶ
func _uncovered() -> void:
	uncovered.emit()
