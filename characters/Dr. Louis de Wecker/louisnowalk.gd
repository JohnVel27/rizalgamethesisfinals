extends CharacterBody2D

@onready var player = get_parent().get_node_or_null("adultrizal")

const TARGET_SCENE := "res://levels/midterm/2/rizaltypewritter.tscn"
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
	print("NPC: Starting Timeline '2/1'")
	started_this_dialogue = true
	
	if player:
		player.set_physics_process(false)
	
	Dialogic.start("2/1")

func _on_timeline_ended():
	
	if started_this_dialogue:
		
		print("NPC: Dialogue finished. Preparing transition...")
		started_this_dialogue = false
		
		
		if has_node("/root/QuestManager"):
			QuestManager.update_quest("In the France", "Talk to Dr. Louis de Wecker", false)
		
		if player:
			player.set_physics_process(true)
		
		start_smooth_transition()

func _on_dialogic_signal(argument: String):
	if argument == "change_level":
		print("NPC: Received manual signal to change level.")
		_on_timeline_ended()

func start_smooth_transition() -> void:
	if has_node("/root/Transitionlayer"):
		print("NPC: Starting Transitionlayer animation.")
		var transition = get_node("/root/Transitionlayer")
		transition.transition()
		
		if transition.has_signal("on_transition_finished"):
			await transition.on_transition_finished
	
	if FileAccess.file_exists(TARGET_SCENE):
		print("NPC: Changing scene to: ", TARGET_SCENE)
		get_tree().call_deferred("change_scene_to_file", TARGET_SCENE)
	else:
		printerr("NPC ERROR: Target scene path is incorrect: ", TARGET_SCENE)

func _on_chatdetection_body_entered(body: Node2D) -> void:
	if body.name == "adultrizal":
		is_near_npc = true
		print("Player is in range.")

func _on_chatdetection_body_exited(body: Node2D) -> void:
	if body.name == "adultrizal":
		is_near_npc = false
		print("Player left range.")
