extends CanvasLayer

@onready var intro_label = $calambaintroduction
@export var typing_speed: float = 5.0  
@export var delay_before_exit: float = 3.0 

func _ready() -> void:
	
	intro_label.visible_ratio = 0.0
	animate_text()

func animate_text() -> void:
	
	var tween = create_tween()
	
	
	tween.tween_property(intro_label, "visible_ratio", 1.0, typing_speed) \
		 .set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	await get_tree().create_timer(delay_before_exit).timeout
	
	start_transition()

func start_transition() -> void:
	Transitionlayer.transition()
	await Transitionlayer.on_transition_finished
	get_tree().change_scene_to_file("res://levels/prelim/1/rizalhome.tscn")
