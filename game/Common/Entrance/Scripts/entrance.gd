extends StaticBody3D

@export var exit: Node3D
@export var fungus_man_x_pushback: float = 8
@export var item_required: String
@export var is_stairs: bool = false
@export var always_locked = false

@onready var player = %Player
var player_overlay_player: AnimationPlayer

@onready var layer_controller = %LayerController
@onready var safe_zone: Area3D = $SafeZone as Area3D
@onready var fungus_man = $"../../../FungusManPath/FungunsManFollow/FungusMan"
@onready var parent_room = $"../"

var unlocked = false

func _ready() -> void:
	player_overlay_player = player.get_node("CanvasLayer/Overlays/Black/AnimationPlayer")
	player_overlay_player.connect("animation_finished", _fade_animation_finished)
	
	if !exit:
		push_error("Entrance in ",parent_room.name, " has no exit")
	
	if is_stairs:
		$Sprite.texture = load("res://Common/Entrance/Sprites/buttonPromptKeyboard.png")
		$Sounds/DoorNormal.stream = load("res://Common/Sounds/thunder.ogg")
	
	if always_locked and rotation.y != 0.0:
		$Sprite.modulate = Color.from_string("#ffffff47", Color.TRANSPARENT)

func _fade_animation_finished(anim_name):
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if player.is_on_floor() \
	and $PlayerCollider.is_colliding() \
	and Input.is_action_just_pressed("use_door") \
	and player.teleportation_allowed:
		if always_locked:
			$Sounds/Locked.play()
			return
		
		if not unlocked and (not item_required or player.get_node("Workers/InventoryManager").primary_item == item_required):
			unlocked = true
		if unlocked:
			player.get_node("Timers/EntranceTimeout").doEntranceTimoutThing()
			handle_use_door()
		else:
			$Sounds/Locked.play()

func handle_use_door():
	player_overlay_player.play("fade_out_in")
	get_tree().paused = true
	$Sounds/DoorNormal.play()
	exit.move_fungus_man_if_in_range()
	await get_tree().create_timer(0.2, true).connect("timeout", func(): move_player())
	player.room_changed.emit(exit.parent_room.name)

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
		if randi_range(0, 1) == 0:
			chosen_pos = left_pos if can_go_left else right_pos
		else:
			chosen_pos = right_pos if can_go_right else left_pos
		
		fungus_man._set_position(chosen_pos)

func _physics_process(delta: float) -> void:
	if always_locked:
		$ButtonPrompt.visible = false
		return
	if $PlayerCollider.is_colliding():
		$ButtonPrompt.modulate = lerp($ButtonPrompt.modulate, Color.WHITE, 0.2)
	else:
		$ButtonPrompt.modulate = lerp($ButtonPrompt.modulate, Color.TRANSPARENT, 0.2)
