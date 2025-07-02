extends Area2D

@export var chave_nome: String = "chave_vinicius"  # Nome da variável do Global

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is Player:
		if Global.has_variable(chave_nome):
			Global.set(chave_nome, true)
			if body.hud:
				body.hud.show_message("Você pegou a " + chave_nome.replace("chave_", "Chave ").capitalize())
			queue_free()
		else:
			if body.hud:
				body.hud.show_message("Chave desconhecida: " + chave_nome)
