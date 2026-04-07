class_name InventoryUI extends Control

# Change this path to point to your SLOT scene, NOT the menu scene
const INVENTORY_SLOT = preload("res://GUI/inventory/inventory_slot.tscn")

@export var data : InventoryData

func _ready() -> void:
	
	InventoryMenu.open.connect(update_inventory)
	InventoryMenu.close.connect(clear_inventory)
	clear_inventory()

func clear_inventory() -> void:
	for c in get_children():
		
		remove_child(c)
		c.queue_free()

func update_inventory() -> void:
	clear_inventory()
	
	if not data or data.slots.is_empty():
		return

	var first_slot_node = null

	for s in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		
		
		new_slot.slot_data = s
		
		if first_slot_node == null:
			first_slot_node = new_slot

	if first_slot_node:
		first_slot_node.grab_focus()
