extends StaticBody3D

@export var exit: Node3D
var player: Node3D
var player_overlay_player: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $"../../../../../../Player"
	print(player)
	player_overlay_player = player.get_node("CanvasLayer/Overlays/Black/AnimationPlayer")
	player_overlay_player.connect("animation_finished", _fade_animation_finished)

func _fade_animation_finished(anim_name):
	print(anim_name)
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if player.is_on_floor() and $PlayerCollider.is_colliding() and Input.is_action_just_pressed("use_door"):
		handle_use_door()

func handle_use_door():
	player_overlay_player.play("fade_out_in")
	get_tree().paused = true
	$Sounds/DoorNormal.play()
	await get_tree().create_timer(0.2, true).connect("timeout", func(): move_player())

func move_player():
	var new_pos = exit.global_position
	player.global_position = Vector3(new_pos.x, new_pos.y, player.global_position.z)

#weil timing egal physics und ned normal process
func _physics_process(delta: float) -> void:
	if $PlayerCollider.is_colliding():
		$ButtonPrompt.modulate = lerp($ButtonPrompt.modulate, Color.WHITE, 0.2)
	else:
		$ButtonPrompt.modulate = lerp($ButtonPrompt.modulate, Color.TRANSPARENT, 0.2)
