extends CharacterBody2D

@export var speed: float = 80.0
@export var wander_radius: int = 10 # Ilang tiles ang layo ng random lakad
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Kakailanganin mo ng Timer node na child ng NPC
@onready var timer: Timer = $Timer 

var tile_map: TileMap
var astar: AStarGrid2D
var current_id_path: Array[Vector2i] = []
var last_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	# 1. Hanapin ang TileMap (dapat may node ka na "TileMap" sa scene)
	if get_tree().current_scene.has_node("TileMap"):
		tile_map = get_tree().current_scene.get_node("TileMap")
		# Kunin ang AStarGrid mula sa TileMap script mo
		if "AstarGrid" in tile_map:
			astar = tile_map.AstarGrid
		else:
			push_error("NPC: AstarGrid not found in TileMap!")
	else:
		push_error("NPC: TileMap not found in scene!")

	# 2. Setup ang Timer para sa pag-wander
	timer.wait_time = randf_range(2.0, 4.0) # Random na oras bago lumipat ng pwesto
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _physics_process(_delta: float) -> void:
	if astar == null: return

	# Kung walang path, idle lang
	if current_id_path.is_empty():
		play_idle_animation()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Target center ng kasalukuyang tile sa path
	var target_position: Vector2 = tile_map.map_to_local(current_id_path[0])

	# Kung malapit na sa target tile, lipat sa susunod na tile sa path
	if global_position.distance_to(target_position) < 2:
		current_id_path.pop_front()
		return

	# Gumalaw patungo sa target
	move_to_target(target_position)

func move_to_target(target: Vector2) -> void:
	var direction: Vector2 = (target - global_position).normalized()
	last_direction = direction
	velocity = direction * speed
	move_and_slide()
	play_walk_animation(direction)

# --- RANDOM WANDERING LOGIC ---
func _on_timer_timeout() -> void:
	# Maghanap ng bagong random na pwesto
	find_random_path()
	# I-reset ang timer para sa susunod na paglakad
	timer.wait_time = randf_range(1.0, 4.0)
	timer.start()

func find_random_path() -> void:
	if astar == null: return

	var start_point: Vector2i = tile_map.local_to_map(global_position)
	
	# Random na direksyon (Up, Down, Left, Right)
	var random_dir = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].pick_random()
	# Random na layo
	var distance = randi_range(2, wander_radius)
	
	var end_point: Vector2i = start_point + (random_dir * distance)
	
	# I-clamp ang end point para hindi lumabas sa mapa
	end_point.x = clamp(end_point.x, astar.region.position.x, astar.region.end.x - 1)
	end_point.y = clamp(end_point.y, astar.region.position.y, astar.region.end.y - 1)
	
	# Kalkulahin ang path
	current_id_path = astar.get_id_path(start_point, end_point)
	
	# Tanggalin ang unang tile (kasalukuyang pwesto)
	if current_id_path.size() > 0:
		current_id_path.remove_at(0)

# --- ANIMATIONS (Gaya ng sa Player mo) ---
func play_walk_animation(dir: Vector2) -> void:
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


func play_idle_animation() -> void:
	if abs(last_direction.x) > abs(last_direction.y):
		if last_direction.x > 0:
			sprite.play("carry_idle_right")
		else:
			sprite.play("carry_idle_left")
	else:
		if last_direction.y > 0:
			sprite.play("carry_idle_down")
		else:
			sprite.play("carry_idle_up")
