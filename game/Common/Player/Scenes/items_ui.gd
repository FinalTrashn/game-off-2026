extends Control

@onready var inventory_manager = %InventoryManager
@onready var prim_item_name = $Panel/HBoxContainer/PrimItem/MarginContainer/Panel/VBoxContainer/RichTextLabel
@onready var sec_item_name = $Panel/HBoxContainer/SecItem/Panel/VBoxContainer/RichTextLabel
@onready var prim_item_sprite = $Panel/HBoxContainer/PrimItem/MarginContainer/Panel/VBoxContainer/TextureRect
@onready var sec_item_sprite = $Panel/HBoxContainer/SecItem/Panel/VBoxContainer/TextureRect

func _ready() -> void:
	update_items()

func update_items():
	print("prim item is", inventory_manager.primary_item)
	prim_item_name.text = inventory_manager.primary_item
	sec_item_name.text = inventory_manager.secondary_item
	#todo get image from item global
	
	#hides sprite if no item
	prim_item_sprite.visible = prim_item_name.text != ""
	sec_item_sprite.visible = sec_item_name.text != ""
