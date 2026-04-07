extends CharacterBody2D

# This function runs automatically on startup
func _ready():
	$AnimatedSprite2D.play("animated")
