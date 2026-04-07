extends CharacterBody2D
class_name Player

@export var inventory_data: InventoryData

@onready var walk_sfx: AudioStreamPlayer = $walk_sfx
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var tile_map: TileMap
var astar: AStarGrid2D

var current_id_path: Array[Vector2i] = []
var speed: float = 160.0
var last_direction: Vector2 = Vector2.DOWN

var current_opening_dialogue := ""

# =========================
# READY
# =========================
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

	if get_tree().current_scene.has_node("TileMap"):
		tile_map = get_tree().current_scene.get_node("TileMap")
	else:
		push_error("TileMap not found!")

	# Connect dialogue finished
	if not Dialogic.timeline_ended.is_connected(_on_dialogue_finished):
		Dialogic.timeline_ended.connect(_on_dialogue_finished)

	# Connect signals safely
	if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.connect(_on_dialogic_signal)

	if not Dialogic.signal_event.is_connected(_on_dialogic_juancho_signal):
		Dialogic.signal_event.connect(_on_dialogic_juancho_signal)

	check_scene_opening_dialogue()


# =========================
# SCENE DIALOGUE CHECK
# =========================
func check_scene_opening_dialogue():

	var scene_path = get_tree().current_scene.scene_file_path

	if scene_path.ends_with("rizalhome.tscn"):
		start_opening_dialogue("Narrator-calamba")

	elif scene_path.ends_with("livingroomrizal.tscn"):
		start_opening_dialogue("narrator-livingroom")

	elif scene_path.ends_with("storyofthemoth.tscn"):
		start_opening_dialogue("storyofmoth")
		
	elif scene_path.ends_with("firstglimpseinjustice.tscn"):
		start_opening_dialogue("1narratorfirstglimpse")

	elif scene_path.ends_with("leavingtocalamba.tscn"):
		start_opening_dialogue("goingtobinan")

	elif scene_path.ends_with("maestroschool.tscn"):
		start_opening_dialogue("2narrator1")

	elif scene_path.ends_with("justianoclassroom.tscn"):
		start_opening_dialogue("2maestrocruzrizal1")

	elif scene_path.ends_with("juanchocarrera.tscn"):
		start_opening_dialogue("2juanchorizal1")

	elif scene_path.ends_with("maestroschool1.tscn"):
		start_opening_dialogue("brawlmission")

	elif scene_path.ends_with("ateneodemanila.tscn"):
		start_opening_dialogue("3narrator1")

	elif scene_path.ends_with("ust.tscn"):
		start_opening_dialogue("4narrator1")

	elif scene_path.ends_with("uhallway.tscn"):
		start_opening_dialogue("4narrato2")


# =========================
# OPENING DIALOGUE
# =========================
func start_opening_dialogue(timeline_name:String):

	if Dialogic.current_timeline != null:
		return

	current_opening_dialogue = timeline_name
	Dialogic.start(timeline_name)


# =========================
# PHYSICS PROCESS
# =========================
func _physics_process(_delta: float) -> void:

	if Dialogic.current_timeline != null:
		stop_player()
		return

	if current_id_path.is_empty():
		stop_player()
		return

	var target_position:Vector2 = tile_map.map_to_local(current_id_path[0])

	if global_position.distance_to(target_position) < 2:
		current_id_path.pop_front()
		return

	move_to_target(target_position)


# =========================
# STOP PLAYER
# =========================
func stop_player():
	play_idle_animation()
	velocity = Vector2.ZERO
	move_and_slide()
	walk_sfx.stop()


# =========================
# PATHFINDING
# =========================
func _input(event:InputEvent):

	if Dialogic.current_timeline != null:
		return

	if event.is_action_pressed("RightClick"):
		set_path_to_mouse()


func set_path_to_mouse():

	if astar == null:
		astar = tile_map.AstarGrid

	if astar == null:
		return

	var start_point:Vector2i = tile_map.local_to_map(global_position)
	var end_point:Vector2i = tile_map.local_to_map(get_global_mouse_position())

	current_id_path = astar.get_id_path(start_point,end_point)

	if current_id_path.size() > 0:
		current_id_path.remove_at(0)


# =========================
# MOVE
# =========================
func move_to_target(target:Vector2):

	var direction:Vector2 = (target - global_position).normalized()

	last_direction = direction
	velocity = direction * speed
	move_and_slide()

	if !walk_sfx.playing:
		walk_sfx.play()

	play_walk_animation(direction)


# =========================
# WALK ANIMATION
# =========================
func play_walk_animation(dir:Vector2):

	if abs(dir.x) > abs(dir.y):

		if dir.x > 0:
			sprite.play("carry_walk_side_right")
		else:
			sprite.play("carry_walk_side_left")

	else:

		if dir.y > 0:
			sprite.play("carry_walk_down")
		else:
			sprite.play("carry_walk_up")


# =========================
# IDLE ANIMATION
# =========================
func play_idle_animation():

	if abs(last_direction.x) > abs(last_direction.y):

		if last_direction.x > 0:
			sprite.play("carry_idle_side_right")
		else:
			sprite.play("carry_idle_side_left")

	else:

		if last_direction.y > 0:
			sprite.play("carry_idle_down")
		else:
			sprite.play("carry_idle_up")


# =========================
# DIALOGUE EVENTS
# =========================
func _on_dialogic_signal(argument:String):

	if argument != "puzzlegame":
		return

	var puzzle_ui = get_tree().current_scene.find_child("Gamelamp",true,false)

	if !puzzle_ui:
		push_error("Puzzle UI not found")
		return

	var player = get_tree().current_scene.find_child("youngrizal",true,false)

	if player:
		player.set_physics_process(false)

	puzzle_ui.visible = true

	var board_node = puzzle_ui.find_child("Boardlamp",true,false)

	if board_node:
		board_node._on_Tile_pressed(-1)

		await board_node.game_won

		if current_opening_dialogue == "storyofmoth":
			await start_smooth_transition("res://levels/prelim/1/leavingtocalamba.tscn")

	if player:
		player.set_physics_process(true)


func _on_dialogic_juancho_signal(argument:String):

	if argument != "minigamepuzzleart":
		return

	var scene = Engine.get_main_loop().current_scene

	var puzzle_ui = scene.find_child("Gameart",true,false)

	if !puzzle_ui:
		push_error("Puzzle UI Gameart not found")
		return

	var player = scene.find_child("youngrizal",true,false)

	if player:
		player.set_physics_process(false)

	puzzle_ui.visible = true

	var board_node = puzzle_ui.find_child("Boardart",true,false)

	if board_node:
		board_node._on_Tile_pressed(-1)

		await board_node.game_won

		if current_opening_dialogue == "2juanchorizal1":
			await start_smooth_transition("res://levels/prelim/3/ateneodemanila.tscn")

	if is_instance_valid(player):
		player.set_physics_process(true)



func _on_dialogue_finished():

	if current_opening_dialogue == "goingtobinan":
		await start_smooth_transition("res://transitionstoryboard/binan.tscn")

	if current_opening_dialogue == "2maestrocruzrizal1":
		await start_smooth_transition("res://levels/prelim/2/maestroschool1.tscn")

	current_opening_dialogue = ""

func start_smooth_transition(next_scene:String):

	if has_node("/root/Transitionlayer"):
		Transitionlayer.transition()
		await Transitionlayer.on_transition_finished

	get_tree().change_scene_to_file(next_scene)
