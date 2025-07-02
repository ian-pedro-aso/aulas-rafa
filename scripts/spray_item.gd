extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.has_spray = true
		Global.spray_ammo = 5

		var hud = body.hud
		if hud:
			hud.update_spray_display()
			hud.update_spray_ammo(Global.spray_ammo)
			hud.show_message("Você adquiriu o spray!")

		queue_free()
