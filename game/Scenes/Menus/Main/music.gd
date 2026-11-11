extends AudioStreamPlayer

func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($".", "volume_db",-10.0,3.0)
