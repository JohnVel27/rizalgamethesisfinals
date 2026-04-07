extends Node

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://GUI/mainmenu/levels.tscn")
