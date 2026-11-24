extends Control

func _ready() -> void:
	$"../../..".room_changed.connect(play)

func play(name:String):
	$Panel/Label.text = name
	$AnimationPlayer.stop()
	$AnimationPlayer.play("fadein")
