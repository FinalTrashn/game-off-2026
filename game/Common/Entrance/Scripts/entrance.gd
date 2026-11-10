extends StaticBody3D

@export var exit: Node3D
var player: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().root.get_node("/root/Main/Player")
	print(player)
	
	
func _input(event: InputEvent) -> void:
	if player.is_on_floor() and $PlayerCollider.is_colliding() and Input.is_action_just_pressed("use_door"):
		handle_use_door()


func handle_use_door():
	var new_pos = exit.global_position
	player.global_position = Vector3(new_pos.x, new_pos.y, player.global_position.z)
