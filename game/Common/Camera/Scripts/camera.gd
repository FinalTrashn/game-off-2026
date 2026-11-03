extends Camera3D


@export var player: Node3D
@export var follow_speed = 5
@export var offset: Vector3 = Vector3(0, 1.5, 7)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not player:
		return
		
	var target_position = player.global_position + offset
	target_position.y = offset.y
	
	global_position = global_position.lerp(target_position, follow_speed * delta)
	
	pass
