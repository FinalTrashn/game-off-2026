extends Node

func get_item_sprite_from_name(iname: String) -> Texture2D:
	var item_sprite_address = "res://Common/Item/Sprites/Types/" + iname + ".png"
	if ResourceLoader.exists(item_sprite_address):
		return load(item_sprite_address)
	push_warning("Item sprite not found: " + item_sprite_address)
	return null

var rando_items = [
	"Blue Book",
	"Red Book",
	"Green Book",
	"Knive"
]
