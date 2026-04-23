extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

# Flag to track if we are currently in the shooting state
var is_shooting = false

func _ready():
	# Start in standby
	_animated_sprite.play("standby")

func _process(_delta):
	# Trigger the shot
	if Input.is_action_just_pressed("ui_accept") and not is_shooting:
		shoot()

func shoot():
	is_shooting = true
	_animated_sprite.play("shot")

# Connect this by clicking the AnimatedSprite2D -> Node Tab -> animation_finished
func _on_animated_sprite_2d_animation_finished():
	if _animated_sprite.animation == "shot":
		is_shooting = false
		_animated_sprite.play("standby")
