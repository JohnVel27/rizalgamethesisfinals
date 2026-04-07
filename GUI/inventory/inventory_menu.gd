extends CanvasLayer

signal open
signal close

var is_open: bool = false

@onready var Icon := get_node_or_null("Control/ItemsInfo/VBoxContainer/Icon")
@onready var ItemName := get_node_or_null("Control/ItemsInfo/VBoxContainer/ItemName")
@onready var ItemDescription := get_node_or_null("Control/ItemsInfo/VBoxContainer/ScrollContainer/Itemdescription")

func _ready() -> void:
	hide()
	is_open = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	
	update_itemInfo(null)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):

		var scene_path = get_tree().current_scene.scene_file_path

		if scene_path == "res://GUI/mainmenu/main_menu.tscn" \
		or scene_path == "res://GUI/mainmenu/levels.tscn":
			return

		if is_open:
			close_inventory()
		else:
			open_inventory()

		get_viewport().set_input_as_handled()

func open_inventory() -> void:
	is_open = true
	show()
	get_tree().paused = true
	open.emit()

func close_inventory() -> void:
	is_open = false
	hide()
	get_tree().paused = false
	close.emit()

func update_itemInfo(item_data: ItemData) -> void:
	if item_data == null:
		Icon.texture = null
		ItemName.text = ""
		ItemDescription.text = ""
		return

	Icon.texture = item_data.texture
	ItemName.text = item_data.name
	ItemDescription.text = item_data.description
