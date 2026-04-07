extends Button

class_name InventorySlotUI

var slot_data: SlotData : set = set_slot_data

@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	texture_rect.texture = null
	focus_entered.connect(item_focused)
	focus_exited.connect(item_unfocused)

func set_slot_data(value: SlotData) -> void:
	slot_data = value

	if slot_data == null or slot_data.item_data == null:
		texture_rect.texture = null
		return

	texture_rect.texture = slot_data.item_data.texture

func item_focused() -> void:
	if slot_data != null and slot_data.item_data != null:
		InventoryMenu.update_itemInfo(slot_data.item_data)

func item_unfocused() -> void:
	InventoryMenu.update_itemInfo(null)
