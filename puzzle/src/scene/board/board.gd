extends Control

@export var board_size: int = 4
@export var tile_size: int = 60
@export var tile_scene: PackedScene
@export var slide_duration: float = 0.15

var board = []
var tiles = []
var empty = Vector2()
var is_animating = false
var tiles_animating = 0

var move_count = 0
var number_visible = true
var background_texture = null

# Linked to the TextureRect in your scene tree
var win_image: TextureRect


enum GAME_STATES {
	NOT_STARTED,
	STARTED,
	WON
}

var game_state = GAME_STATES.NOT_STARTED

signal game_started
signal game_won
signal moves_updated(count)

func _ready():
	# Use native Control size property
	tile_size = floor(size.x / board_size)
	size = Vector2(tile_size * board_size, tile_size * board_size)

	# Fetch the TextureRect from your scene tree
	win_image = $TextureRect
	win_image.visible = false
	win_image.z_index = 100 
	
	gen_board()

func gen_board():
	var value = 1
	board = []
	tiles = []

	for r in range(board_size):
		board.append([])
		for c in range(board_size):
			if value == board_size * board_size:
				board[r].append(0)
				empty = Vector2(c, r)
			else:
				board[r].append(value)
				var tile = tile_scene.instantiate()
				tile.position = Vector2(c * tile_size, r * tile_size)
				tile.set_text(value)

				if background_texture:
					tile.set_sprite_texture(background_texture)

				tile.set_sprite(value - 1, board_size, tile_size)
				tile.set_number_visible(number_visible)

				tile.tile_pressed.connect(_on_Tile_pressed)
				tile.slide_completed.connect(_on_Tile_slide_completed)

				add_child(tile)
				tiles.append(tile)
			value += 1

func _on_Tile_pressed(number):
	if is_animating or game_state == GAME_STATES.WON:
		return

	if game_state == GAME_STATES.NOT_STARTED:
		scramble_board()
		game_state = GAME_STATES.STARTED
		game_started.emit()
		return

	var tile = value_to_grid(number)
	if tile == null: return
	
	empty = value_to_grid(0)

	if tile.x != empty.x and tile.y != empty.y:
		return

	var dir = Vector2(sign(tile.x - empty.x), sign(tile.y - empty.y))
	var start = Vector2(min(tile.x, empty.x), min(tile.y, empty.y))
	var end = Vector2(max(tile.x, empty.x), max(tile.y, empty.y))

	for r in range(end.y, start.y - 1, -1):
		for c in range(end.x, start.x - 1, -1):
			if board[r][c] == 0:
				continue

			var object = get_tile_by_value(board[r][c])
			object.slide_to((Vector2(c, r) - dir) * tile_size, slide_duration)
			is_animating = true
			tiles_animating += 1

	# Logic for sliding rows/columns
	if tile.y == empty.y:
		if dir.x == -1:
			board[tile.y] = slide_row(board[tile.y], 1, start.x)
		else:
			board[tile.y] = slide_row(board[tile.y], -1, end.x)

	if tile.x == empty.x:
		var col = []
		for r in range(board_size):
			col.append(board[r][tile.x])
		if dir.y == -1:
			col = slide_column(col, 1, start.y)
		else:
			col = slide_column(col, -1, end.y)
		for r in range(board_size):
			board[r][tile.x] = col[r]

	move_count += 1
	moves_updated.emit(move_count)

	# WIN CONDITION: Trigger the TextureRect immediately
	if is_board_solved():
		game_state = GAME_STATES.WON
		show_completed_picture() 
		game_won.emit()

func show_completed_picture():
	
	win_image.visible = true
	
	
	for tile in tiles:
		tile.visible = false

	await get_tree().create_timer(3.0).timeout
	
	var puzzle_root = get_node("../../../..") 
	
	
	if puzzle_root:
		
		puzzle_root.queue_free() 

	var player = get_tree().current_scene.find_child("youngrizal", true, false)
	if player:
		player.set_physics_process(true)

func is_board_solved():
	var count = 1
	for r in range(board_size):
		for c in range(board_size):
			if count == board_size * board_size:
				return board[r][c] == 0
			if board[r][c] != count:
				return false
			count += 1
	return true

# --- SLIDE HELPER FUNCTIONS ---
func slide_row(row, dir, limiter):
	var empty_index = row.find(0)
	if dir == 1:
		var start = row.slice(0, limiter)
		var mid = row.slice(limiter, empty_index)
		var end = row.slice(empty_index + 1)
		return start + [0] + mid + end
	else:
		var start = row.slice(0, empty_index)
		var mid = row.slice(empty_index + 1, limiter + 1)
		var end = row.slice(limiter + 1)
		return start + mid + [0] + end

func slide_column(col, dir, limiter):
	var empty_index = col.find(0)
	if dir == 1:
		var start = col.slice(0, limiter)
		var mid = col.slice(limiter, empty_index)
		var end = col.slice(empty_index + 1)
		return start + [0] + mid + end
	else:
		var start = col.slice(0, empty_index)
		var mid = col.slice(empty_index + 1, limiter + 1)
		var end = col.slice(limiter + 1)
		return start + mid + [0] + end

func value_to_grid(value):
	for r in range(board_size):
		for c in range(board_size):
			if board[r][c] == value:
				return Vector2(c, r)
	return null

func get_tile_by_value(value):
	for tile in tiles:
		if tile.number == value:
			return tile
	return null

func _on_Tile_slide_completed(_number):
	tiles_animating -= 1
	if tiles_animating <= 0:
		is_animating = false
		tiles_animating = 0

func scramble_board():
	reset_board()
	var temp_flat_board = []
	for i in range(board_size * board_size - 1, -1, -1):
		temp_flat_board.append(i)
	temp_flat_board.shuffle()
	while not is_board_solvable(temp_flat_board):
		temp_flat_board.shuffle()
	for r in range(board_size):
		for c in range(board_size):
			board[r][c] = temp_flat_board[r * board_size + c]
			if board[r][c] != 0:
				set_tile_position(r, c, board[r][c])
	empty = value_to_grid(0)

func reset_board():
	move_count = 0
	moves_updated.emit(move_count)
	board = []
	for r in range(board_size):
		board.append([])
		for c in range(board_size):
			board[r].append(r * board_size + c + 1)
			if r * board_size + c + 1 == board_size * board_size:
				board[r][c] = 0
			else:
				set_tile_position(r, c, board[r][c])
	empty = value_to_grid(0)

func set_tile_position(r, c, val):
	var object = get_tile_by_value(val)
	if object:
		object.position = Vector2(c, r) * tile_size

func is_board_solvable(flat):
	var parity = 0
	var grid_width = board_size
	var row = 0
	var blank_row = 0
	for i in range(board_size * board_size):
		if i % grid_width == 0: row += 1
		if flat[i] == 0:
			blank_row = row
			continue
		for j in range(i + 1, board_size * board_size):
			if flat[i] > flat[j] and flat[j] != 0: parity += 1
	if grid_width % 2 == 0:
		if blank_row % 2 == 0: return parity % 2 == 0
		else: return parity % 2 != 0
	else: return parity % 2 == 0
