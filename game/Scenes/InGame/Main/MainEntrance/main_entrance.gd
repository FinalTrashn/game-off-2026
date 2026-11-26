extends StaticBody3D

@onready var layer_controller = %LayerController

@export var disabled = true
@export var exit: Node3D
@onready var player = %Player
@onready var parent_room = $"../"
var player_overlay_player: AnimationPlayer

var _player_in = false

func _ready() -> void:
	player_overlay_player = player.get_node("CanvasLayer/Overlays/Black/AnimationPlayer")
	player_overlay_player.connect("animation_finished", _fade_animation_finished)

func _on_player_detector_body_entered(body: Node3D) -> void:
	print(body.name)
	if body.name == "Player":
		if !disabled or body.get_node("Workers/InventoryManager").primary_item == "Main Entrance Key":
			print("OOOOHHH SHIIIIIIDD")
			_player_in = true


func _on_player_detector_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		if !disabled:
			_player_in = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and _player_in:
		player_overlay_player.play("fade_out_in")
		get_tree().paused = true
		#$Sounds/DoorNormal.play()
		await get_tree().create_timer(0.2, true).connect("timeout", func(): move_player())
		player.room_changed.emit(exit.parent_room.name)

#weil timing egal physics und ned normal process
func _physics_process(delta: float) -> void:
	if _player_in:
		$ButtonPrompt.modulate = lerp($ButtonPrompt.modulate, Color.WHITE, 0.2)
	else:
		$ButtonPrompt.modulate = lerp($ButtonPrompt.modulate, Color.TRANSPARENT, 0.2)

func _fade_animation_finished(anim_name):
	get_tree().paused = false

#copy from entrance
func move_player():
	var new_pos = exit.global_position
	var on_background = new_pos.z < -layer_controller.background_z_offset
	layer_controller.set_currently_on_background_layer(on_background)
	var z_pos = 0 if not on_background else -layer_controller.background_z_offset
	player.global_position = Vector3(new_pos.x, new_pos.y, z_pos)
	
	player.get_node("Sprite").render_priority = -2 if on_background else 0
