extends Node

func _ready() -> void:
	_reset_rooms_visibility()

#makes all rooms invisible immediatly
func _reset_rooms_visibility(): 
	for r in $"../../Rooms".get_children():
		r.visible = false

func show_room(name:String):
	for r in $"../../Rooms".get_children():
		if r.name == name:
			_reset_rooms_visibility()
			r.visible = true
	
