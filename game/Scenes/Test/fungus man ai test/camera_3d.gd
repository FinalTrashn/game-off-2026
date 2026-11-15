class_name FreeCam
extends Camera3D
## Simple free-fly camera. Attach to a Camera3D node.
## WASD = move, Space/Ctrl (or E/Q) = up/down, Shift = sprint,
## Mouse wheel = change speed, Esc = release/capture the mouse.

@export var move_speed := 8.0
@export var sprint_multiplier := 3.0
@export var mouse_sensitivity := 0.003
@export var min_speed := 1.0
@export var max_speed := 100.0

var _yaw := 0.0
var _pitch := 0.0


func _ready() -> void:
	print("FreeCam ready on: ", get_path())  # remove once it's working
	_yaw = rotation.y
	_pitch = rotation.x
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch = clampf(_pitch - event.relative.y * mouse_sensitivity, -PI / 2.0, PI / 2.0)
		rotation = Vector3(_pitch, _yaw, 0.0)

	elif event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			# Click to (re)capture the mouse
			if event.button_index == MOUSE_BUTTON_LEFT:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			move_speed = minf(move_speed * 1.2, max_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			move_speed = maxf(move_speed / 1.2, min_speed)

	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	var input_dir := Vector3.ZERO
	input_dir.x = _axis(KEY_D, KEY_A)
	input_dir.z = _axis(KEY_S, KEY_W)  # -Z is forward
	input_dir.y = _axis(KEY_SPACE, KEY_CTRL) + _axis(KEY_E, KEY_Q)

	if input_dir == Vector3.ZERO:
		return

	var speed := move_speed
	if Input.is_physical_key_pressed(KEY_SHIFT):
		speed *= sprint_multiplier

	# Move relative to where the camera is looking
	global_position += global_transform.basis * input_dir.normalized() * speed * delta


func _axis(positive: Key, negative: Key) -> float:
	return float(Input.is_physical_key_pressed(positive)) - float(Input.is_physical_key_pressed(negative))
