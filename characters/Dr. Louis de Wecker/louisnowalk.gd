extends CharacterBody2D

@onready var player = get_parent().get_node_or_null("adultrizal")

## --- NPC CONFIGURATION (Inspector) ---
@export_group("Dialogue & Scene")
## The timeline name in Dialogic (e.g., "2/1")
@export var timeline_name: String = "2/1"
## Choose the .tscn file for the next level
@export_file("*.tscn") var next_scene_path: String = "res://levels/midterm/2/rizaltypewritter.tscn"

@export_group("Quest Settings")
@export var quest_title: String = "In the France"
@export var quest_step: String = "Talk to Dr. Louis de Wecker"

## --- STATE VARIABLES ---
var is_near_npc: bool = false
var started_this_dialogue: bool = false

func _ready():
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	print("NPC Ready: Signals connected.")
	
	if has_node("/root/QuestManager"):
		QuestManager.check_location_completion()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_near_npc:
		if Dialogic.current_timeline == null:
			start_dialogue()

func start_dialogue():
	print("NPC: Starting Timeline: ", timeline_name)
	started_this_dialogue = true
	
	if player:
		player.set_physics_process(false)
	
	Dialogic.start(timeline_name)

func _on_timeline_ended():
	if started_this_dialogue:
		print("NPC: Dialogue finished. Preparing transition...")
		started_this_dialogue = false
		
		# Update Quest
		if has_node("/root/QuestManager"):
			QuestManager.update_quest(quest_title, quest_step, false)
		
		# Free Player
		if player:
			player.set_physics_process(true)
		
		# Only transition if a path exists
		if next_scene_path != "":
			start_smooth_transition()

func _on_dialogic_signal(argument: String):
	if argument == "change_level":
		print("NPC: Received manual signal to change level.")
		_on_timeline_ended()

func start_smooth_transition() -> void:
	# Using the exported variable next_scene_path directly
	if has_node("/root/Transitionlayer"):
		Transitionlayer.transition()
		if Transitionlayer.has_signal("on_transition_finished"):
			await Transitionlayer.on_transition_finished

	if next_scene_path != "":
		print("NPC: Changing scene to: ", next_scene_path)
		get_tree().call_deferred("change_scene_to_file", next_scene_path)

func _on_chatdetection_body_entered(body: Node2D) -> void:
	if body.name == "adultrizal":
		is_near_npc = true
		print("Player is in range.")

func _on_chatdetection_body_exited(body: Node2D) -> void:
	if body.name == "adultrizal":
		is_near_npc = false
		print("Player left range.")
