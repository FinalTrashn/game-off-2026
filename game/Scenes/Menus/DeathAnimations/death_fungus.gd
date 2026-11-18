extends Control



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	SceneLoader.go_to("res://Scenes/Menus/Main/main.tscn")
