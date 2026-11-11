extends Control

@export var max_shift := 30.0
@export var smoothing := 10.0

var start_glob_pos: Vector2

func _ready() -> void:
	start_glob_pos = global_position

func _process(delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	var dir := start_glob_pos.direction_to(mouse_pos)
	var target := start_glob_pos + dir * max_shift
	global_position = global_position.lerp(target, 1.0 - exp(-smoothing * delta))
