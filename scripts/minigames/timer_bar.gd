extends ColorRect

@onready var timer = get_parent().get_parent().get_node("TimerMinigame")

func _process(_delta):
	if timer.is_stopped():
		return
	
	var s = remap(timer.time_left, 0, timer.wait_time, 0, 1)
	var c = Color.from_rgba8(0, 243, 80).lerp(Color.from_rgba8(240, 176, 0), clampf(remap(s, 0.7, 0.4, 0, 1), 0, 1))
	
	scale.x = s
	color = c
