class_name TelaItem
extends Node2D

@onready var icones = {
	3: preload("res://sprites/fishing_game_assets/4 Icons/Icons_20.png"),
	4: preload("res://sprites/fishing_game_assets/4 Icons/Icons_11.png"),
	5: preload("res://sprites/fishing_game_assets/4 Icons/Icons_12.png"),
	6: preload("res://sprites/fishing_game_assets/4 Icons/Icons_14.png")
}

@onready var timer = get_node("/root/Global/ItemTimer")




var id: int
var nome: String
var descricao: String
var qtd: int

func with_data(
	_id: int,
	_nome: String,
	_descricao: String,
	_qtd: int,
) -> TelaItem:
	id = _id
	nome = _nome
	descricao = _descricao
	qtd = _qtd
	return self

func _ready() -> void:
	$Control/LabelItem.text = nome
	$Control/LabelDescricao.text = descricao.replace('\n', '\n\n')
	
	$Control/LabelDuracao.text = "2min"
	$Control/LabelQtd.text = str(qtd) + "x"
	
	if (timer.time_left > 0):
		$Control/Button.text = "já existe um item ativo"
	
	var showIcone = icones.get(id)
	if showIcone:
		$Control/Texture.texture = showIcone
	
func _on_use_pressed() -> void:
	if (timer.time_left > 0): return
	
	var body = {
		"userID": Global.userID,
		"itemID": id,
		"quantidade": -1
	}
	var json = JSON.stringify(body)
	print(json)
	
	var headers = ["Content-Type: application/json"]
	var url = Constants.API_URL + "/item/adicionarIteminventario"
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, json)
	
	
func _notification(what: int):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	Global.itemNome = nome
	if id == 3:
		Global.fish_wait_time = 3.0
		Global.fish_boost = 0.8
	elif id == 4:
		Global.minigame_add = "-1"
		Global.item_chance = 0.1
	elif id == 5:
		Global.minigame_timeout_scale = 0.7
		Global.fish_wait_time = 2.0
		Global.item_chance = 0.4
		Global.fish_boost = 0.6
		
	elif id == 6:
		Global.minigame_timeout_scale = 1.2
		Global.item_chance = 0.1
	timer.start()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
