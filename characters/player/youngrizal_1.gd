extends CharacterBody2D



var is_dialogue_active: bool = false

func _ready() -> void:
	# I-connect ang signals ng Dialogic para malaman kung kailan hihinto at gagana uli
	Dialogic.timeline_started.connect(_on_dialogue_started)
	Dialogic.timeline_ended.connect(_on_dialogue_finished)

	var scene_path = get_tree().current_scene.scene_file_path
	if scene_path.ends_with("maestroschool2.tscn"):
		start_opening_dialogue("foughtback")

func _physics_process(_delta: float) -> void:
	# 1. STOPPING CONDITION: Kung may dialogue, huwag gawin ang movement logic
	if is_dialogue_active:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	

func start_opening_dialogue(timeline_name: String) -> void:
	if Dialogic.current_timeline != null:
		return
	Dialogic.start(timeline_name)

# --- SIGNAL CALLBACKS ---

func _on_dialogue_started() -> void:
	is_dialogue_active = true
	

func _on_dialogue_finished() -> void:
	is_dialogue_active = false
	
