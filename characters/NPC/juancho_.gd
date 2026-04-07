extends CharacterBody2D

func _ready() -> void:
	
	if has_node("/root/QuestManager"):
		QuestManager.check_location_completion()
