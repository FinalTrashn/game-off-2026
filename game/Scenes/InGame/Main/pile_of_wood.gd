extends StaticBody3D

@onready var button_prompt = $ButtonPrompt

var _player_here = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		_player_here = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		_player_here = false

#weil timing egal physics und ned normal process
## wie in entrence
func _physics_process(delta: float) -> void:
	if !button_prompt:
		return
	if _player_here:
		button_prompt.modulate = lerp(button_prompt.modulate, Color.WHITE, 0.2)
	else:
		button_prompt.modulate = lerp(button_prompt.modulate, Color.TRANSPARENT, 0.2)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and _player_here:
		if %Player.get_node("Workers/InventoryManager").primary_item == "Fire Axt":
			#removes any things to interact with
			$Area3D.queue_free()
			button_prompt.queue_free()
			$CollisionShape3D.queue_free()
			
			#final start and deletion
			$"AnimationPlayer/703420HadescolossusChoppingLogsWithAnAxe".connect("finished",func(): queue_free())
			$"AnimationPlayer/703420HadescolossusChoppingLogsWithAnAxe".play()
			
		else:
			if !$AnimationPlayer.is_playing():
				$AnimationPlayer.play("shake")
			
