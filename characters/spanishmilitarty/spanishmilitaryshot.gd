extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

var is_shooting = false

func _ready():
	_animated_sprite.play("standby")
	
	
	Dialogic.timeline_ended.connect(_on_dialogue_finished)
	_animated_sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	

	Dialogic.start("shot")

func shoot():
	is_shooting = true
	_animated_sprite.play("shot")

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
		
		if tree: # extra safety
			tree.change_scene_to_file("res://transitionstoryboard/finals/shot1.tscn")
	else:
		if tree:
			tree.change_scene_to_file("res://transitionstoryboard/finals/shot1.tscn")

# 🔥 Dialogue ends → ONLY shoot
func _on_dialogue_finished():
	shoot()
	QuestManager.update_quest("Mi Ultimo Adios", "Farewell", true)
	
