extends Label

@onready var sensors = get_parent().get_parent().get_node("Sensors")

var esquerda = false

signal tilt_success
signal tilt_fail

func _process(_delta):
	if not visible:
		pass
		
	var gravity = sensors.grav
	if esquerda:
		if gravity.x < -4:
			tilt_success.emit()
		elif gravity.x > 3:
			tilt_fail.emit()
	else:
		if gravity.x > 4:
			tilt_success.emit()
		elif gravity.x < -3:
			tilt_fail.emit()
		
