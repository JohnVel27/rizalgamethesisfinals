extends Node

signal level_load_started
signal level_loaded
signal tilemap_bounds_changed( bounds : Array[ Vector2 ] )

var current_tilemap_bounds : Array[ Vector2 ]
var target_transition : String
var position_offset : Vector2

func change_tilemap_bounds( bounds : Array[ Vector2 ] ) -> void:
	current_tilemap_bounds = bounds
	tilemap_bounds_changed.emit( bounds )


func load_new_level(
		level_path: String,
		_target_transition: String,
		_position_offset: Vector2
) -> void:

	target_transition = _target_transition
	position_offset = _position_offset

	# start fade
	Transitionlayer.transition()

	print("waiting for fade...")

	# wait until fully black
	await Transitionlayer.on_transition_finished

	print("fade finished -> changing scene")

	level_load_started.emit()

	await get_tree().process_frame

	get_tree().change_scene_to_file(level_path)

	await get_tree().process_frame

	level_loaded.emit()
