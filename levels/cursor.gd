extends Node2D


var tile_size = Vector2(32, 32)

func _process(_delta: float) -> void:
	
	var mouse_pos = get_global_mouse_position() + tile_size / 2
	position = mouse_pos.snapped(tile_size) - tile_size / 2


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				visible = true 
			else:
				visible = false 
