extends Node3D

func _ready() -> void:
	for c in get_children():
		c.visible = false
