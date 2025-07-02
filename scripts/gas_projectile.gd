# GasProjectile.gd
extends Area2D

var speed := 75.0
var direction := Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Move o projétil na direção definida
	position += direction * speed * delta

# Chamado quando o projétil atinge algo
func _on_body_entered(body: Node2D) -> void:
	# Se atingir um inimigo (vamos supor que seu inimigo está no grupo "enemies")
	if body.is_in_group("enemies"):
		body.take_damage(1) # Supondo que seu inimigo tenha uma função take_damage
		queue_free() # O gás se dissipa ao atingir um inimigo
	
	# Se atingir uma parede (vamos supor que paredes estão na tilemap layer 1)
	if body is TileMap and body.get_layer_for_body_rid(get_rid()) == 1:
		queue_free() # O gás se dissipa ao atingir uma parede


# Chamado quando o projétil sai da tela
func _on_screen_exited() -> void:
	queue_free()
