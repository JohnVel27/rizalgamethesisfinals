extends CanvasLayer

func _ready():
	# Ensure the layer itself is visible
	self.show()
	
	# Set everything inside to transparent immediately
	for child in get_children():
		if child is CanvasItem:
			child.modulate.a = 0
	
	show_notification()

func show_notification():
	var tween = create_tween()
	
	# Fade everything IN
	for child in get_children():
		if child is CanvasItem:
			tween.parallel().tween_property(child, "modulate:a", 100.0, 2.5)
	
	# Wait 10 seconds
	tween.tween_interval(20.0)
	
	# Fade everything OUT
	for child in get_children():
		if child is CanvasItem:
			tween.parallel().tween_property(child, "modulate:a", 0.0, 0.5)
			
	# Delete after fading
	tween.tween_callback(queue_free)
