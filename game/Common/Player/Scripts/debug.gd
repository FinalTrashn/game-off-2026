extends Control

@onready var player = $"../../.."

@onready var p_walking_speed = player.walk_speed
@onready var p_sprinting_speed = player.sprint_speed

func _ready() -> void:
	visible = false
	$VBoxContainer/DisableSanity.button_pressed = player.insanity_disabled

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


func _on_disable_sanity_pressed() -> void:
	player.insanity_changed.emit(true)


func _on_open_secret_ball_pressed() -> void:
	$"../../../../Rooms/Ball Room/hiddenroom"._openme()


func _on_button_pressed_give() -> void:
	%InventoryManager.hold_item_prim($VBoxContainer/g/give.text)
	$"../../Ui/Items".update_items()
