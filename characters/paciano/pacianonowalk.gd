extends CharacterBody2D

@onready var player = get_parent().get_node_or_null("adultrizal")

# I kept your Dictionary, but we will "clean" the paths before checking them
const LEVEL_DATA := {
	"res://levels/midterm/1/1.tscn": [
		"1", 
		"res://transitionstoryboard/midterm/firsteurope.tscn", 
		"First Sojourn to Europe"
	],
	"res://levels/midterm/4/1.tscn": [
		"4/1", 
		"res://levels/midterm/5/1.tscn", 
		"Second Sojourn to Europe (1888)"
	],
	"res://levels/midterm/5/brusselsappartmentrizal.tscn": [
		"5/1", 
		"res://GUI/mainmenu/levels.tscn", 
		"Rizal in Brussels"
	]
}

var is_near_npc: bool = false
var started_this_dialogue: bool = false 
var current_target_scene: String = ""
var current_quest_to_complete: String = ""

func _ready():
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	if has_node("/root/QuestManager"):
		QuestManager.check_location_completion()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_near_npc:
		# --- CRITICAL EXPORT FIX ---
		# We remove ".remap" from the path so it matches the Dictionary key
		var current_path = get_tree().current_scene.scene_file_path.replace(".remap", "")
		
		if LEVEL_DATA.has(current_path):
			if Dialogic.current_timeline == null:
				var data = LEVEL_DATA[current_path]
				current_opening_dialogue_logic(data)

func current_opening_dialogue_logic(data: Array):
	var timeline_to_use = data[0] 
	current_target_scene = data[1] 
	current_quest_to_complete = data[2]
	start_dialogue(timeline_to_use)

func start_dialogue(timeline_name: String):
	started_this_dialogue = true
	if player:
		player.set_physics_process(false)
	Dialogic.start(timeline_name) 

func _on_timeline_ended():
	if started_this_dialogue:
		started_this_dialogue = false
		
		if current_quest_to_complete != "" and has_node("/root/QuestManager"):
			QuestManager.update_quest(current_quest_to_complete, "Talk to Paciano", true)
		
		if player:
			player.set_physics_process(true)
		
		if current_target_scene != "":
			start_smooth_transition()

func _on_dialogic_signal(argument: String):
	if argument == "change_level":
		_on_timeline_ended()

func start_smooth_transition() -> void:
	if has_node("/root/Transitionlayer"):
		var transition = get_node("/root/Transitionlayer")
		transition.transition()
		if transition.has_signal("on_transition_finished"):
			await transition.on_transition_finished
	
	# --- EXPORT FIX #2 ---
	# ResourceLoader.exists is better than FileAccess.file_exists for exported builds
	if current_target_scene != "" and ResourceLoader.exists(current_target_scene):
		get_tree().call_deferred("change_scene_to_file", current_target_scene)
	else:
		push_error("Scene not found in exported build: " + current_target_scene)

func _on_chatdetection_body_entered(body: Node2D) -> void:
	if body.name == "adultrizal":
		is_near_npc = true

func _on_chatdetection_body_exited(body: Node2D) -> void:
	if body.name == "adultrizal":
		is_near_npc = false
