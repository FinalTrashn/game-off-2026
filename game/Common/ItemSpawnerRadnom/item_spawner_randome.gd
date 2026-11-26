extends Node3D

const item = preload("res://Common/Item/Scenes/item.tscn")

@export var blocked_items: Array[String] = []

var has_item := false
var _i_name = ""

func allows_item(item_name: String) -> bool:
	return not blocked_items.has(item_name)

func spawn_item(item_name: String) -> void:
	_i_name = item_name
	if has_item:
		OS.crash("Spawner %s was given a second item" % name)
		return
	if not allows_item(item_name):
		OS.crash("Spawner %s is blocked from holding %s" % [name, item_name])
		return
	has_item = true

	print(_i_name, " spawn in ", get_parent().name)

	var new_item = item.instantiate()
	new_item.set_item_name(item_name)

	get_tree().current_scene.get_node("Items").add_child(new_item)
	new_item.global_position.x = global_position.x
