extends StaticBody3D

@export var exit: Node3D
@export var fungus_man_x_pushback: float = 8
var player: Node3D
var player_overlay_player: AnimationPlayer

@onready var layer_controller = %LayerController
@onready var safe_zone: Area3D = $SafeZone as Area3D
@onready var fungus_man = $"../../../FungusManPath/FungunsManFollow/FungusMan"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = %Player
	print(player)
	player_overlay_player = player.get_node("CanvasLayer/Overlays/Black/AnimationPlayer")
	player_overlay_player.connect("animation_finished", _fade_animation_finished)

func _fade_animation_finished(anim_name):
	print(anim_name)
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if player.is_on_floor() and $PlayerCollider.is_colliding() and Input.is_action_just_pressed("use_door") and player.teleportation_allowed:
		player.get_node("Timers/EntranceTimeout").doEntranceTimoutThing()
		handle_use_door()

func handle_use_door():
	player_overlay_player.play("fade_out_in")
	get_tree().paused = true
	$Sounds/DoorNormal.play()
	exit.move_fungus_man_if_in_range()
	await get_tree().create_timer(0.2, true).connect("timeout", func(): move_player())

func move_player():
	var new_pos = exit.global_position
	var on_background = new_pos.z < -layer_controller.background_z_offset
	layer_controller.set_currently_on_background_layer(on_background)
	var z_pos = 0 if not on_background else -layer_controller.background_z_offset
	player.global_position = Vector3(new_pos.x, new_pos.y, z_pos)
	
	player.get_node("Sprite").render_priority = -2 if on_background else 0

func move_fungus_man_if_in_range():
	if !fungus_man:
		print("fungus man doesnt exist")
		return
	if safe_zone.has_overlapping_bodies():
		print("moved")
		var right_pos = Vector3(global_position.x + fungus_man_x_pushback, global_position.y, global_position.z)
		var left_pos = Vector3(global_position.x - fungus_man_x_pushback, global_position.y, global_position.z)
		
		var min_x = min(abs(fungus_man.start_global.x), abs(fungus_man.end_global.x))
		var max_x = max(abs(fungus_man.start_global.x), abs(fungus_man.end_global.x))
		
		var can_go_right = abs(right_pos.x) >= min_x and abs(right_pos.x) <= max_x
		var can_go_left = abs(left_pos.x) >= min_x and abs(left_pos.x) <= max_x
		
		var chosen_pos = Vector3()
		# coinflip which direction
		if randi_range(0, 1) == 0:
			chosen_pos = left_pos if can_go_left else right_pos
		else:
			chosen_pos = right_pos if can_go_right else left_pos
		
		fungus_man._set_position(chosen_pos)


#weil timing egal physics und ned normal process
func _physics_process(delta: float) -> void:
	if $PlayerCollider.is_colliding():
		$ButtonPrompt.modulate = lerp($ButtonPrompt.modulate, Color.WHITE, 0.2)
	else:
		$ButtonPrompt.modulate = lerp($ButtonPrompt.modulate, Color.TRANSPARENT, 0.2)
