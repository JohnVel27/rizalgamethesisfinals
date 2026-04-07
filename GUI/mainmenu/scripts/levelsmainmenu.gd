extends Node

func _on_prelim_pressed() -> void:
	Transitionlayer.transition()
	await Transitionlayer.on_transition_finished
	get_tree().change_scene_to_file("res://transitionstoryboard/calamba.tscn")


func _on_prelim_3_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/midterm/1/1.tscn")
	
