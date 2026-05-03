extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var shot_sound = $Shotsound # Reference to your AudioStreamPlayer node

var is_shooting = false

func _ready():
	_animated_sprite.play("standby")
	
	Dialogic.timeline_ended.connect(_on_dialogue_finished)
	_animated_sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	
	Dialogic.start("shot")

func shoot():
	is_shooting = true
	_animated_sprite.play("shot")
	shot_sound.play() # 🔥 This triggers the audio

func _on_animated_sprite_2d_animation_finished():
	if _animated_sprite.animation == "shot":
		is_shooting = false
		_animated_sprite.play("standby")
		
		start_smooth_transition()

func start_smooth_transition() -> void:
	var tree = get_tree() 
	
	if has_node("/root/Transitionlayer"):
		Transitionlayer.transition()
		await Transitionlayer.on_transition_finished
		
		if tree: 
			tree.change_scene_to_file("res://levels/finals/6/bagumbayandeath.tscn")
	else:
		if tree:
			tree.change_scene_to_file("res://levels/finals/6/bagumbayandeath.tscn")

# Dialogue ends → ONLY shoot
func _on_dialogue_finished():
	shoot()
	QuestManager.update_quest("Mi Ultimo Adios", "Farewell", true)
	
