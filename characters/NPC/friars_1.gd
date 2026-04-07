extends CharacterBody2D

var is_near_npc: bool = false
var started_this_dialogue: bool = false 

func _ready():
	Dialogic.timeline_ended.connect(_on_timeline_ended)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_near_npc:
		start_dialogue()


func start_dialogue():
	if Dialogic.current_timeline == null:
		started_this_dialogue = true
		Dialogic.start("firstglimpseofinjustice")

		# Stop player movement
		var player = get_tree().current_scene.find_child("youngrizal", true, false)
		if player:
			player.set_physics_process(false)


func _on_timeline_ended():
	if started_this_dialogue:
		started_this_dialogue = false

		
		QuestManager.update_quest(
			"The Beginning in Calamba",
			"Go to Rizal sibling and interact with her",
			true
		)

		# Enable player movement again
		var player = get_tree().current_scene.find_child("youngrizal", true, false)
		if player:
			player.set_physics_process(true)

		start_smooth_transition()


func start_smooth_transition() -> void:
	var tree = get_tree()
	var target_scene = "res://levels/prelim/1/leavingtocalamba.tscn"

	if has_node("/root/Transitionlayer"):
		Transitionlayer.transition()
		await Transitionlayer.on_transition_finished
		tree.change_scene_to_file(target_scene)
	else:
		tree.change_scene_to_file(target_scene)


# --- Signal Connections ---

func _on_chatdetection_body_entered(body: Node2D) -> void:
	if body.name == "youngrizal":
		is_near_npc = true
		print("Player near Teodora: Press 'interact' to chat")


func _on_chatdetection_body_exited(body: Node2D) -> void:
	if body.name == "youngrizal":
		is_near_npc = false
		print("Player left the area")
