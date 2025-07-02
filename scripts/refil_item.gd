extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var hud = body.hud

		if not Global.has_spray:
			if hud:
				hud.show_message("Você não tem um spray para recarregar.")
			return

		if Global.spray_ammo >= 5:
			if hud:
				hud.show_message("Seu spray já está cheio.")
			return

		Global.spray_ammo = min(Global.spray_ammo + 5, 5)

		if hud:
			hud.update_spray_ammo(Global.spray_ammo)
			hud.show_message("Spray recarregado!")

		queue_free()
