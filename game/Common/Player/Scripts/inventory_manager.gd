extends Node

var primary_item = ""
var secondary_item = ""

const item = preload("res://Common/Item/Scenes/item.tscn")
@onready var item_ui = $"../../CanvasLayer/Ui/Items"

func hold_item_prim(name: String):
	if primary_item != "":
		pass#summon item with this name
	primary_item = name
	
	item_ui.update_items()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("drop_item"):
		if primary_item != "":
			var new_item = item.instantiate()
			new_item.set_item_name(primary_item)
			new_item.global_position.x = $"../..".global_position.x
			
			get_tree().root.get_node("Main/Items").add_child(new_item)
			primary_item = ""
			item_ui.update_items()
	elif Input.is_action_just_pressed("rotate_items"):
		var old_prim = primary_item
		primary_item = secondary_item
		secondary_item = old_prim
		item_ui.update_items()
	
