extends CharacterBody3D

# speed
@export var walk_speed: float = 2.6
@export var sprint_speed: float = 6.5
@export var acceleration: float = 20
@export var friction: float = 35
@export var jump_velocity = 5.5
var current_speed: float = walk_speed

# @export var max_animation_speed: float = 15
# @export var min_animation_speed: float = 6

# air control and weight
@export var air_resistance: float = 1.5
@export var air_resistance_scale: float = 2.5
@export var max_jump_windup_time: float = 0.16
@export var min_jump_windup_time: float = 0.04
var jump_prep_timer: float = 0.0
var is_preparing_jump: bool = false

# stamina values
@export var max_stamina = 100
var current_stamina = 100
@export var stamina_drain = 35
@export var stamina_regen = 20
var currently_penalty_recharging = false

# ui elements
@export var stamina_bar: TextureProgressBar
@export var blink_player: AnimationPlayer

@onready var layer_controller = %LayerController

var is_colliding_with_wall: bool = false
var last_collider: Node = null
signal colliding_with_wall(colliding: bool, last_collider: Node, new_collider: Node)


var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if layer_controller:
		layer_controller.layer_changed.connect(_on_layer_changed)
		_on_layer_changed(layer_controller.currently_on_background_layer)
		
	$Sprite.play("idle")


func _on_layer_changed(on_background: bool):
	$Sprite.render_priority = $Sprite.global_position.z*10


func get_input_direction() -> Vector3:
	var direction = Vector3()
	
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	
	return direction


func handle_sprinting(delta):
	# stop from using stamina if no stamina left
	if current_stamina <= 0 and not currently_penalty_recharging:
		currently_penalty_recharging = true
		stamina_bar.tint_progress = Color.WEB_MAROON
		blink_player.play("Blink")

	# handle sprinting if not on penalty
	if Input.is_action_pressed("sprint") and not currently_penalty_recharging and abs(velocity.x) > 0:
		# set max speed
		current_speed = sprint_speed
		
		# drain stamina if not already 0
		if current_stamina > 0 and is_on_floor():
			current_stamina -= stamina_drain * delta
	
	# handle walking or standing
	else:
		# apply walking speed
		current_speed = walk_speed
		
		# regenerate stamina if not already on 100
		if current_stamina < 100 and is_on_floor():
			current_stamina += stamina_regen * delta
		# stamina is fully recovered, remove penalty
		elif currently_penalty_recharging:
			stamina_bar.tint_progress = Color(11.551, 0.293, 13.531)
			currently_penalty_recharging = false
			blink_player.stop()
	
	# visualize on ui progress bar
	if stamina_bar:
		stamina_bar.value = current_stamina


func handle_animation():
	var speed_ratio = clamp(abs(velocity.x) / current_speed, 0.0, 1.0)
	$Sprite.speed_scale = lerp(0.5, 1.5, speed_ratio)
	
	if (is_preparing_jump or not is_on_floor()):
		$Sprite.play("jump")
	elif abs(velocity.x) == 0:
		$Sprite.play("idle")
	elif is_on_floor() and current_speed == walk_speed:
		$Sprite.play("walk")
	elif is_on_floor() and current_speed == sprint_speed:
		$Sprite.play("sprint")


func _process(delta: float) -> void:
	# print(current_stamina)
	handle_sprinting(delta)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# jump windup, prepare for jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not currently_penalty_recharging and not is_preparing_jump:
		is_preparing_jump = true
		
		if abs(velocity.x) < 0.1:
			# if player stands still, they should jump almost instantly
			jump_prep_timer = 0.01
		else:
			# dynamically calculate the prep time based on current speed
			var speed_ratio = clamp(abs(velocity.x) / sprint_speed, 0.0, 1.0)
			jump_prep_timer = lerp(max_jump_windup_time, min_jump_windup_time, speed_ratio)
	
	# while preparing for jump
	if is_preparing_jump:
		velocity.x = move_toward(velocity.x, velocity.x * 0.8, friction * 0.5 * delta)
		
		jump_prep_timer -= delta
		# if preparation finished - jump
		if jump_prep_timer <= 0:
			velocity.y = jump_velocity
			current_stamina -= 30
			is_preparing_jump = false
	
	var direction = get_input_direction()
	if is_on_floor():
		if direction != Vector3.ZERO:
			$Sprite.flip_h = velocity.x < 0
			velocity.x = move_toward(velocity.x, direction.x * current_speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
	# resistance in air
	else:
		# ratio - scale air resistance with speed
		var speed_ratio = abs(velocity.x) / sprint_speed
		var dynamic_resistance = air_resistance + (speed_ratio * speed_ratio * air_resistance_scale)		
		velocity.x = move_toward(velocity.x, 0, dynamic_resistance * delta)
	
	# play animation
	handle_animation()
	
	move_and_slide()


func _physics_process(delta: float) -> void:
	# check collision with wall
	var currently_colliding = $WallCollider.is_colliding()
	if is_colliding_with_wall != currently_colliding:
		var new_collider = null
		if currently_colliding:
			new_collider = $WallCollider.get_collider(0)
		
		emit_signal("colliding_with_wall", currently_colliding, last_collider, new_collider)
		is_colliding_with_wall = currently_colliding
		last_collider = new_collider
