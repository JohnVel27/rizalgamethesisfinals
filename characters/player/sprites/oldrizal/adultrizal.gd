extends CharacterBody2D


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var walk_sfx: AudioStreamPlayer = $walk_sfx

var tile_map: TileMap
var astar: AStarGrid2D

var current_id_path: Array[Vector2i] = []
var speed: float = 160.0
var last_direction: Vector2 = Vector2.DOWN
var current_opening_dialogue := ""

func _ready() -> void:
	if get_tree().current_scene.has_node("TileMap"):
		tile_map = get_tree().current_scene.get_node("TileMap")
	else:
		push_error("TileMap not found in current scene!")

	# Connect once only
	if not Dialogic.timeline_ended.is_connected(_on_dialogue_finished):
		Dialogic.timeline_ended.connect(_on_dialogue_finished)

	var scene_path = get_tree().current_scene.scene_file_path

	# Scene-based dialogue triggers
	if scene_path.ends_with("rizalhome.tscn"):
		start_opening_dialogue("Narrator-calamba")
	elif scene_path.ends_with("livingroomrizal.tscn"):
		start_opening_dialogue("narrator-livingroom")
	elif scene_path.ends_with("storyofthemoth.tscn"):
		start_opening_dialogue("storyofmoth")
	elif scene_path.ends_with("leavingtocalamba.tscn"):
		start_opening_dialogue("goingtobinan")
	elif scene_path.ends_with("maestroschool.tscn"):
		start_opening_dialogue("2narrator1")
	elif scene_path.ends_with("justianoclassroom.tscn"):
		start_opening_dialogue("2maestrocruzrizal1")
	elif scene_path.ends_with("juanchocarrera.tscn"):
		start_opening_dialogue("2juanchorizal1")
	elif scene_path.ends_with("ateneodemanila.tscn"):
		start_opening_dialogue("3narrator1")
	elif scene_path.ends_with("ust.tscn"):
		start_opening_dialogue("4narrator1")
	elif scene_path.ends_with("res://levels/prelim/4/uhallway.tscn"):
		start_opening_dialogue("4narrato2")
	elif scene_path.ends_with("res://levels/midterm/1/1.tscn"):
		start_opening_dialogue("1midtermnarrator1")
	elif scene_path.ends_with("res://levels/midterm/2/medicalclinic.tscn"):
		start_opening_dialogue("2midtermnarrator1")
	elif scene_path.ends_with("res://levels/midterm/2/1.tscn"):
		start_opening_dialogue("gotomedicalclinic")
	elif scene_path.ends_with("res://levels/midterm/3/comebackhome.tscn"):
		start_opening_dialogue("3midtermnarrator1")
	elif scene_path.ends_with("res://levels/midterm/4/1.tscn"):
		start_opening_dialogue("1midtermnarrator1")
	elif scene_path.ends_with("res://levels/midterm/5/1.tscn"):
		start_opening_dialogue("5midtermnarrator1")
	elif scene_path.ends_with("res://levels/midterm/5/brusselsappartmentrizal.tscn"):
		start_opening_dialogue("5midtermnarrator2")
	elif scene_path.ends_with("res://levels/finals/2/librariesinlondon.tscn"):
		start_opening_dialogue("StudyingPhilippineHistory")
	elif scene_path.ends_with("res://levels/finals/3/familyresidence.tscn"):
		start_opening_dialogue("SecondHomecoming1")

	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.signal_event.connect(_on_dialogic_juancho_signal)

# =========================
# OPENING DIALOGUE
# =========================

func start_opening_dialogue(timeline_name: String) -> void:
	if Dialogic.current_timeline != null:
		return
	current_opening_dialogue = timeline_name
	Dialogic.start(timeline_name)

# =========================
# SIGNAL HANDLERS
# =========================

func _on_dialogic_signal(argument: String) -> void:
	if argument != "puzzlegame": return
	
	var puzzle_ui = get_tree().current_scene.find_child("Gamelamp", true, false)
	if not puzzle_ui: return

	var player = get_tree().current_scene.find_child("youngrizal", true, false)
	if player: player.set_physics_process(false)
	
	velocity = Vector2.ZERO
	stop_walking_sfx() # Ensure sound stops during puzzle
	puzzle_ui.visible = true

	var board_node = puzzle_ui.find_child("Boardlamp", true, false)
	if board_node:
		board_node._on_Tile_pressed(-1)
		await board_node.game_won 
		if current_opening_dialogue == "storyofmoth":
			await start_smooth_transition("res://levels/prelim/1/leavingtocalamba.tscn")

	if player: player.set_physics_process(true)

