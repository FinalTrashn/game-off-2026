extends Sprite2D

@onready var pictures = [
	preload("res://icon.svg"),
	preload("res://Scenes/Test/hihi/Bildschirmfoto 2025-08-16 um 23.10.29.png"),
	preload("res://Scenes/Test/hihi/Bildschirmfoto 2025-09-16 um 09.25.59.png"),
	preload("res://Scenes/Test/hihi/grimlo.png")
]

func _ready() -> void:
	change_pic()

var last_pic = null
func change_pic():
	var i = randi_range(0, len(pictures)-1)
	while i == last_pic:
		i = randi_range(0, len(pictures)-1)
	
	last_pic = i
	$".".texture = pictures[i]


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("pic changed")
	change_pic()
	$"../AnimationPlayer".play("fade")
