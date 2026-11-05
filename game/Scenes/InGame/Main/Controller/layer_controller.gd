extends Node

@export var player: Node3D
@export var background_z_offset = 3

var currently_on_background_layer = false
signal layer_changed(is_background: bool)

func switch_layer():
	currently_on_background_layer = !currently_on_background_layer
	emit_signal("layer_changed", currently_on_background_layer)
	if currently_on_background_layer:
		player.global_position.z -= background_z_offset
	else:
		player.global_position.z += background_z_offset

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("switch_to_background_layer") and not currently_on_background_layer:
		switch_layer()
	elif Input.is_action_just_pressed("switch_to_foreground_layer") and currently_on_background_layer:
		switch_layer()
