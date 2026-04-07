extends Node

# This is just the "blueprint"
const PLAYER_SCENE = preload("res://characters/player/youngrizal.tscn")
const INVENTORY_DATA : InventoryData = preload("res://GUI/inventory/player_inventory.tres")


# This will hold the actual player instance
var player



func set_as_parent( _p : Node2D ) -> void:
	# Safety check: if player isn't created yet, don't run
	if player == null:
		return
		
	if player.get_parent():
		player.get_parent().remove_child( player )
	
	_p.add_child( player )
