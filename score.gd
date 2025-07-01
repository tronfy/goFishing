extends PanelContainer

@onready var ScoreBar = get_parent().get_node("ScoreBar")

var target

func _on_score_changed(score: int, catch_score: int) -> void:
	target = remap(score, 0, catch_score, 0, 1)
	ScoreBar.scale = Vector2(target, 1)
