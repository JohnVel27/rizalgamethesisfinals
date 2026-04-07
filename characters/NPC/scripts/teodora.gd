extends CharacterBody2D

@export var speed: float = 60.0
@export var wander_radius: int = 5 # tiles for random wandering
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

var tile_map: TileMap
var astar: AStarGrid2D
var current_id_path: Array[Vector2i] = []
var last_direction: Vector2 = Vector2.DOWN
var is_near_npc: bool = false

func _ready() -> void:
	# --- TileMap + AStar Setup ---
	if get_tree().current_scene.has_node("TileMap"):
		tile_map = get_tree().current_scene.get_node("TileMap")
		if "AstarGrid" in tile_map:
			astar = tile_map.AstarGrid
		else:
			push_error("NPC: AstarGrid not found in TileMap!")
	else:
		push_error("NPC: TileMap not found in scene!")

	# --- Timer for random wandering ---
	timer.wait_time = randf_range(2.0, 4.0)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

	# --- Dialogue connections ---
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_dialogic_ended)
	

	# --- Check quest or location at scene start ---
	if has_node("/root/QuestManager"):
		QuestManager.check_location_completion()


func _physics_process(_delta: float) -> void:
	if astar == null: return

	if current_id_path.is_empty():
		play_idle_animation()
		velocity = Vector2.ZERO
		move_and_slide()
		return

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
	play_walk_animation(direction)


# --- Random wandering ---
func _on_timer_timeout() -> void:
	find_random_path()
	timer.wait_time = randf_range(1.0, 4.0)
	timer.start()


func find_random_path() -> void:
	if astar == null: return

	var start_point: Vector2i = tile_map.local_to_map(global_position)
	var random_dir = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].pick_random()
	var distance = randi_range(2, wander_radius)
	var end_point: Vector2i = start_point + (random_dir * distance)

	end_point.x = clamp(end_point.x, astar.region.position.x, astar.region.end.x - 1)
	end_point.y = clamp(end_point.y, astar.region.position.y, astar.region.end.y - 1)

	current_id_path = astar.get_id_path(start_point, end_point)
	if current_id_path.size() > 0:
		current_id_path.remove_at(0)


# --- Animation helpers ---
func play_walk_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		sprite.play("carry_walk_side_right" if dir.x > 0 else "carry_walk_side_left")
	else:
		sprite.play("carry_walk_down" if dir.y > 0 else "carry_walk_up")


func play_idle_animation() -> void:
	if abs(last_direction.x) > abs(last_direction.y):
		sprite.play("carry_idle_right" if last_direction.x > 0 else "carry_idle_left")
	else:
		sprite.play("carry_idle_down" if last_direction.y > 0 else "carry_idle_up")


# --- Player interaction ---
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_near_npc:
		if Dialogic.current_timeline == null:
			var player = get_tree().current_scene.find_child("youngrizal", true, false)
			if player:
				player.set_physics_process(false)

			# Pause NPC movement
			timer.stop()
			velocity = Vector2.ZERO
			move_and_slide()

			# Start Teodora dialogue only if in living room scene
			if get_tree().current_scene.scene_file_path == "res://levels/prelim/1/livingroomrizal.tscn":
				start_teodora_dialogue()
			else:
				print("Nasa maling scene ka para sa dialogue na ito.")


func start_teodora_dialogue() -> void:
	# Check kung tapos na ba talaga ang unang usapan
	var done_talking = Dialogic.VAR.francisco.aftertalkteodora
	
	if done_talking:
		# Mag-start ng ibang timeline na nagsasabing "Puntahan mo na ang iyong ama."
		Dialogic.start("remind_rizal_talk_francisco")
	else:
		# Ito yung main dialogue (rizalteodoratalk1)
		Dialogic.start("rizalteodoratalk1")
	
	if not Dialogic.timeline_ended.is_connected(_on_dialogue_finished):
		Dialogic.timeline_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)


# --- Dialogic Signals ---

func _on_dialogic_signal(argument: String) -> void:
	if argument == "minipuzzle":
		# Search the current scene for the 'Game' UI node
		var puzzle_ui = get_tree().current_scene.find_child("Game", true, false)
		
		if puzzle_ui:
			# Freeze the world
			var player = get_tree().current_scene.find_child("youngrizal", true, false)
			if player:
				player.set_physics_process(false)
			
			timer.stop()
			velocity = Vector2.ZERO
			
			# Show the puzzle
			puzzle_ui.visible = true
			
			# Find and show the Startoverlay
			var overlay = puzzle_ui.find_child("Startoverlay", true, false)
			if overlay:
				overlay.visible = true
			
			# Find the Board to trigger the game
			var board_node = puzzle_ui.find_child("Board", true, false)
			if board_node:
				board_node._on_Tile_pressed(-1) 


func _on_dialogue_finished() -> void:
	var player = get_tree().current_scene.find_child("youngrizal", true, false)
	if player:
		player.set_physics_process(true)
	timer.start()

	QuestManager.update_quest("The Beginning in Calamba", "Talk to Teodora Alonso")

	Dialogic.VAR.francisco.aftertalkteodora = true
	


func _on_dialogic_ended() -> void:
	
	var player = get_tree().current_scene.find_child("youngrizal", true, false)
	if player:
		player.set_physics_process(true)


# --- Detection Area ---
func _on_chatdetection_body_entered(body: Node2D) -> void:
	if body is Player:
		is_near_npc = true
		print("Player near Teodora: Press 'interact' to chat")


func _on_chatdetection_body_exited(body: Node2D) -> void:
	if body is Player:
		is_near_npc = false
		print("Player left the area")
