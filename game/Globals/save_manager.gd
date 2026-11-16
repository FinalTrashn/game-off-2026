extends Node

const SAVE_PATH := "user://save.json"

@export var auto_save := true

@onready var sound_bus_id = AudioServer.get_bus_index("Sounds")
@onready var music_bus_id = AudioServer.get_bus_index("Music")
@onready var master_bus_id = AudioServer.get_bus_index("Master")

var _data: Dictionary = {}

func _ready() -> void:
	load_data()
	_setSoundAtBeginning()

func set_value(key: String, value: String) -> void:
	_data[key] = value
	if auto_save:
		save_data()

func get_value(key: String, default: String = "") -> String:
	return str(_data.get(key, default))

func has_key(key: String) -> bool:
	return _data.has(key)

func delete_key(key: String) -> void:
	if _data.erase(key) and auto_save:
		save_data()

func clear_all() -> void:
	_data.clear()
	save_data()

func save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: could not open %s for writing (error %d)" % [SAVE_PATH, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(_data, "\t"))

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: could not open %s for reading (error %d)" % [SAVE_PATH, FileAccess.get_open_error()])
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_data = parsed
	else:
		push_warning("SaveManager: save file was invalid, starting fresh.")
		_data = {}

func _setSoundAtBeginning():
	var old_sound_vol = SaveManager.get_value("sound-volume")
	var old_music_vol = SaveManager.get_value("music-volume")
	var old_master_vol = SaveManager.get_value("master-volume")
	
	##setting saved volume to bus
	if old_sound_vol:
		AudioServer.set_bus_volume_db(sound_bus_id, linear_to_db(float(old_sound_vol))+10)
	if old_music_vol:
		AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(float(old_music_vol))+10)
	if old_master_vol:
		AudioServer.set_bus_volume_db(master_bus_id, linear_to_db(float(old_master_vol))+10)
	
