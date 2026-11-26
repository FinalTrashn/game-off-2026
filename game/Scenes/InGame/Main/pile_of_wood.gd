extends StaticBody3D

@onready var button_prompt = $ButtonPrompt

@export var item_needed: String
@export var use_sound: AudioStream

var _player_here = false

func _ready() -> void:
	$AnimationPlayer/use.stream = use_sound

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
		if %Player.get_node("Workers/InventoryManager").primary_item == item_needed:
			#removes any things to interact with
			$Area3D.queue_free()
			button_prompt.queue_free()
			
			#final start and deletion
			$AnimationPlayer/use.play()
			
			var target: GeometryInstance3D = null
			for c in get_children():
				if c is CollisionObject3D: #deletes the collision objects so the player can already go
					c.queue_free()
				elif c is MeshInstance3D:
					target = c
					break  # mesh has prio
				elif c is Sprite3D and target == null:
					target = c  # only using sprite if no mesh is found
			
			if target == null:
				push_error(name, " had the error that it didnt find a mesh or sprite")
				return
			
			var tw := create_tween()
			tw.tween_property(target, "transparency", 1.0, 2)
			tw.tween_callback(queue_free)  
		else:
			if !$AnimationPlayer.is_playing():
				$AnimationPlayer.play("shake")
			
