extends CanvasLayer

@onready var button_resume: Button = $VBoxContainer/resumebutton
@onready var button_exit: Button = $VBoxContainer/exitbutton

# List of scenes where the pause menu is forbidden
const NON_PAUSEABLE_SCENES = [
	"res://GUI/mainmenu/levels.tscn",
	"res://GUI/mainmenu/main_menu.tscn"
]

var is_paused: bool = false

func _ready() -> void:
	hide_pause_menu()
	
	button_resume.pressed.connect(_on_resume_pressed)
	button_exit.pressed.connect(_on_exit_pressed)
	
	# Ensures this node processes even when the tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		# Check if the current scene is in our restricted list
		var current_path = get_tree().current_scene.scene_file_path
		if current_path in NON_PAUSEABLE_SCENES:
			return # Exit the function; do nothing
		
		# If we aren't in a restricted scene, toggle the menu
		if not is_paused:
			show_pause_menu()
		else:
			hide_pause_menu()
			
		get_viewport().set_input_as_handled()

func show_pause_menu() -> void:
	print("Menu Opened") 
	is_paused = true
	get_tree().paused = true
	visible = true
	button_resume.grab_focus() 
	
func hide_pause_menu() -> void:
	print("Menu Closed") 
	is_paused = false
	get_tree().paused = false
	visible = false

func _on_resume_pressed() -> void:
	hide_pause_menu()

func _on_exit_pressed() -> void:
	# Unpause the game before switching scenes to avoid issues
	hide_pause_menu()
	
	var error = get_tree().change_scene_to_file("res://GUI/mainmenu/levels.tscn")
	
	if error != OK:
		print("Error: Could not find the scene path!")
	
