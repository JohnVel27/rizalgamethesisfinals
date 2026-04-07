extends CharacterBody2D

@export var speed: float = 200.0
@export var stopping_distance: float = 30.0 

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var young_rizal = $"../classmate1"
@onready var walk_sfx: AudioStreamPlayer = $walk_sfx

var tile_map: TileMap
var astar: AStarGrid2D
var current_id_path: Array[Vector2i] = []
var last_direction: Vector2 = Vector2.DOWN

var is_dialogue_active: bool = false
var last_timeline_played: String = "" 




func _ready() -> void:
	# 1. Hanapin ang TileMap at AstarGrid
	if get_tree().current_scene.has_node("TileMap"):
		tile_map = get_tree().current_scene.get_node("TileMap")
		if "AstarGrid" in tile_map:
			astar = tile_map.AstarGrid
		else:
			push_error("NPC: AstarGrid not found in TileMap!")
	else:
		push_error("NPC: TileMap not found in scene!")

	# 2. I-connect ang signals mula sa Dialogic
	Dialogic.timeline_started.connect(_on_dialogue_started)
	Dialogic.timeline_ended.connect(_on_dialogue_finished)

func _physics_process(_delta: float) -> void:
	if astar == null: return

	# 3. STOPPING CONDITION: Hihinto habang may dialogue
	if is_dialogue_active:
		play_idle_animation()
		velocity = Vector2.ZERO
		move_and_slide()
		return 

	# 4. PATHFINDING LOGIC: Lakad papunta sa target (classmate1)
	if young_rizal:
		var dist = global_position.distance_to(young_rizal.global_position)
		if dist > stopping_distance:
			find_path_to_target(young_rizal.global_position)
		else:
			current_id_path = [] 

	# 5. MOVEMENT EXECUTION
	if current_id_path.is_empty():
		play_idle_animation()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var target_position: Vector2 = tile_map.map_to_local(current_id_path[0])
	
	# Kung malapit na sa target tile, lipat sa susunod na tile sa path
	if global_position.distance_to(target_position) < 4:
		current_id_path.pop_front()
		return

	move_to_target(target_position)

func move_to_target(target: Vector2) -> void:
	var direction: Vector2 = (target - global_position).normalized()
	last_direction = direction
	velocity = direction * speed
	move_and_slide()
	
	play_walk_animation(direction)
	
	
	if not walk_sfx.playing:
		walk_sfx.play()

func find_path_to_target(target_pos: Vector2) -> void:
	var start_point = tile_map.local_to_map(global_position)
	var end_point = tile_map.local_to_map(target_pos)
	
	# Siguraduhin na nasa loob ng grid ang end point
	end_point.x = clamp(end_point.x, astar.region.position.x, astar.region.end.x - 1)
	end_point.y = clamp(end_point.y, astar.region.position.y, astar.region.end.y - 1)
	
	var new_path = astar.get_id_path(start_point, end_point)
	if new_path.size() > 0:
		new_path.remove_at(0)
		current_id_path = new_path

# --- ANIMATIONS ---

func play_walk_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		sprite.play("carry_walk_side_right" if dir.x > 0 else "carry_walk_side_left")
	else:
		sprite.play("carry_walk_down" if dir.y > 0 else "carry_walk_up")

func play_idle_animation() -> void:
	if walk_sfx.playing:
		walk_sfx.stop()
		
	if abs(last_direction.x) > abs(last_direction.y):
		sprite.play("carry_idle_right" if last_direction.x > 0 else "carry_idle_left")
	else:
		sprite.play("carry_idle_down" if last_direction.y > 0 else "carry_idle_up")

# --- DIALOGIC SIGNALS & TRANSITION ---

func _on_dialogue_started() -> void:
	is_dialogue_active = true
	velocity = Vector2.ZERO 

func _on_dialogue_finished() -> void:
	is_dialogue_active = false
	
	QuestManager.update_quest("Bullies at the school", "Talk to your classmate and confront their grievances towards you", true)
	
	# I-check kung ang huling tinakbong dialogue ay ang brawl scene
	if last_timeline_played == "firstbrawl2":
		start_smooth_transition()

func start_smooth_transition() -> void:
	var tree = get_tree()
	var target_scene = "res://levels/prelim/2/juanchocarrera.tscn"
	
	# Re-enable player physics kung sakaling naka-disable
	var player = tree.current_scene.find_child("youngrizal", true, false)
	if player:
		player.set_physics_process(true)

	if has_node("/root/Transitionlayer"):
		Transitionlayer.transition()
		await Transitionlayer.on_transition_finished
		tree.change_scene_to_file(target_scene)
	else:
		tree.change_scene_to_file(target_scene)

func _on_chatdetectionjustiano_body_entered(body: Node2D) -> void:
	# Mag-trigger lang kung si classmate1 ang pumasok at wala pang active dialogue
	if body == young_rizal and not is_dialogue_active:
		last_timeline_played = "firstbrawl2" # I-record ang pangalan bago i-start
		Dialogic.start("firstbrawl2")
		
