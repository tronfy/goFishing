extends Node2D

static var scene := preload("res://prefabs/fish_container.tscn")
var f: FishContainer

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	
	for p in json:
		var tamanho = str(p.tamanho) + "m"
		f = scene.instantiate().with_data(p.nome, p.nomeCientifico, p.tamanhoMedio, p.pesoMedio, p.nativa, p.conhecido, p.capturado, tamanho, p.icone)
		$Control/GridContainer.add_child(f)
	
	$Control/Carregando.visible = false

func _ready() -> void:
	$Control/Carregando.visible = true
	for c in $Control/GridContainer.get_children():
		c.free()
	
	var config = ConfigFile.new()
	var status = config.load("user://auth.cfg")
	if status != OK: return
	var userID = config.get_value("player", "userID")
	
	var url = Constants.API_URL + "/peixe/peixedex/" + str(userID)
	$HTTPRequest.request(url)

func _notification(what: int):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
