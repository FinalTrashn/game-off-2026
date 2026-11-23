extends CharacterBody3D


@export var patrol_speed: float = 2.0
@export var investigation_speed: float = 4
@export var chase_speed: float = 5.5
@export var wait_time_range: Vector2 = Vector2(1.5, 4.0)
@export var min_patrol_distance: float = 8.0
@export var sanity_visibility: float = 0.5
@export var sanity_lethal: float = 0.7

@onready var sprite: Sprite3D = $Sprite as Sprite3D
@onready var path_follow: PathFollow3D = get_parent() as PathFollow3D
@onready var path_node: Path3D = path_follow.get_parent() as Path3D
@onready var player = $"../../../Player"
@onready var player_collider: ShapeCast3D = $PlayerCollider as ShapeCast3D
@onready var vision_collider: ShapeCast3D = $VisionCollider as ShapeCast3D
@onready var layer_controller = $"../../../Controller/LayerController"
@onready var sanity_controller = $"../../../Controller/SanityController"

var sanity_enough_for_attack = false

var target_progress: float = 0.0
var current_speed: float = 0.0
var path_length: float = 0.0
var last_x: float = 0.0
var is_waiting: bool = false
var wait_timer: float = 0.0

var start_global: Vector3
var end_global: Vector3


func _ready() -> void:
	path_length = path_node.curve.get_baked_length()
	last_x = global_position.x
	
	start_global = path_node.to_global(path_node.curve.get_point_position(0))
	end_global = path_node.to_global(path_node.curve.get_point_position(path_node.curve.point_count - 1))
	
	_pick_new_random_destination()
	sanity_controller.connect("insanity", on_sanity_change)


func _set_destination(destination: Vector3) -> void:
	target_progress = convert_position_to_progress(destination)


func _set_position(position: Vector3) -> void:
	path_follow.progress = convert_position_to_progress(position)


func convert_position_to_progress(position: Vector3) -> float:
	var local_position = path_node.to_local(position)
	return clamp(path_node.curve.get_closest_offset(local_position), -0.1, path_length + 0.1)


func _pick_new_random_destination() -> void:
	# set the speed to the patrol speed
	current_speed = patrol_speed
	
	# get the global coordinates of the end and start position of path
	var start_position = path_node.to_global(path_node.curve.sample_baked(0.0))
	var end_position = path_node.to_global(path_node.curve.sample_baked(path_length))
	
	# move to left or right via coinflip
	var destination = Vector3()
	if randi_range(0, 1) == 0:
		var max_distance = global_position.distance_to(start_position)
		var random_distance = randf_range(min_patrol_distance, max_distance)
		destination = global_position.move_toward(start_position, random_distance)
	else:
		var max_distance = global_position.distance_to(end_position)
		var random_distance = randf_range(min_patrol_distance, max_distance)
		destination = global_position.move_toward(end_position, random_distance)
	
	destination.x = clamp(destination.x, min(start_position.x, end_position.x), max(start_position.x, end_position.x))
	
	_set_destination(destination)


func _start_waiting() -> void:
	is_waiting = true
	wait_timer = randf_range(wait_time_range.x, wait_time_range.y)


func get_distance_to_player() -> float:
	return player.global_position.x - global_position.x


func on_sanity_change(sanity_ratio: float):
	sprite.modulate.a = clamp(remap(sanity_ratio, sanity_visibility, 1.0, 0.0, 1.0), 0.0, 1.0)
	sanity_enough_for_attack = sanity_ratio >= sanity_lethal


func collides_with_player(collision_shape: ShapeCast3D) -> bool:
	if not collision_shape.is_colliding() or not sanity_enough_for_attack:
		return false
	
	# check if player is in a safe area
	var player_is_in_front_of_wall = not layer_controller.currently_on_background_layer and layer_controller.currently_colliding_with_wall
	# TODO: make collision detected when not fully colliding with wall
	
	# player is visible if in collision and not in front of a wall
	return not player_is_in_front_of_wall


func _process(delta: float) -> void:
	if is_waiting:
		wait_timer -= delta
		if wait_timer <= 0.0:
			is_waiting = false
			_pick_new_random_destination()
		return
	
	# move toward the target point on the path
	path_follow.progress = move_toward(path_follow.progress, target_progress, current_speed * delta)
	
	# flip sprite based on direction
	var dx = global_position.x - last_x
	if abs(dx) > 0.001:
		var facing_left = dx < 0
		sprite.flip_h = facing_left
		vision_collider.position.x = -3.0 if facing_left else 3.0
	last_x = global_position.x
	
	# check if destination was reached
	if is_equal_approx(path_follow.progress, target_progress):
		_start_waiting()
	

func _physics_process(delta: float) -> void:
	if collides_with_player(player_collider):
		print("GOT YOU at ", global_position.x)
		SceneLoader.go_to("res://Scenes/Menus/DeathAnimations/deathFungus.tscn")
	
	if collides_with_player(vision_collider):
		current_speed = chase_speed
		is_waiting = false
		_set_destination(player.global_position)
