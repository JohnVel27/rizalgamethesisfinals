extends CanvasLayer

signal on_transition_finished

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func transition() -> void:
	print("🎬 Transition started")
	color_rect.visible = true
	animation_player.play("fade_to_black")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		print("⬛ Fade to black finished")
		on_transition_finished.emit()
		animation_player.play("fade_to_normal")

	elif anim_name == "fade_to_normal":
		color_rect.visible = false
		
func start_smooth_transition(next_scene: String) -> void:
	
	# If you have a global Transitionlayer (Autoload)
	if has_node("/root/Transitionlayer"):
		Transitionlayer.transition()
		await Transitionlayer.on_transition_finished
	
	get_tree().change_scene_to_file(next_scene)
