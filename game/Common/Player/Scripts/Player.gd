extends CharacterBody3D

# speed
@export var walk_speed = 2.6
@export var sprint_speed = 6.5
@export var acceleration: float = 20
@export var friction: float = 35
@export var jump_velocity = 4.5
var current_speed: float = walk_speed

# stamina values
@export var max_stamina = 100
var current_stamina = 100
@export var stamina_drain = 35
@export var stamina_regen = 20
var currently_penalty_recharging = false

# ui elements
@export var stamina_bar: TextureProgressBar
@export var blink_player: AnimationPlayer


var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


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
	if Input.is_action_pressed("sprint") and not currently_penalty_recharging:
		# set max speed
		current_speed = sprint_speed
		
		# drain stamina if not already 0
		if current_stamina > 0:
			current_stamina -= stamina_drain * delta
	
	# handle walking or standing
	else:
		# apply walking speed
		current_speed = walk_speed
		
		# regenerate stamina if not already on 100
		if current_stamina < 100:
			current_stamina += stamina_regen * delta
		# stamina is fully recovered, remove penalty
		elif currently_penalty_recharging:
			stamina_bar.tint_progress = Color(11.551, 0.293, 13.531)
			currently_penalty_recharging = false
			blink_player.stop()
	
	# visualize on ui progress bar
	if stamina_bar:
		stamina_bar.value = current_stamina

func _physics_process(delta: float) -> void:
	# print(current_stamina)
	handle_sprinting(delta)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor() and not currently_penalty_recharging:
		velocity.y = jump_velocity
		current_stamina -= 30
	
	var direction = get_input_direction()
	if is_on_floor():
		if direction != Vector3.ZERO:
			velocity.x = move_toward(velocity.x, direction.x * current_speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	move_and_slide()
