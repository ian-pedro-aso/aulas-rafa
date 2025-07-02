extends Area2D

@export var chave_id := 2  # Defina 1, 2 ou 3 no Inspetor

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is Player:
		var hud = body.hud

		match chave_id:
			1:
				Global.has_key_1 = true
			2:
				Global.has_key_2 = true
			3:
				Global.has_key_3 = true

		if hud:
			hud.show_message("Você pegou a Chave %d!" % chave_id)

		queue_free()
