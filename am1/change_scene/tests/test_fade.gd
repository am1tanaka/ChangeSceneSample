extends GutTest

const FADE_PACK = preload("res://am1/change_scene/scenes/cover_fade.tscn")

var _immediate_covered := false
var _immediate_uncovered := false

func test_fade_anim():
	var fade = FADE_PACK.instantiate() as GeneralScreenCover
	get_tree().root.add_child(fade)
	
	await wait_frames(1)
	fade.cover(0.5, Color.WHITE)

	# フェードが始まっている
	await wait_seconds(0.25)
	var color_rect = fade.get_node("ColorRect") as ColorRect
	assert_gt(color_rect.color.a, 0.0, "フェード開始")
	assert_eq(color_rect.modulate, Color.WHITE, "カバーの色設定")
	
	# 完了待ち
	await fade.covered
	assert_eq(color_rect.color.a, 1.0, "フェード完了")
	
	# カバーを外す
	fade.uncover(0.5)
	await wait_seconds(0.25)
	
	# 解除が始まっている
	assert_lt(color_rect.color.a, 1.0, "解除開始")
	await fade.uncovered

	# 解除完了
	assert_eq(color_rect.color.a, 0.0, "解除完了")
	
	fade.queue_free()
	await wait_frames(2)

func test_fade_immediate():
	var fade = FADE_PACK.instantiate() as GeneralScreenCover
	get_tree().root.add_child(fade)
	await wait_frames(1)

	# 即時画面が隠れる
	fade.covered.connect(_on_immediate_covered)
	fade.uncovered.connect(_on_immediate_uncovered)
	fade.cover(0, Color.RED)
	await wait_frames(1)

	assert_true(_immediate_covered, "即時、カバー")
	var color_rect = fade.get_node("ColorRect") as ColorRect
	assert_eq(color_rect.modulate, Color.RED, "カバーの色が赤")
	
	# カバーを外す
	fade.uncover()
	await wait_frames(1)

	# 解除完了
	assert_true(_immediate_uncovered, "即時、カバー解除")

	fade.queue_free()
	await wait_frames(2)

func _on_immediate_covered():
	_immediate_covered = true

func _on_immediate_uncovered():
	_immediate_uncovered = true
