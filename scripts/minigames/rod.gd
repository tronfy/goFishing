extends Sprite2D

@onready var Bob = get_parent().get_node("Bob")


var initial_position;
var max_offset = Vector2(20, 20)
var cur_offset = Vector2(0, 0)

var increment
var fastNoiseLite: FastNoiseLite;

var bob_pos;

func _ready() -> void:
	fastNoiseLite = FastNoiseLite.new()
	_mode_idle()
	initial_position = position


func _process(_delta: float) -> void:
	cur_offset += increment * fastNoiseLite.get_noise_1d(Time.get_ticks_msec())
	cur_offset = cur_offset.clamp(-max_offset, max_offset)
	position = initial_position + cur_offset
	
	bob_pos = to_local(Bob.position + Vector2(-10, -40))
	queue_redraw()
	

func _mode_reel(_score: int, _catch_score: int) -> void:
	increment = Vector2(6, 12)
	fastNoiseLite.frequency = 0.003

func _mode_idle() -> void:
	cur_offset = Vector2.ZERO
	increment = Vector2(4, 8)
	fastNoiseLite.frequency = 0.0003


func _draw():
	var off = Vector2(0.5,0.5)
	var points: PackedVector2Array = [bob_pos, off, -off]
	var color: PackedColorArray = [Color("a7acba")]
	draw_polygon(points, color)
