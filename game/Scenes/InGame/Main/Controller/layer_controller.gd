extends Node

@export var player: Node3D
@export var background_z_offset = 3

var currently_on_background_layer = false
var currently_colliding_with_wall = false
signal layer_changed(is_background: bool)

func _ready() -> void:
	player.colliding_with_wall.connect(_on_collision_change)

func switch_layer():
	if not currently_colliding_with_wall:
		currently_on_background_layer = !currently_on_background_layer
		if currently_on_background_layer:
			player.global_position.z -= background_z_offset
		else:
			player.global_position.z += background_z_offset
		emit_signal("layer_changed", currently_on_background_layer)


func _on_collision_change(is_colliding: bool, last_collider: Node, new_collider: Node):
	currently_colliding_with_wall = is_colliding
	
	var new_alpha = 1
	if currently_on_background_layer:
		new_alpha = 0.5
	
	_change_opacity_of_wall(last_collider, 1)
	_change_opacity_of_wall(new_collider, new_alpha)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("switch_to_background_layer") and not currently_on_background_layer:
		switch_layer()
	elif Input.is_action_just_pressed("switch_to_foreground_layer") and currently_on_background_layer:
		switch_layer()


#func _change_opacity_of_walls(alpha: float = 0.5):
	#var walls = get_tree().get_nodes_in_group("wall")
	#for w in walls:
		#if w is Sprite3D:
			#var tween = create_tween()
			#tween.tween_property(w, "modulate:a", alpha, 0.5)
		#else:
			#push_warning("%s has no modulate (not a Sprite3D)" % w.name)
			
func _change_opacity_of_wall(wall: Node, alpha: float = 0.5):
	if wall:
		var sprite = wall.get_node("Sprite")
		if sprite is Sprite3D:
			var tween = create_tween()
			tween.tween_property(sprite, "modulate:a", alpha, 0.5)
		else:
			push_warning("%s has no modulate (not a Sprite3D)" % sprite.name)
