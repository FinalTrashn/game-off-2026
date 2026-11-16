extends CharacterBody3D


@export var patrol_speed: float = 2.0
@export var investigation_speed: float = 4
@export var chase_speed: float = 5.5
@export var wait_time_range: Vector2 = Vector2(1.5, 4.0)
@export var min_patrol_distance: float = 8.0

@onready var sprite: Sprite3D = $Sprite as Sprite3D
@onready var path_follow: PathFollow3D = get_parent() as PathFollow3D
@onready var path_node: Path3D = path_follow.get_parent() as Path3D
@onready var player = $"../../../Player"
@onready var player_collider: ShapeCast3D = $PlayerCollider as ShapeCast3D
@onready var vision_collider: ShapeCast3D = $VisionCollider as ShapeCast3D

var target_progress: float = 0.0
var current_speed: float = 0.0
var path_length: float = 0.0
var last_x: float = 0.0
var is_waiting: bool = false
var wait_timer: float = 0.0


func _ready() -> void:
	path_length = path_node.curve.get_baked_length()
	last_x = global_position.x
	
	_pick_new_random_destination()


func _set_position(world_pos: Vector3) -> void:
	var local_pos: Vector3 = path_node.to_local(world_pos)
	target_progress = clamp(path_node.curve.get_closest_offset(local_pos), 0.0, path_length)


func _pick_new_random_destination() -> void:
	current_speed = patrol_speed
	
	# Get the world-space start and end points of the path
	var start_world: Vector3 = path_node.to_global(path_node.curve.sample_baked(0.0))
	var end_world: Vector3 = path_node.to_global(path_node.curve.sample_baked(path_length))
	
	# Check distances in world space from the character's current position
	var dist_to_start: float = global_position.distance_to(start_world)
	var dist_to_end: float = global_position.distance_to(end_world)
	
	# Safety check: if the path is shorter than min_patrol_distance, go to the furthest end
	if path_length <= min_patrol_distance:
		_set_position(start_world if dist_to_start > dist_to_end else end_world)
		return
	
	var can_go_start: bool = dist_to_start >= min_patrol_distance
	var can_go_end: bool = dist_to_end >= min_patrol_distance
	
	var chosen_target: Vector3
	
	if can_go_start and can_go_end:
		# Both directions have enough room: pick a random world point on either side
		if randf() < 0.5:
			var stop_point = global_position.move_toward(start_world, min_patrol_distance)
			chosen_target = stop_point.lerp(start_world, randf())
		else:
			var stop_point = global_position.move_toward(end_world, min_patrol_distance)
			chosen_target = stop_point.lerp(end_world, randf())
	elif can_go_start:
		var stop_point = global_position.move_toward(start_world, min_patrol_distance)
		chosen_target = stop_point.lerp(start_world, randf())
	else:
		var stop_point = global_position.move_toward(end_world, min_patrol_distance)
		chosen_target = stop_point.lerp(end_world, randf())
	
	_set_position(chosen_target)


func _on_destination_reached():
	is_waiting = true
	await get_tree().create_timer(randf_range(wait_time_range.x, wait_time_range.y)).timeout
	is_waiting = false
	_pick_new_random_destination()


func _start_waiting() -> void:
	is_waiting = true
	wait_timer = randf_range(wait_time_range.x, wait_time_range.y)


func get_distance_to_player() -> float:
	return player.global_position.x - global_position.x


func collides_with_player(collision_shape: ShapeCast3D) -> bool:
	if not collision_shape.is_colliding():
		return false

	var hit_player := false
	for i in range(collision_shape.get_collision_count()):
		if collision_shape.get_collider(i) == player:
			hit_player = true
			break
			
	if not hit_player:
		return false

	# Fire a ray to check if a wall is between the Fungus Man and the Player
	var space_state = get_world_3d().direct_space_state
	var origin = global_position + Vector3(0, 1.0, 0)
	var target = player.global_position + Vector3(0, 1.0, 0) 
	
	var query = PhysicsRayQueryParameters3D.create(origin, target)
	query.collision_mask = 2 
	query.exclude = [self.get_rid(), player.get_rid()]
	
	var result = space_state.intersect_ray(query)
	
	return result.is_empty()


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
	
	if collides_with_player(vision_collider):
		current_speed = chase_speed
		is_waiting = false
		_set_position(player.global_position)
