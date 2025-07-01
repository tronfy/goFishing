extends Node2D

signal spin_success


var completion = 0
var last_angle = null

func _input(event):
	if not visible:
		return

	if event is InputEventScreenTouch:
		if not event.pressed:
			completion = 0
	elif event is InputEventScreenDrag:
		handle_input(event.position)
	elif event is InputEventMouseMotion:
		if Input.is_action_just_released("left_click"):
			completion = 0
		elif Input.is_action_pressed("left_click"):
			handle_input(event.position)

func handle_input(pos: Vector2):
	var relative = pos - position
	var angle = relative.angle()
	if last_angle != null:
		var delta = angle - last_angle
		if delta > 0:
			completion += delta * 0.05
			if completion >= 1:
				spin_success.emit()
	last_angle = angle
	rotation = angle
