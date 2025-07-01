class_name FishContainer
extends Button

static var scene := preload("res://scenes/especie.tscn")
var s: TelaEspecie

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

func with_data(
	_especie: String,
	_nome_cientifico: String,
	_tamanho_medio: String,
	_peso_medio: String,
	_nativa: bool,
	_visto: bool,
	_capturado: bool,
	_tamanho: String,
	_icone: String
) -> FishContainer:
	especie = _especie
	nome_cientifico = _nome_cientifico
	tamanho_medio = _tamanho_medio
	peso_medio = _peso_medio
	nativa = _nativa
	visto = _visto
	capturado = _capturado
	tamanho = _tamanho
	icone = _icone
	return self

func _ready() -> void:
	if capturado:
		$EspecieLabel.text = especie
		$RecordeLabel.text = tamanho
	else: 
		$EspecieLabel.text = "?"
		$RecordeLabel.text = ""
	
	var showIcone = icones.get(icone)
	if showIcone:
		$Texture.texture = showIcone
	
	if not visto:
		$Texture.material = silMat


func _on_pressed() -> void:
	s = scene.instantiate().with_data(especie, nome_cientifico, tamanho_medio, peso_medio, nativa, visto, capturado, tamanho, icone)
	get_parent().get_parent().add_child(s)
