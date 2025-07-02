extends Area2D

@export var heal_amount := 1  # Quantidade de corações curados

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is Player:
		var hud = body.hud

		if body.hp < body.max_hp:
			body.hp = min(body.hp + heal_amount, body.max_hp)
			Global.hp = body.hp
			body.update_hud()
			if hud:
				hud.show_message("Você recuperou 1 de vida!")
			queue_free()
		else:
			if hud:
				hud.show_message("Você está com a vida cheia.")
