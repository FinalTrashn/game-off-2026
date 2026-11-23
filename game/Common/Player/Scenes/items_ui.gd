extends Control

@onready var inventory_manager = %InventoryManager
@onready var prim_item_name = $Panel/VBoxContainer/HBoxContainer/PrimItem/MarginContainer/Panel/VBoxContainer/RichTextLabel
@onready var prim_item_sprite = $Panel/VBoxContainer/HBoxContainer/PrimItem/MarginContainer/Panel/VBoxContainer/TextureRect
@onready var sec_item_name = $Panel/VBoxContainer/HBoxContainer/SecItem/Panel/VBoxContainer/RichTextLabel
@onready var sec_item_sprite = $Panel/VBoxContainer/HBoxContainer/SecItem/Panel/VBoxContainer/TextureRect

func _ready() -> void:
	update_items()

func update_items():
	print("prim item is", inventory_manager.primary_item)
	prim_item_name.text = inventory_manager.primary_item
	sec_item_name.text = inventory_manager.secondary_item
	#todo get image from item global#
	prim_item_sprite.texture = ItemSource.get_item_sprite_from_name(inventory_manager.primary_item)
	sec_item_sprite.texture = ItemSource.get_item_sprite_from_name(inventory_manager.secondary_item)
	
	#hides sprite if no item
	prim_item_sprite.visible = prim_item_name.text != ""
	sec_item_sprite.visible = sec_item_name.text != ""
