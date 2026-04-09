extends CharacterBody2D

@onready var player = get_parent().get_node_or_null("adultrizal")

const LEVEL_DATA := {
	"res://levels/midterm/1/1.tscn": ["1", "res://transitionstoryboard/midterm/firsteurope.tscn"],
	"res://levels/midterm/4/1.tscn": ["4/1", "res://levels/midterm/5/1.tscn"],
	"res://levels/midterm/5/brusselsappartmentrizal.tscn": ["5/1", "res://GUI/mainmenu/levels.tscn"]
}

var is_near_npc: bool = false
var started_this_dialogue: bool = false 
var current_target_scene: String = ""
var current_opening_dialogue: String = "" # Tracks which level key is active

func _ready():
	# Connect Dialogic signals
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	print("NPC System: Ready.")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_near_npc:
		var current_path = get_tree().current_scene.scene_file_path
		
		if LEVEL_DATA.has(current_path):
			# Prevent starting multiple dialogues at once
			if Dialogic.current_timeline == null:
				var data = LEVEL_DATA[current_path]
				current_opening_dialogue = data[0] # Sets "1", "4/1", or "5/1"
				current_target_scene = data[1]    # Sets the next level path
				
				start_dialogue(current_opening_dialogue)
		else:
			print("NPC Error: Scene path not in LEVEL_DATA: ", current_path)

func start_dialogue(timeline_name: String):
	started_this_dialogue = true
	if player:
		player.set_physics_process(false)
	Dialogic.start(timeline_name) 

func _on_dialogic_signal(argument: String):
	# Triggered by the "Emit signal" event in your Dialogic Timeline
	if argument == "minigames":
		handle_minigame()
	elif argument == "change_level":
		start_smooth_transition()

func handle_minigame():
	var puzzle_ui = get_tree().current_scene.find_child("Gamegermany", true, false)
	if !puzzle_ui:
		push_error("Gamegermany node not found!")
		return

	puzzle_ui.visible = true
	
	var board_node = puzzle_ui.find_child("Boardlamp", true, false)
	if board_node:
		# Simulates tile press to start/reset
		board_node._on_Tile_pressed(-1)
		
		# Wait for the player to win the game
		await board_node.game_won
		print("Minigame Completed.")

		# Logic for Brussels: If we are in level 5/1, transition to menu
		if current_opening_dialogue == "5/1":
			start_smooth_transition()
		else:
			# If it's a different level's minigame, just give control back
			if player: player.set_physics_process(true)

func _on_timeline_ended():
	if started_this_dialogue:
		started_this_dialogue = false
		
		# If it's NOT the Brussels level, we might want to change levels immediately
		# If it IS Brussels, we wait for the minigame signal instead
		if current_opening_dialogue != "5/1" and current_target_scene != "":
			# Only transition here if you don't use the 'change_level' signal in the timeline
			pass 
		
		# Resume player if no level change is pending
		if current_target_scene == "":
			if player: player.set_physics_process(true)

func start_smooth_transition() -> void:
	if has_node("/root/Transitionlayer"):
		var transition = get_node("/root/Transitionlayer")
		transition.transition()
		if transition.has_signal("on_transition_finished"):
			await transition.on_transition_finished
	
	if FileAccess.file_exists(current_target_scene):
		get_tree().change_scene_to_file(current_target_scene)
	else:
		push_error("Scene file missing: " + current_target_scene)
		if player: player.set_physics_process(true)

# Collision checks
func _on_chatdetection_body_entered(body: Node2D) -> void:
	if body.name == "adultrizal":
		is_near_npc = true

func _on_chatdetection_body_exited(body: Node2D) -> void:
	if body.name == "adultrizal":
		is_near_npc = false
