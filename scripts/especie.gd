class_name TelaEspecie
extends Node2D

@onready var silMat = preload("res://shaders/silhouette.tres")

@onready var icones = {
	"jau": preload("res://sprites/kenney_fish_pack/fish_blue.png"),
	"piracanjuba": preload("res://sprites/kenney_fish_pack/fish_brown.png"),
	"dourado": preload("res://sprites/kenney_fish_pack/fish_orange.png"),
	"tilapia": preload("res://sprites/kenney_fish_pack/fish_pink.png"),
	"sardinha": preload("res://sprites/kenney_fish_pack/fish_grey.png"),
	"surubim": preload("res://sprites/kenney_fish_pack/fish_red.png"),
}

var especie: String
var nome_cientifico: String
var tamanho_medio: String
var peso_medio: String
var nativa: bool
var visto: bool
var capturado: bool
var tamanho: String
var icone: String
var tamanhoMinimo: float
var tamanhoMaximo: float

func with_data(
		_especie: String,
		_nome_cientifico: String,
		_tamanho_medio: String,
		_peso_medio: String,
		_nativa: bool,
		_visto: bool,
		_capturado: bool,
		_tamanho: String,
		_icone: String,
		_tamanhoMinimo: float,
		_tamanhoMaximo: float
	) -> TelaEspecie:
	especie = _especie
	nome_cientifico = _nome_cientifico
	tamanho_medio = _tamanho_medio
	peso_medio = _peso_medio
	nativa = _nativa
	visto = _visto
	capturado = _capturado
	tamanho = _tamanho
	icone = _icone
	tamanhoMinimo = _tamanhoMinimo
	tamanhoMaximo = _tamanhoMaximo
	return self

func _ready() -> void:
	if capturado:
		$Control/LabelEspecie.text = especie
		$Control/LabelNomeCientifico.text = nome_cientifico
		$Control/LabelPesoMedio.text = peso_medio
		$Control/LabelTamanhoMedio.text = tamanho_medio
		$Control/LabelNativa.text = "sim" if nativa else "não"
		
		$Control/LabelRecorde.text = tamanho + " (" + Global.get_stars_string(float(tamanho), tamanhoMaximo) + ")"
	else: 
		$Control/LabelEspecie.text = "?"
		$Control/LabelNomeCientifico.text = "? ?"
		$Control/LabelPesoMedio.text = "?"
		$Control/LabelTamanhoMedio.text = "?"
		$Control/LabelNativa.text = "?"
		
		$Control/LabelRecorde.text = "X"
	
	var showIcone = icones.get(icone)
	if showIcone:
		$Control/Texture.texture = showIcone
	
	if not visto:
		$Control/Texture.material = silMat

func _notification(what: int):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
