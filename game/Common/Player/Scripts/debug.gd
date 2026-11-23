extends Control

@onready var player = $"../../.."

@onready var p_walking_speed = player.walk_speed
@onready var p_sprinting_speed = player.sprint_speed

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Debug"):
		visible = !visible


func _on_fast_toggled(toggled_on: bool) -> void:
	if toggled_on:
		player.walk_speed = 20
		player.sprint_speed = 0
	else:
		player.walk_speed = p_walking_speed
		player.sprint_speed = p_sprinting_speed


func _on_kill_fuingus_pressed() -> void:
	var fm = get_tree().root.get_node("Main/FungusManPath")
	print("fm found ", fm.name)
	fm.queue_free()
