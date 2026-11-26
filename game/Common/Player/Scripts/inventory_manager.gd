extends Node

var primary_item = ""
var secondary_item = ""

const item = preload("res://Common/Item/Scenes/item.tscn")
@onready var item_ui = $"../../CanvasLayer/Ui/Items"

func hold_item_prim(name: String):
	if primary_item != "":
		if secondary_item == "":
			secondary_item = primary_item
		else:
			_drop_item(secondary_item)
			_swap_items()
		
	primary_item = name
	
	item_ui.update_items()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("drop_item"):
		if primary_item != "":
			_drop_item(primary_item)
			primary_item = ""
			item_ui.update_items()
	elif Input.is_action_just_pressed("rotate_items"):
		_swap_items()

func _drop_item(name:String):
	var new_item = item.instantiate()
	new_item.set_item_name(name)
	new_item.global_position.x = $"../..".global_position.x
	
	get_tree().current_scene.get_node("Items").add_child(new_item)
	item_ui.update_items()

func _swap_items():
	var old_prim = primary_item
	primary_item = secondary_item
	secondary_item = old_prim
	item_ui.update_items()

func del_prim_item():
	primary_item = ""
	item_ui.update_items()
