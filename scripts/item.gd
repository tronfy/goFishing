class_name TelaItem
extends Node2D

#@onready var icones = {
	#"jau": preload("res://sprites/kenney_fish_pack/fish_blue.png"),
	#"piracanjuba": preload("res://sprites/kenney_fish_pack/fish_brown.png"),
	#"dourado": preload("res://sprites/kenney_fish_pack/fish_orange.png"),
	#"tilapia": preload("res://sprites/kenney_fish_pack/fish_pink.png"),
	#"sardinha": preload("res://sprites/kenney_fish_pack/fish_grey.png"),
	#"surubim": preload("res://sprites/kenney_fish_pack/fish_red.png"),
#}

var nome: String
var descricao: String
var qtd: int

func with_data(
		_nome: String,
		_descricao: String,
		_qtd: int,
	) -> TelaItem:
	nome = _nome
	descricao = _descricao
	qtd = _qtd
	return self

func _ready() -> void:
	$Control/LabelItem.text = nome
	$Control/LabelDescricao.text = descricao.replace('\n', '\n\n')
	
	$Control/LabelDuracao.text = "2min"
	$Control/LabelQtd.text = str(qtd) + "x"
	
	#var showIcone = icones.get(icone)
	#if showIcone:
		#$Control/Texture.texture = showIcone
	
func _notification(what: int):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
