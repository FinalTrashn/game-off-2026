extends Node3D

@onready var lightnings = $Lightnings

func _flash_random_lightning():
	var list = lightnings.get_children()
	list.pick_random().get_node("AnimationPlayer").play("flash")


func _on_timer_timeout() -> void:
	_flash_random_lightning()
