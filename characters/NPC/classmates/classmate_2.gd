extends CharacterBody2D

var is_near_npc: bool = false
# Track if THIS specific NPC started the dialogue to avoid global scene changes
var started_this_dialogue: bool = false 

func _ready():
	# Connect Dialogic's signal to our handler
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_near_npc:
		start_dialogue()

func start_dialogue():
	if Dialogic.current_timeline == null:
		started_this_dialogue = true
		Dialogic.start("firstbrawl")
		
		# Optional: Disable player movement while talking
		var player = get_tree().current_scene.find_child("youngrizal", true, false)
		if player:
			player.set_physics_process(false)

func _on_timeline_ended():
	# Only proceed if this NPC was the one the player talked to
	if started_this_dialogue:
		started_this_dialogue = false # Reset the flag
		start_smooth_transition()

func start_smooth_transition() -> void:
	# 1. Grab the tree NOW while the node is still 'inside' the scene
	var tree = get_tree()
	var target_scene = "res://levels/prelim/2/maestroschool2.tscn"
	
	# Re-enable player physics
	var player = tree.current_scene.find_child("youngrizal", true, false)
	if player:
		player.set_physics_process(true)

	if has_node("/root/Transitionlayer"):
		Transitionlayer.transition()
		# 2. Wait for the animation
		await Transitionlayer.on_transition_finished
		
		# 3. Use the 'tree' variable we saved earlier 
		# instead of calling get_tree() again
		tree.change_scene_to_file(target_scene)
	else:
		tree.change_scene_to_file(target_scene)

# --- Signal Connections ---

func _on_chatdetection_body_entered(body: Node2D) -> void:
	if body is Player:
		is_near_npc = true
		print("Player near Teodora: Press 'interact' to chat")

func _on_chatdetection_body_exited(body: Node2D) -> void:
	if body is Player:
		is_near_npc = false
		print("Player left the area")
