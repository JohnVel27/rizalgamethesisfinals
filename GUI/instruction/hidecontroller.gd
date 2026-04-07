extends Button

func _on_pressed():
	# 1. Unpause the entire game engine
	get_tree().paused = false
	
	# 2. Hide the controller menu
	get_parent().visible = false
	
	# Optional: Remove the menu from the scene entirely to save memory
	# get_parent().queue_free() 
	
	print("Game Unpaused and Menu hidden!")
