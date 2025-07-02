extends Node

var destination_level : String = ""

# Variáveis de vida!
var max_hp := 3
var hp := 3

var has_spray := false
var spray_ammo := 0

var has_key_1 := false
var has_key_2 := false
var has_key_3 := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func resetar():
	destination_level = ""
	max_hp = 3
	hp = 3
	has_spray = false
	spray_ammo = 0
	has_key_1 = false
	has_key_2 = false
	has_key_3 = false
