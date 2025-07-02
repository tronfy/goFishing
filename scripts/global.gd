extends Node

var userID

var itemNome
var fish_wait_time = 6.0
var minigame_timeout_scale = 1.0
var minigame_add = 0
var item_chance = 0.2
var fish_boost = 0.5

func _ready() -> void:
	update_user_id()

func update_user_id() -> void:
	var config = ConfigFile.new()
	var status = config.load("user://auth.cfg")
	if status != OK: return
	userID = config.get_value("player", "userID")


func _on_item_timer_timeout() -> void:
	itemNome = null
	fish_wait_time = 6.0
	minigame_timeout_scale = 1.0
	minigame_add = 0
	item_chance = 0.2
	fish_boost = 0.5
