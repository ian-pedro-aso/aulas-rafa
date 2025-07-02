# inimigo.gd
extends CharacterBody2D

# Você pode ajustar a velocidade do inimigo no Inspetor
@export var velocidade: float = 30.0
@export var medkit_scene: PackedScene # <--- ADICIONE ESTA LINHA
@export var refill_scene: PackedScene # <--- ADICIONE ESTA LINHA
var hp: int = 2 # <--- ADICIONE ESTA LINHA (vida inicial = 2)

# Variável que vai "segurar" o jogador quando ele estiver no alcance
var player_target: Player = null

# A lógica principal do inimigo, executada a cada frame de física
func _physics_process(_ddelta):
	# Se não há um alvo, o inimigo fica parado.
	if player_target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Se houver um alvo (o jogador):
	# 1. Calcula o vetor de direção normalizado até a posição global do alvo
	var direcao = global_position.direction_to(player_target.global_position)
	
	# 2. Define a velocidade na direção do alvo
	velocity = direcao * velocidade
	
	# 3. Move o inimigo usando a física, o que permite colidir com paredes
	move_and_slide()
	
	# 4. Vira o sprite horizontalmente baseado na direção do movimento

# --- SINAIS ---

# O nome desta função corresponde ao sinal "body_exited" do nó "DetectionArea2D"


# O nome desta função corresponde ao sinal "body_entered" do nó "damageArea2D"

func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	# Verifica se o corpo que entrou é o jogador
	if body is Player:
		# Se for, o define como o alvo a ser perseguido
		player_target = body
		$BuzzSound.play() # Toca o som da mosca em loop


func _on_detection_area_2d_body_exited(body: Node2D) -> void:
	# Verifica se o corpo que saiu era o jogador
	if body is Player:
		# Se for, limpa o alvo para que o inimigo pare de perseguir
		player_target = null
		$BuzzSound.stop() # Para o som da mosca


func _on_damage_area_2d_body_entered(body: Node2D) -> void:
	# Verifica se o corpo que entrou na área de dano é o jogador
	if body is Player:
		# Chama a função de dano no script do jogador
		body.take_damage(1)
func take_damage(amount: int) -> void:
	hp -= amount # Subtrai a quantidade de dano da vida
	if hp <= 0:
		die() # Se a vida chegar a zero, chama a função para morrer
func die() -> void:
	# 1. Impede que o inimigo se mova e processe física
	set_physics_process(false)

	# 2. Desativa a colisão para que ele não bloqueie mais o jogador
	#    (IMPORTANTE: renomeie "CollisionShape2D" para o nome real do seu nó de colisão)
	$CollisionShape2D.set_deferred("disabled", true)

	# 3. Tocar a animação de morte, se existir
	$AnimatedSprite2D.play("morte")
	await $AnimatedSprite2D.animation_finished
	# --- LÓGICA DE DROP ADICIONADA AQUI ---
	# Gera um número aleatório entre 0.0 e 1.0
	# Se for menor que 0.2, significa que acertamos a chance de 20%
	if randf() < 0.20:
		var item_a_dropar: PackedScene

		# Agora, decidimos QUAL item dropar (50/50 de chance)
		if randf() < 0.5:
			item_a_dropar = medkit_scene
		else:
			item_a_dropar = refill_scene
		
		# Verificamos se uma cena foi realmente definida antes de instanciar
		if item_a_dropar:
			var item_instancia = item_a_dropar.instantiate()
			# Adiciona o item na cena principal (no mesmo nível do inimigo)
			get_parent().add_child(item_instancia)
			# Posiciona o item exatamente onde o inimigo morreu
			item_instancia.global_position = global_position

	# Remove o inimigo da cena permanentemente (depois de tentar o drop)
	queue_free()
	# 4. Remove o inimigo da cena permanentemente
	queue_free()
