extends Control

func _ready():
	$Menu/Jogar.grab_focus()

func _input(event):
	if event.is_action_pressed("confirmar"):
		var focus = get_viewport().gui_get_focus_owner()
		if focus:
			focus.emit_signal("pressed")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/fases/fase_1_porao.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/menus/options_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
