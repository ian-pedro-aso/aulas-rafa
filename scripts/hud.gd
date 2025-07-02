extends Node

@export var full_heart: Texture2D
@export var empty_heart: Texture2D

var hearts = []
var message_tween: Tween

@onready var stamina_bar: ProgressBar = $Estamina/ProgressBar
@onready var death_text = $Death_text
@onready var spray_ui := $Spray/SprayUI
@onready var ammo_label := $Spray/SprayUI/AmmoLabel

# 4 Labels fixos em um VBoxContainer chamado NotificationBox
@onready var notification_lines := [
	$notificantion_inputs/NotificationBox/Line1,
	$notificantion_inputs/NotificationBox/Line2,
	$notificantion_inputs/NotificationBox/Line3,
	$notificantion_inputs/NotificationBox/Line4,
]

func _ready():
	hearts = [
		$Hearts/HBoxContainer/heart1,
		$Hearts/HBoxContainer/heart2,
		$Hearts/HBoxContainer/heart3
	]

	death_text.visible = false
	clear_notification_lines()

	update_spray_display()
	update_spray_ammo(Global.spray_ammo)

func update_hearts(hp: int):
	for i in range(3):
		if i < hp:
			hearts[i].texture = full_heart
		else:
			hearts[i].texture = empty_heart

func update_stamina(value: float):
	stamina_bar.value = value

func show_death_text():
	death_text.visible = true

func hide_death_text():
	death_text.visible = false

func update_spray_display():
	if Global.has_spray:
		spray_ui.show()
	else:
		spray_ui.hide()

func update_spray_ammo(ammo: int):
	ammo_label.text = str(ammo)

# ✅ Mostra nova mensagem no topo e aplica fade-out de baixo pra cima
func show_message(text: String, duration: float = 3.0):
	# Move mensagens antigas para baixo
	for i in range(notification_lines.size() - 1, 0, -1):
		notification_lines[i].text = notification_lines[i - 1].text

	# Coloca nova mensagem no topo
	notification_lines[0].text = text

	# Cancela tween antigo se existir
	if message_tween and message_tween.is_valid():
		message_tween.kill()

	# Cria tween para fade de baixo pra cima
	message_tween = create_tween()
	for i in range(notification_lines.size() - 1, -1, -1):
		var line = notification_lines[i]
		var delay = (notification_lines.size() - 1 - i) * 0.1  # aumenta o delay conforme a linha for mais alta
		message_tween.tween_property(line, "modulate:a", 0.0, duration).set_delay(delay)

	message_tween.connect("finished", Callable(self, "_on_all_messages_hidden"))

func _on_all_messages_hidden():
	clear_notification_lines()

func clear_notification_lines():
	for line in notification_lines:
		line.text = ""
		line.modulate.a = 1.0  # Reseta opacidade pra ficar pronto pra próxima exibição
