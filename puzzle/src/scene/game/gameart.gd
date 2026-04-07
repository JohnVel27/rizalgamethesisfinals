extends CanvasLayer

# References to your nodes based on your scene tree
@onready var board = $MarginContainer/VBoxContainer/GameView/Boardart
@onready var overlay = $MarginContainer/VBoxContainer/GameView/Startoverlay

func _ready():
	# Ensure the overlay is visible at the start
	overlay.visible = true
	
	# Connect the Board's signals if you want to update UI later
	board.game_won.connect(_on_game_won)

func _input(event):
	# Check if the player clicks while the overlay is still active
	if event is InputEventMouseButton and event.pressed and overlay.visible:
		_start_game()

func _start_game():
	# 1. Hide the overlay so you can click the puzzle tiles
	overlay.visible = false
	
	# 2. Tell the board to scramble and begin
	# Passing -1 or a dummy value triggers your scramble logic
	board._on_Tile_pressed(-1) 

func _on_game_won():
	# Optional: Show a message or the overlay again when they win
	print("Puzzle Solved!")
