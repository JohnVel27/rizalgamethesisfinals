extends TileMap

var AstarGrid: AStarGrid2D

func _ready() -> void:
	
	LevelManager.change_tilemap_bounds(_get_tilemap_bounds())
	# Initialize the navigation grid
	assigning_astar()

func assigning_astar() -> void:
	
	var wall_layer = $walls 
	
	
	var used_rect = get_used_rect()
	
	AstarGrid = AStarGrid2D.new()
	AstarGrid.region = used_rect
	AstarGrid.cell_size = tile_set.tile_size
	AstarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AstarGrid.update()
	
	# Loop through every possible tile coordinate in your map
	for x in range(used_rect.size.x):
		for y in range(used_rect.size.y):
			var tile_position = Vector2i(x + used_rect.position.x, y + used_rect.position.y)
			
			# 1. Check if there is a tile in the 'walls' layer at this position
			var wall_tile_data = wall_layer.get_cell_tile_data(tile_position)
			
			# 2. Check the base TileMap (Layer 0) for non-walkable data as well
			var base_tile_data = get_cell_tile_data(0, tile_position)
			
			# Determine if the spot should be solid
			var is_solid = false
			
			# If the 'walls' layer has a tile here, we mark it solid
			if wall_tile_data != null:
				is_solid = true
			
			# Additionally check Custom Data "Walkable" if it exists on the base layer
			if base_tile_data != null and base_tile_data.get_custom_data("Walkable") == false:
				is_solid = true
				
			if is_solid:
				AstarGrid.set_point_solid(tile_position)

func _get_tilemap_bounds() -> Array[Vector2]:
	var bounds: Array[Vector2] = []
	# Use tile_set.tile_size (e.g., 32 or 16) for accurate pixel bounds
	var cell_size = tile_set.tile_size
	
	bounds.append(
		Vector2(get_used_rect().position * cell_size)
	)
	bounds.append(
		Vector2(get_used_rect().end * cell_size)
	)
	return bounds
