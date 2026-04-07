class_name QuestsUI extends CanvasLayer

signal open
signal close

const QUEST_ITEM : PackedScene = preload("res://GUI/quest/questitem.tscn")
const QUEST_STEP_ITEM : PackedScene = preload("res://GUI/quest/queststepitem.tscn")



@onready var quest_item_container: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer
@onready var details_container: VBoxContainer = $VBoxContainer
@onready var title_label: Label = $VBoxContainer/titlelabel
@onready var description_label: Label = $VBoxContainer/descriptionlabel

var is_open: bool = false

func _ready() -> void:
	hide()
	is_open = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	clear_quest_details()
	visibility_changed.connect( _on_visible_changed )
	

func _on_visible_changed() -> void:
	for i in quest_item_container.get_children():
		i.queue_free()
		
		
	if visible == true:
		
		
		for q in QuestManager.current_quests:
			var quest_data : Quest = QuestManager.find_quest_by_title( q.title )
			if quest_data == null:
				continue
			var new_q_item : QuestItem = QUEST_ITEM.instantiate()
			quest_item_container.add_child( new_q_item )
			new_q_item.intialize( quest_data,q)
			new_q_item.focus_entered.connect( update_quest_details.bind( new_q_item.quest ) )
	
	pass
	

func update_quest_details( q : Quest ) -> void:
	clear_quest_details()
	
	title_label.text = q.title
	description_label.text = q.description
	
	# Find the saved data for this specific quest
	var quest_save = QuestManager.find_quest( q )
	
	for step in q.steps:
		var new_step : QuestStepItem = QUEST_STEP_ITEM.instantiate()
		details_container.add_child( new_step ) # Add to container first
		
		var step_is_complete : bool = false
		
		# Check if the quest exists in current_quests
		if quest_save.title != "not found":
			# Use to_lower() to match the QuestManager logic
			step_is_complete = quest_save.completed_steps.has( step.to_lower() )
		
		# Pass the data to the UI item
		new_step.initialize( step, step_is_complete )
	
func clear_quest_details() -> void:
	title_label.text = ""
	description_label.text = ""
	for c in details_container.get_children():
		if c is QuestStepItem:
			c.queue_free()
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quest"):
		
		var scene_path = get_tree().current_scene.scene_file_path

		if scene_path == "res://GUI/mainmenu/main_menu.tscn" \
		or scene_path == "res://GUI/mainmenu/levels.tscn":
			return

		if is_open:
			close_quest()
		else:
			open_quest()

		get_viewport().set_input_as_handled()
		
		
func open_quest() -> void:
	is_open = true
	show()
	get_tree().paused = true
	open.emit()
	
func close_quest() -> void:
	is_open = false
	hide()
	get_tree().paused = false
	close.emit()
	
