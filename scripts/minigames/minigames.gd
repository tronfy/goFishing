extends Node2D

# afetado pelo tamanho do peixe
var start_score = 2
var catch_score = 5 

var peixe
var tamanho

signal score_changed
signal bob_reset
signal bob_hook_update

@onready var TiltGame = $Control/Tilt
@onready var TapGame = $Control/Tap
@onready var SpinGame = $Spin
@onready var TimerBar = $Control/TimerBar
@onready var CatchLabel = $Control/Catch
@onready var FleeLabel = $Control/Flee

@onready var ItemTimer = get_node("/root/Global/ItemTimer")

var userID

var games = [
	{
		"name": "tap",
		"timeout": 2.0,
		"start": Callable(self, "show_tap"),
		"chance": 1,
	},
	{
		"name": "tilt",
		"timeout": 2.0,
		"start": Callable(self, "show_tilt"),
		"chance": 0,
	},
	{
		"name": "spin",
		"timeout": 4.0,
		"start": Callable(self, "show_spin"),
		"chance": 0,
	},
]

var score;

func show_tap():
	var screen_size = get_viewport_rect().size
	var x = randi_range(0, screen_size.x - TapGame.size.x)
	var y = randi_range(0 + 100, screen_size.y - TapGame.size.y - 100)
	TapGame.position = Vector2(x, y)
	TapGame.visible = true

func _on_tap_success() -> void:
	success()

func show_tilt():
	var esquerda = randi_range(0, 1) == 0
	if esquerda: TiltGame.text = "inclinar para a ESQUERDA"
	else: TiltGame.text = "inclinar para a DIREITA"
	TiltGame.esquerda = esquerda
	TiltGame.visible = true

func _on_tilt_success() -> void:
	if TiltGame.visible == false: return
	success()

func _on_tilt_fail() -> void:
	if TiltGame.visible == false: return
	fail()


func show_spin():
	SpinGame.visible = true
	SpinGame.completion = 0
	SpinGame.rotation = 0

func _on_spin_success() -> void:
	success()


func success():
	cleanup_after_minigame()
	score += 1
	score_changed.emit(score, catch_score)
	print("Sucesso, score = ", score)
	
	if score >= catch_score:
		CatchLabel.text = "Você pescou:\n" + peixe.nome + " de " + str(tamanho) + "m!\n"
		if not peixe.capturado: CatchLabel.text += "Nova espécie descoberta!"
		elif peixe.tamanho != null and tamanho > peixe.tamanho: CatchLabel.text += "Novo recorde!"
		CatchLabel.visible = true
		
		# sortear item
		var c = randf_range(0, 1)
		print(c, " ", Global.item_chance)
		if c < Global.item_chance:
			var i = randi_range(3, 6)
			print("ganhou item: ", str(i))
			$Control/CatchItem.visible = true
		
			var body = {
				"userID": userID,
				"itemID": i,
				"quantidade": 1
			}
			var json = JSON.stringify(body)
			
			var headers = ["Content-Type: application/json"]
			var url = Constants.API_URL + "/item/adicionarIteminventario"
			
			$HTTPItemPostRequest.request(url, headers, HTTPClient.METHOD_POST, json)

		
		var body = {
			"userID": userID,
			"peixeID": peixe.id,
			"tamanho": tamanho
		}
		var json = JSON.stringify(body)
		
		var headers = ["Content-Type: application/json"]
		var url = Constants.API_URL + "/peixe/pegouPeixe"
		
		$HTTPPostRequest.request(url, headers, HTTPClient.METHOD_POST, json)
		setup_waiting_for_fish()
	else:
		bob_hook_update.emit(score, catch_score)
		$TimerCooldown.start()

func fail():
	cleanup_after_minigame()
	score -= 1
	score_changed.emit(score, catch_score)
	print("Falha, score = ", score)
	
	if score <= 0:
		FleeLabel.visible = true
		setup_waiting_for_fish()
	else:
		bob_hook_update.emit(score, catch_score)
		$TimerCooldown.start()

func _on_minigame_timeout() -> void:
	fail()

func _on_cooldown_timeout() -> void:
	$Control/BackButton.visible = false
	# var next = randi_range(0, games.size() - 1)
	var total = 0
	for game in games:
		total += game["chance"]

	var random_value = randi_range(0, total - 1)
	var cumulative_chance = 0
	var game = null
	for g in games:
		cumulative_chance += g["chance"]
		if random_value < cumulative_chance:
			game = g
			break

	Input.vibrate_handheld(100)
	$TimerMinigame.start(game["timeout"] * Global.minigame_timeout_scale)
	TimerBar.visible = true
	game["start"].call()

func _on_hook_timeout() -> void:
	var url = Constants.API_URL + "/peixe/peixedex/" + str(userID)
	$HTTPRequest.request(url)

func _on_request_completed(result, response_code, headers, body):
	var peixes = JSON.parse_string(body.get_string_from_utf8())
	
	peixe = peixes[randi_range(0, len(peixes)-1)]  # sortear uma especie
	tamanho = randf_range(peixe.tamanhoMaximo * Global.fish_boost, peixe.tamanhoMaximo)  # sortear tamanho
	tamanho = snapped(tamanho, 0.01)
	
	# definir catch_score a partir do tamanho
	catch_score = round(remap(tamanho, peixe.tamanhoMinimo, peixe.tamanhoMaximo, 4, 8))
	print("sorteou: ", peixe.nome, "(", str(tamanho), "m), dificuldade=", catch_score + Global.minigame_add)
	
	$Control/StarsLabel.text = Global.get_stars_string(tamanho, peixe.tamanhoMaximo)
	
	start_fishing()

func start_fishing():
	score = start_score
	score_changed.emit(score, catch_score)
	cleanup_after_minigame()
	$Control/Score.visible = true
	$Control/ScoreBar.visible = true
	$Control/StarsLabel.visible = true
	Input.vibrate_handheld(300)
	bob_hook_update.emit(score, catch_score)
	$TimerCooldown.start(2)

func cleanup_after_minigame():
	$TimerMinigame.stop()
	bob_reset.emit()
	
	SpinGame.visible = false
	TapGame.visible = false
	TiltGame.visible = false
	
	CatchLabel.visible = false
	FleeLabel.visible = false
	TimerBar.visible = false
	$Control/CatchItem.visible = false

func setup_waiting_for_fish():
	score = start_score
	$Control/Score.visible = false
	$Control/ScoreBar.visible = false
	$Control/StarsLabel.visible = false
	$TimerFish.start(Global.fish_wait_time)
	bob_reset.emit()

func _ready():
	cleanup_after_minigame()
	$Control/Score.visible = false
	$Control/ScoreBar.visible = false
	
	var config = ConfigFile.new()
	var status = config.load("user://auth.cfg")
	if status != OK: return
	userID = config.get_value("player", "userID")

func _process(delta):
	if ItemTimer.time_left > 0:
		$Control/ItemLabel.text = Global.itemNome + " (" + str(int(ItemTimer.time_left)) + "s)"
	else:
		$Control/ItemLabel.text = ""
	

func _notification(what: int):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_http_post_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	$Control/BackButton.visible = true
