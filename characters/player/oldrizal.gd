extends CharacterBody2D

@export var speed: float = 80.0
@export var wander_radius: int = 10 
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


@onready var timer: Timer = $Timer 

var tile_map: TileMap
var astar: AStarGrid2D
var current_id_path: Array[Vector2i] = []
var last_direction: Vector2 = Vector2.DOWN

var current_opening_dialogue := ""

func _ready() -> void:
	

	if has_node("/root/QuestManager"):
		QuestManager.check_location_completion()
		
		
	
	if get_tree().current_scene.has_node("TileMap"):
		tile_map = get_tree().current_scene.get_node("TileMap")
		
		if "AstarGrid" in tile_map:
			astar = tile_map.AstarGrid
		else:
			push_error("NPC: AstarGrid not found in TileMap!")
	else:
		push_error("NPC: TileMap not found in scene!")

	#
	timer.wait_time = randf_range(2.0, 4.0) 
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
	var scene_path = get_tree().current_scene.scene_file_path
	

	if not Dialogic.timeline_ended.is_connected(_on_dialogue_finished):
		Dialogic.timeline_ended.connect(_on_dialogue_finished)
	
	if scene_path.ends_with("ahallway.tscn"):
		start_opening_dialogue("3narrator2")
		
	elif scene_path.ends_with("res://levels/prelim/4/uhallway.tscn"):
		start_opening_dialogue("4narrato2")
		

func start_opening_dialogue(timeline_name: String) -> void:
	if Dialogic.current_timeline != null:
		return

	current_opening_dialogue = timeline_name
	Dialogic.start(timeline_name)
	
	
func _on_dialogue_finished() -> void:
	
	
	if current_opening_dialogue == "3narrator2":
		await start_smooth_transition("res://levels/prelim/4/ust.tscn")
		
	if current_opening_dialogue == "4narrato2":
		await start_smooth_transition("res://GUI/mainmenu/levels.tscn")
		
	current_opening_dialogue = ""
	
func start_smooth_transition(next_scene: String) -> void:
	
	# If you have a global Transitionlayer (Autoload)
	if has_node("/root/Transitionlayer"):
		Transitionlayer.transition()
		await Transitionlayer.on_transition_finished
	
	get_tree().change_scene_to_file(next_scene)

func _physics_process(_delta: float) -> void:
	if astar == null: return

	# Kung walang path, idle lang
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
