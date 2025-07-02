extends Area2D

@export var next_level: String = ""
@export var chaves_necessarias: Array[String] = [""]  # Ex: ["chave_3", "chave_4", "chave_5", "chave_6"]

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is Player:
		var todas_tem := true
		for chave in chaves_necessarias:
			if not Global.has_variable(chave) or not Global.get(chave):
				todas_tem = false
				break

		if todas_tem:
			Global.destination_level = get_parent().name
			get_tree().call_deferred("change_scene_to_file", next_level)
		else:
			if body.hud:
				var msg = "Você precisa das chaves: "
				for chave in chaves_necessarias:
					if not Global.get(chave):
						msg += chave.replace("chave_", "") + " "
				body.hud.show_message(msg.strip_edges())
