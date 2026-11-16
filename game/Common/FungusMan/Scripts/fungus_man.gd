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

var target_progress: float = 0.0
var current_speed: float = 0.0
var path_length: float = 0.0
var last_x: float = 0.0
var is_waiting: bool = false


func _ready() -> void:
	path_length = path_node.curve.get_baked_length()
	last_x = global_position.x
	
	_pick_new_random_destination()


func _pick_new_random_destination():
	current_speed = patrol_speed
	var current_pos = path_follow.progress
	
	# if min distance < total length then default to the opposing end
	if path_length <= min_patrol_distance:
		target_progress = 0.0 if current_pos > path_length * 0.5 else path_length
		return
	
	# Check which directions have enough room left
	var can_go_left = current_pos >= min_patrol_distance
	var can_go_right = (path_length - current_pos) >= min_patrol_distance
	
	if can_go_left and can_go_right:
		# Both sides are valid: flip a coin to pick left or right
		if randf() < 0.5:
			target_progress = randf_range(0.0, current_pos - min_patrol_distance)
		else:
			target_progress = randf_range(current_pos + min_patrol_distance, path_length)
	elif can_go_left:
		# Too close to the right end, forced to go left
		target_progress = randf_range(0.0, current_pos - min_patrol_distance)
	else:
		# Too close to the left end, forced to go right
		target_progress = randf_range(current_pos + min_patrol_distance, path_length)


func _on_destination_reached():
	is_waiting = true
	await get_tree().create_timer(randf_range(wait_time_range.x, wait_time_range.y)).timeout
	is_waiting = false
	_pick_new_random_destination()
	

func get_distance_to_player() -> float:
	return player.global_position.x - global_position.x


func _process(delta: float) -> void:
	if is_waiting:
		return
	
	# move toward the target point on the path
	path_follow.progress = move_toward(path_follow.progress, target_progress, current_speed * delta)
	
	# flip sprite based on direction
	var dx = global_position.x - last_x
	if abs(dx) > 0.001:
		sprite.flip_h = dx < 0
	last_x = global_position.x
	
	# check if destination was reached
	if is_equal_approx(path_follow.progress, target_progress):
		_on_destination_reached()
	

func _physics_process(delta: float) -> void:
	if not player_collider.is_colliding():
		return
		
	var wall_dist: float = INF
	var player_dist: float = INF
	
	for i in range(player_collider.get_collision_count()):
		var collider = player_collider.get_collider(i)
		if not collider:
			continue
			
		var dist = collider.global_position.z - global_position.z

		if collider == player:
			player_dist = dist
		else:
			wall_dist = dist
		
	if player_dist < wall_dist:
		print("GOT YOU", global_position.x)
