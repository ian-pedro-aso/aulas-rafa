extends CharacterBody2D
class_name Player

@export var speed := 100
@onready var animated_sprite := $AnimatedSprite2D
@onready var camera := $Camera2D
@onready var hud = $HUD
@onready var damage_sound = $DamageSound
@onready var aim_pointer = $AimPointer
@export var gas_projectile_scene: PackedScene
@onready var audio_andar: AudioStreamPlayer2D = $AudioAndar

var last_direction := Vector2.DOWN
var last_aim_direction_gamepad := Vector2.DOWN
var is_dead := false

var hp: int
var max_hp: int

# Câmera
var camera_target_offset := Vector2.ZERO
var camera_speed := 100.0

# Stamina
var max_stamina := 100.0
var stamina := max_stamina
var stamina_regen := 20.0
var stamina_drain := 40.0
var stamina_delay := 1.0
var regen_timer := 0.0
var can_regen := true

# Corrida com clique rápido
var corrida_impulso := 0.0
var impulso_maximo := 3.0
var impulso_decay := 2.0
var corrida_verificando := false
var corrida_timer: Timer

func _ready():
	hp = Global.hp
	max_hp = Global.max_hp

	if hud == null:
		print("HUD não encontrado!")
	else:
		print("HUD carregado com sucesso.")
		call_deferred("update_hud")
		if hud.has_method("hide_death_text"):
			hud.hide_death_text()

	corrida_timer = Timer.new()
	corrida_timer.wait_time = 0.3
	corrida_timer.one_shot = true
	corrida_timer.timeout.connect(_on_corrida_timer_timeout)
	add_child(corrida_timer)

	last_aim_direction_gamepad = last_direction

func _on_corrida_timer_timeout():
	corrida_verificando = false

func update_hud():
	if hud and hud.has_method("update_hearts"):
		hud.update_hearts(hp)

func take_damage(amount: int):
	if is_dead:
		return
	hp -= amount
	hp = clamp(hp, 0, max_hp)
	Global.hp = hp
	update_hud()
	if hp <= 0:
		die()
	if damage_sound:
		damage_sound.play()
	blink()

func die():
	if is_dead:
		return
	is_dead = true
	set_physics_process(false)
	animated_sprite.flip_h = randf() < 0.5
	animated_sprite.play("death_side")
	var offset_x = 50 if animated_sprite.flip_h else -50
	camera_target_offset = camera.position + Vector2(offset_x, 0)
	if hud and hud.has_method("show_death_text"):
		hud.show_death_text()

	Global.resetar()

func _physics_process(delta):
	if is_dead:
		return

	var direction := Vector2.ZERO

	if Input.is_action_pressed("Mdireita"):
		direction.x += 1
	if Input.is_action_pressed("Mesquerda"):
		direction.x -= 1
	if Input.is_action_pressed("Mbaixo"):
		direction.y += 1
	if Input.is_action_pressed("Mcima"):
		direction.y -= 1

	var is_moving = direction != Vector2.ZERO
	if is_moving:
		if !audio_andar.playing:
			audio_andar.play()
	else:
		if audio_andar.playing:
			audio_andar.stop()

	if corrida_impulso > 0.1 and stamina > 0:
		speed = 200
		animated_sprite.speed_scale = 2.5
		stamina = max(0, stamina - stamina_drain * delta)
		can_regen = false
	else:
		speed = 100
		animated_sprite.speed_scale = 1.0

	corrida_impulso = max(0, corrida_impulso - impulso_decay * delta)

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	if direction != Vector2.ZERO:
		last_direction = direction
		if abs(direction.x) > abs(direction.y):
			animated_sprite.play("side")
			animated_sprite.flip_h = direction.x < 0
		else:
			animated_sprite.flip_h = false
			if direction.y > 0:
				animated_sprite.play("down")
			else:
				animated_sprite.play("up")
	else:
		if abs(last_direction.x) > abs(last_direction.y):
			animated_sprite.play("idleside")
			animated_sprite.flip_h = last_direction.x < 0
		else:
			animated_sprite.flip_h = false
			if last_direction.y > 0:
				animated_sprite.play("idledown")
			else:
				animated_sprite.play("idleup")

	if hud and hud.has_method("update_stamina"):
		hud.update_stamina(stamina)

func _process(delta):
	if is_dead:
		camera.position = camera.position.lerp(camera_target_offset, delta * 2.0)

		if Input.is_action_just_pressed("volta"):
			get_tree().change_scene_to_file("res://cenas/menus/main_menu.tscn")
		return

	if Input.is_action_just_pressed("ui_accept"):
		take_damage(1)

	if corrida_impulso <= 0 and stamina < max_stamina:
		if regen_timer < stamina_delay:
			regen_timer += delta
		else:
			stamina = min(stamina + stamina_regen * delta, max_stamina)
			can_regen = true
	else:
		regen_timer = 0.0

	update_aim_pointer()

func blink():
	if not is_instance_valid(animated_sprite):
		return

	var times := 3
	var blink_time := 0.1

	for i in range(times):
		animated_sprite.modulate.a = 0.2
		await get_tree().create_timer(blink_time).timeout
		animated_sprite.modulate.a = 1.0
		await get_tree().create_timer(blink_time).timeout

func get_analog_shot_direction() -> Vector2:
	var axis_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var axis_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	var direction = Vector2(axis_x, axis_y)
	if direction.length() < 0.2:
		return Vector2.ZERO
	return direction.normalized()

func update_aim_pointer():
	if not is_instance_valid(aim_pointer):
		return

	var current_gamepad_aim_input = get_analog_shot_direction()
	var final_aim_dir: Vector2

	if current_gamepad_aim_input.length() > 0.1:
		final_aim_dir = current_gamepad_aim_input
		last_aim_direction_gamepad = current_gamepad_aim_input
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		final_aim_dir = last_aim_direction_gamepad
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	aim_pointer.visible = true
	var distance := 20.0
	aim_pointer.global_position = global_position + (final_aim_dir * distance)
	aim_pointer.rotation = final_aim_dir.angle()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("atirar") and not is_dead and Global.has_spray and Global.spray_ammo > 0:
		Global.spray_ammo -= 1
		hud.update_spray_ammo(Global.spray_ammo)

		var projectile = gas_projectile_scene.instantiate() as Area2D
		var shoot_direction = last_aim_direction_gamepad.normalized()
		projectile.direction = shoot_direction
		projectile.global_position = global_position
		get_parent().add_child(projectile)
		$SpraySound.play()

	if event.is_action_pressed("correr") and not is_dead and stamina > 0:
		if not corrida_verificando:
			corrida_verificando = true
			corrida_timer.start()
		else:
			corrida_impulso = min(corrida_impulso + 1.0, impulso_maximo)
			corrida_verificando = false
			corrida_timer.stop()
