class_name ItemContainer
extends Button

static var scene := preload("res://scenes/item.tscn")
var s: TelaItem

var id: int
var nome: String
var descricao: String
var qtd: int

func with_data(_id: int, _nome: String, _descricao: String, _qtd: int) -> ItemContainer:
	id = _id
	nome = _nome
	descricao = _descricao
	qtd = _qtd
	return self

func _ready() -> void:
	$ItemLabel.text = nome
	$QuantidadeLabel.text = str(qtd) + "x"

func _on_pressed() -> void:
	s = scene.instantiate().with_data(id, nome, descricao, qtd)
	get_parent().get_parent().add_child(s)
