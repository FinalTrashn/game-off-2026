extends Node2D

func _on_video_stream_player_finished() -> void:
	SceneLoader.go_to("res://Scenes/Menus/Main/main.tscn")
