extends Timer


func doEntranceTimoutThing():
	$"../..".teleportation_allowed = false
	start()


func _on_timeout() -> void:
	$"../..".teleportation_allowed = true
