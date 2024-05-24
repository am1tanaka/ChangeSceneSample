extends Area2D


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			free_me()

## 解放する。
func free_me() -> void:
	UserSettings.set_destroy_character(_get_index())
	queue_free()

## オブジェクト名から、インデックスを返す。
func _get_index() -> int:
	var r = name.right(1)
	if r.is_valid_int():
		return r.to_int()-1
	
	return 0
