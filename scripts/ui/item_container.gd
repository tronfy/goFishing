class_name ItemContainer
extends ColorRect

var nome: String
var qtd: int

func with_data(_nome: String, _qtd: int) -> ItemContainer:
	nome = _nome
	qtd = _qtd
	return self

func _ready() -> void:
	$ItemLabel.text = nome
	$QuantidadeLabel.text = str(qtd) + "x"
