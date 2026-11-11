extends Line2D

@export var max_points := 12
@export var target: Control

func _process(_delta):
	if target == null:
		return
	add_point(target.global_position)
	if get_point_count() > max_points:
		remove_point(0)
