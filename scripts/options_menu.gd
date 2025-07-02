extends Control

func _ready():
	await get_tree().process_frame
	$Button.grab_focus()

func _input(event):
	if event.is_action_pressed("confirmar"):
		var focus = get_viewport().gui_get_focus_owner()
		if focus:
			focus.emit_signal("pressed")
	elif event.is_action_pressed("atirar"):
		get_tree().change_scene_to_file("res://cenas/menus/main_menu.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/menus/main_menu.tscn")
