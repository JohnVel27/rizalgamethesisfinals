extends Node

@onready var main_button: VBoxContainer = $MainButton
@onready var settings: Panel = $Settings

func _ready():
	main_button.visible = true
	settings.visible = false

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://GUI/mainmenu/levels.tscn")

func _on_settings_pressed() -> void:
	main_button.visible = false
	settings.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_htp_pressed() -> void:
	pass # Replace with function body.


func _on_back_settings_pressed() -> void:
	_ready()
