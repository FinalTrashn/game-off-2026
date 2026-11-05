extends Camera3D


@export var player: Node3D
@export var follow_speed = 5
@export var foreground_y_offset: float = 3
@export var background_y_offset: float = 1.5
@export var foreground_z_offset: float = 7
@export var background_z_offset: float = 4.5

@onready var layer_controller = get_tree().root.get_node("/root/Main/Controller/LayerController")

var target_z_offset: float = foreground_z_offset
var target_y_offset: float = foreground_y_offset


func _ready() -> void:
	if layer_controller:
		layer_controller.layer_changed.connect(_on_layer_changed)
		_on_layer_changed(layer_controller.currently_on_background_layer)

func _process(delta: float) -> void:
	if not player or not layer_controller:
		print("hüfe")
		return
		
	var target_position = player.global_position
	target_position.z += target_z_offset
	target_position.y = target_y_offset
	
	global_position = global_position.lerp(target_position, follow_speed * delta)
	

func _on_layer_changed(is_background: bool) -> void:
	if is_background:
		target_z_offset = background_z_offset
		target_y_offset = background_y_offset
	else:
		target_z_offset = foreground_z_offset
		target_y_offset= foreground_y_offset
