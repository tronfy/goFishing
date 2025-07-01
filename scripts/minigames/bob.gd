extends AnimatedSprite2D

var target_position_y = 1000;

func _on_hook_update(score: int, catch_score: int) -> void:
	play("hook")
	var w = float(score) / float(catch_score - 1)
	var s = lerp(4, 20, w)
	scale = Vector2(s, s)
	target_position_y = lerp(600, 1500, w)

func _on_bob_reset() -> void:
	play("bob")
	scale = Vector2(8, 8)
	target_position_y = 1000

func _process(_delta: float) -> void:
	var d = target_position_y - position.y
	position.y += d/3
