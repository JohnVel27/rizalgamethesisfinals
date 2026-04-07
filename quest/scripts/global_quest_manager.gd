extends Node

signal quest_updated(q)

const QUEST_DATA_LOCATION: String = "res://quest/"

## Drag your .tres files here in the Inspector! (Safest for exports)
@export var quest_library: Array[Quest] = []

var quests: Array[Quest] = []
var current_quests: Array = []

var all_quests: Dictionary = {
	"prelim": [
		{ "title": "The Beginning in Calamba", "is_complete": false, "completed_steps": [] },
		{ "title": "Life at Biñan Laguna", "is_complete": false, "completed_steps": [] },
		{ "title": "Bullies at the school", "is_complete": false, "completed_steps": [] },
		{ "title": "Secondary Education at Ateneo", "is_complete": false, "completed_steps": [] },
		{ "title": "Third Education at University Of Santo Thomas", "is_complete": false, "completed_steps": [] }
	],
	"midterm": [],
	"final": []
}

func _ready() -> void:

	current_quests = all_quests["prelim"].duplicate(true)
	gather_quest_data()
	
	
	
func check_location_completion() -> void:
	var current_scene_path = get_tree().current_scene.scene_file_path
	
	# Check if player is in the Rizal Living Room
	if current_scene_path == "res://levels/prelim/1/livingroomrizal.tscn":
		update_quest("The Beginning in Calamba", "Travel to Rizal's house", false)
		print("Location reached: Rizal Home")
		
		
	if current_scene_path == "res://levels/prelim/2/juanchocarrera.tscn":
		update_quest("Life at Biñan Laguna", "Enter the nipa hut meet the maestro and enter his class", false)
		
	if current_scene_path == "res://levels/prelim/3/ahallway.tscn":
		update_quest("Secondary Education at Ateneo", "Enter Ateneo", true)
		
	if current_scene_path == "res://levels/prelim/4/uhallway.tscn":
		update_quest("Third Education at University Of Santo Thomas", "Enter UST", true)

func gather_quest_data() -> void:
	quests.clear()
	
	# 1. Use the exported library if you filled it (Most reliable)
	if quest_library.size() > 0:
		quests = quest_library
		print("QuestManager: Loaded from Inspector Library. Count: ", quests.size())
		return

	# 2. Fallback to DirAccess (handling exports via .remap check)
	if not DirAccess.dir_exists_absolute(QUEST_DATA_LOCATION):
		print("QuestManager Error: Folder not found: ", QUEST_DATA_LOCATION)
		return
		
	var dir = DirAccess.open(QUEST_DATA_LOCATION)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				# In export, files end in .remap; we strip that to load the base resource
				var clean_path = file_name.replace(".remap", "")
				
				if clean_path.ends_with(".tres") or clean_path.ends_with(".res"):
					var full_path = QUEST_DATA_LOCATION + clean_path
					var resource = load(full_path)
					if resource is Quest:
						quests.append(resource)
						print("QuestManager: Loaded via DirAccess: ", clean_path)
			
			file_name = dir.get_next()
		dir.list_dir_end()
	
	print("QuestManager: Total quests loaded: ", quests.size())

func update_quest(_title: String, _step: String = "", _complete: bool = false) -> void:
	var index = get_quest_index_by_title(_title)
	var sanitized_step = _step.strip_edges().to_lower()

	# If quest isn't in current_quests, add it
	if index == -1:
		var new_quest: Dictionary = {
			"title": _title,
			"is_complete": _complete,
			"completed_steps": []
		}
		if sanitized_step != "": 
			new_quest["completed_steps"].append(sanitized_step)
		
		current_quests.append(new_quest)
		if _complete: 
			_process_rewards(_title)
		
		quest_updated.emit(new_quest)
		return

	var q = current_quests[index]

	if sanitized_step != "" and not q["completed_steps"].has(sanitized_step):
		q["completed_steps"].append(sanitized_step)

	if _complete and not q["is_complete"]:
		q["is_complete"] = true
		_process_rewards(_title)
	
	quest_updated.emit(q)
	print("Quest Log Updated: ", _title, " | Complete: ", q["is_complete"])

func _process_rewards(_title: String) -> void:
	var quest_res = find_quest_by_title(_title)
	if quest_res:
		disperse_quest_rewards(quest_res)

func disperse_quest_rewards(_q: Quest) -> void:
	for reward in _q.reward_items:
		if reward and reward.item != null:
			if has_node("/root/PlayerManager"):
				# Ensure PlayerManager exists and has INVENTORY_DATA
				get_node("/root/PlayerManager").INVENTORY_DATA.add_item(reward.item, reward.quantity)
				print("Reward Received: ", reward.item.name)

func find_quest_by_title(_title: String) -> Quest:
	for q in quests:
		if q.title.to_lower() == _title.to_lower(): 
			return q
	return null

func get_quest_index_by_title(_title: String) -> int:
	for i in range(current_quests.size()):
		if current_quests[i]["title"].to_lower() == _title.to_lower(): 
			return i
	return -1

func find_quest(_quest: Quest) -> Dictionary:
	for q in current_quests:
		if q["title"].to_lower() == _quest.title.to_lower():
			return q
	return { "title": "not found", "is_complete": false, "completed_steps": [] }
	
func is_step_completed(_title: String, _step: String) -> bool:
	var index = get_quest_index_by_title(_title)
	
	if index == -1:
		return false
	
	var q = current_quests[index]
	var sanitized_step = _step.strip_edges().to_lower()
	
	return q["completed_steps"].has(sanitized_step)
	
