extends Button


func _on_pressed() -> void:
	get_parent().get_parent().queue_free()
