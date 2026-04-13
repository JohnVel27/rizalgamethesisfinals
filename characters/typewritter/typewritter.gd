extends CharacterBody2D

@onready var player = get_parent().get_node_or_null("adultrizal")

## --- NPC CONFIGURATION (Set these in the Inspector) ---
@export_group("Dialogue & Scene")
## The name of the Dialogic timeline to play
@export var timeline_name: String = "typewritter"
## The scene to load after the dialogue ends
@export_file("*.tscn") var next_scene_path: String = "res://levels/midterm/3/rizalcomebackpier.tscn"

@export_group("Quest Settings")
## The title of the quest to update
@export var quest_title: String = "In the France"
## The objective text
@export var quest_step: String = "Interact to the table"

## --- STATE VARIABLES ---
var is_near_npc: bool = false
var started_this_dialogue: bool = false 

func _ready():
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	print("NPC Ready: Script updated for Export compatibility.")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_near_npc:
		# If no dialogue is running, start it using the exported variable
		if Dialogic.current_timeline == null:
			if timeline_name != "":
				start_dialogue()
			else:
				print("NPC Warning: No timeline name assigned in Inspector.")

func start_dialogue():
	print("NPC: Starting Timeline: ", timeline_name)
	started_this_dialogue = true
	
	if player:
		player.set_physics_process(false)
	
	Dialogic.start(timeline_name) 

func _on_timeline_ended():
	# Only proceed if THIS NPC was the one being talked to
	if started_this_dialogue:
		started_this_dialogue = false
		print("NPC: Dialogue finished. Updating quest and transitioning.")
		
		# 1. Update Quest
		if has_node("/root/QuestManager"):
			QuestManager.update_quest(quest_title, quest_step, true)
			
		# 2. Release Player
		if player:
			player.set_physics_process(true)
		
		# 3. Transition to next scene
		if next_scene_path != "":
			start_smooth_transition()

func _on_dialogic_signal(argument: String):
	if argument == "change_level":
		_on_timeline_ended()

func start_smooth_transition() -> void:
	# Check for transition layer
	if has_node("/root/Transitionlayer"):
		var transition = get_node("/root/Transitionlayer")
		transition.transition()
		if transition.has_signal("on_transition_finished"):
			await transition.on_transition_finished
	
	# Safe scene change for Exported builds
	if next_scene_path != "":
		print("NPC: Moving to next stage: ", next_scene_path)
		get_tree().call_deferred("change_scene_to_file", next_scene_path)
	else:
		print("NPC ERROR: next_scene_path is empty!")

func _on_chatdetection_body_entered(body: Node2D) -> void:
	if body.name == "adultrizal":
		is_near_npc = true

func _on_chatdetection_body_exited(body: Node2D) -> void:
	if body.name == "adultrizal":
		is_near_npc = false
