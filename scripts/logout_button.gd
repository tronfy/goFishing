extends Button

func _on_pressed() -> void:
	var config = ConfigFile.new()
	var status = config.load("user://auth.cfg")
	if status != OK: return
	
	config.erase_section("player")
	config.save("user://auth.cfg")
	
	get_tree().change_scene_to_file("res://scenes/login.tscn")
