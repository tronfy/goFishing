extends Node2D

static var scene := preload("res://prefabs/item_container.tscn")
var s: ItemContainer

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	
	if len(json) > 0:
		for i in json:
			if i != null and i.quantidade > 0:
				s = scene.instantiate().with_data(i.nome, i.descricao, i.quantidade)
				$Control/GridContainer.add_child(s)
				print(i)
	
	$Control/Carregando.visible = false

func _ready() -> void:
	$Control/Carregando.visible = true
	for c in $Control/GridContainer.get_children():
		c.free()
	
	var config = ConfigFile.new()
	var status = config.load("user://auth.cfg")
	if status != OK: return
	var userID = config.get_value("player", "userID")
	
	var url = Constants.API_URL + "/item/inventario/" + str(userID)
	$HTTPRequest.request(url)

func _notification(what: int):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
