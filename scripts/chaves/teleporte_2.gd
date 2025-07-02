extends Area2D

@export var next_level: String = "res://cenas/menus/main_menu.tscn"  # Caminho da cena de destino
@export var chave_necessaria_1 := false     # Porta exige a chave 1?
@export var chave_necessaria_2 := true       # Porta exige a chave 2?
@export var chave_necessaria_3 := true       # Porta exige a chave 3?

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if not (body is Player):
		return

	var hud = body.hud
	var pode_entrar := true
	var faltando := []

	if chave_necessaria_1 and not Global.has_key_1:
		pode_entrar = false
		faltando.append("Chave 1")
	if chave_necessaria_2 and not Global.has_key_2:
		pode_entrar = false
		faltando.append("Chave 2")
	if chave_necessaria_3 and not Global.has_key_3:
		pode_entrar = false
		faltando.append("Chave 3")

	if pode_entrar:
		get_tree().change_scene_to_file(next_level)
	else:
		if hud:
			hud.show_message("Você precisa de: " + ", ".join(faltando))