func _on_dialogic_juancho_signal(argument: String) -> void:
	if argument != "minigamepuzzleart": return

	var puzzle_ui = get_tree().current_scene.find_child("Gameart", true, false)
	if not puzzle_ui: return

	var player = get_tree().current_scene.find_child("youngrizal", true, false)
	if player: player.set_physics_process(false)
	
	velocity = Vector2.ZERO
	stop_walking_sfx()
	puzzle_ui.visible = true

	var board_node = puzzle_ui.find_child("Boardart", true, false)
	if board_node:
		board_node._on_Tile_pressed(-1)
		await board_node.game_won 
		if current_opening_dialogue == "2juanchorizal1":
			await start_smooth_transition("res://levels/prelim/3/ateneodemanila.tscn")

	if player: player.set_physics_process(true)

func _on_dialogue_finished() -> void:
	if current_opening_dialogue == "goingtobinan":
		await start_smooth_transition("res://transitionstoryboard/binan.tscn")
	if current_opening_dialogue == "2maestrocruzrizal1":
		await start_smooth_transition("res://levels/prelim/2/juanchocarrera.tscn")
	if current_opening_dialogue == "StudyingPhilippineHistory":
		await start_smooth_transition("res://levels/finals/3/familyresidence.tscn")
	current_opening_dialogue = ""

# =========================
# MOVEMENT & PATHFINDING
# =========================

func _input(event: InputEvent) -> void:
	if Dialogic.current_timeline != null: return
	if event.is_action_pressed("RightClick"):
		set_path_to_mouse()

func set_path_to_mouse() -> void:
	if astar == null:
		astar = tile_map.AstarGrid
	if astar == null: return

	var start_point: Vector2i = tile_map.local_to_map(global_position)
	var end_point: Vector2i = tile_map.local_to_map(get_global_mouse_position())
	
	current_id_path = astar.get_id_path(start_point, end_point)
	if current_id_path.size() > 0:
		current_id_path.remove_at(0)

func _physics_process(_delta: float) -> void:
	# 1. Check if Dialogue is active
	if Dialogic.current_timeline != null:
		play_idle_animation()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# 2. Check if Path is empty
	if current_id_path.is_empty():
		play_idle_animation()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# 3. Movement execution
	var target_position: Vector2 = tile_map.map_to_local(current_id_path[0])

	if global_position.distance_to(target_position) < 2:
		current_id_path.pop_front()
		return

	move_to_target(target_position)

func move_to_target(target: Vector2) -> void:
	var direction: Vector2 = (target - global_position).normalized()
	last_direction = direction
	velocity = direction * speed
	move_and_slide()
	
	# Handle SFX: Only play if not already playing
	if not walk_sfx.playing:
		walk_sfx.play()
		
	play_walk_animation(direction)

# =========================
# ANIMATION & SFX HELPERS
# =========================

func play_walk_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		sprite.play("carry_walk_side_right" if dir.x > 0 else "carry_walk_side_left")
	else:
		sprite.play("carry_walk_down" if dir.y > 0 else "carry_walk_up")

func play_idle_animation() -> void:
	stop_walking_sfx() # Stop sound when idling
	if abs(last_direction.x) > abs(last_direction.y):
		sprite.play("carry_idle_side_right" if last_direction.x > 0 else "carry_idle_side_left")
	else:
		sprite.play("carry_idle_down" if last_direction.y > 0 else "carry_idle_up")

func stop_walking_sfx() -> void:
	if walk_sfx.playing:
		walk_sfx.stop()

# =========================
# TRANSITIONS
# =========================

func start_smooth_transition(next_scene: String) -> void:
	if is_instance_valid(get_node_or_null("/root/Transitionlayer")):
		Transitionlayer.transition()
		if Transitionlayer.has_signal("on_transition_finished"):
			await Transitionlayer.on_transition_finished
	get_tree().change_scene_to_file(next_scene)
