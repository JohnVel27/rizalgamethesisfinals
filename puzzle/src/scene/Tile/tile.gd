extends TextureButton

var number: int # Type hinting is recommended in Godot 4

signal tile_pressed(number)
signal slide_completed(number)

# Update the number of the tile
func set_text(new_number):
	number = new_number
	$number/Label.text = str(number)

# Update the background image of the tile
func set_sprite(new_frame, size, tile_size):
	var sprite = $Sprite2D

	update_size(size, tile_size)

	sprite.hframes = size
	sprite.vframes = size
	sprite.frame = new_frame

# scale to the new tile_size
func update_size(size, tile_size):
	var new_size = Vector2(tile_size, tile_size)
	# In Godot 4, 'rect_size' is now 'size'
	self.size = new_size 
	$number.size = new_size
	$number/ColorRect.size = new_size
	$number/Label.size = new_size
	$Panel.size = new_size

	var to_scale = size * (new_size / $Sprite2D.texture.get_size())
	$Sprite2D.scale = to_scale

# Update the entire background image
func set_sprite_texture(texture):
	$Sprite2D.texture = texture

# Slide the tile to a new position (Godot 4 Tweening)
func slide_to(new_position: Vector2, duration: float):
	# Create a tween via the SceneTree
	var tween = get_tree().create_tween()
	
	# 'rect_position' is now 'position'
	tween.tween_property(self, "position", new_position, duration)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)
	
	# Connect to the finished signal (replacing the old Tween node signal)
	tween.finished.connect(_on_tween_finished)

# Hide / Show the number of the tile
func set_number_visible(state):
	$number.visible = state

# Tile is pressed
func _on_pressed(): # Renamed from _on_Tile_pressed to match default signals
	tile_pressed.emit(number)

# Replacement for the old tween_completed signal
func _on_tween_finished():
	slide_completed.emit(number)
