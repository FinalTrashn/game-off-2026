extends Area3D

var _player_in = false
@onready var player = %Player

@export var _holding_item = ""

signal holding_changed(String)

func _ready() -> void:
	_updateGui()

func _physics_process(delta: float) -> void:
	if _player_in:
		$ButtonPrompt.modulate = lerp($ButtonPrompt.modulate, Color.WHITE, 0.2)
	else:
		$ButtonPrompt.modulate = lerp($ButtonPrompt.modulate, Color.TRANSPARENT, 0.2)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		_player_in = true

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		_player_in = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and _player_in:
		if _holding_item:
			player.set_prim_item(_holding_item)
			_holding_item = ""
			_updateGui()
		else:
			_holding_item = player.get_prim_item()
			player.del_prim_item()
			_updateGui()

func _updateGui():
	holding_changed.emit(_holding_item)
	$Item.texture = ItemSource.get_item_sprite_from_name(_holding_item)
