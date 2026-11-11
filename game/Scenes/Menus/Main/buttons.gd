extends PanelContainer

func _ready() -> void:
	$"../../../Overlay/Control/SettingsClose".visible = false

func _on_exit_pressed() -> void:
	$"../../../Overlay/Control/ColorRect/AnimationPlayer".play("fade_out")
	$MarginContainer/VBoxContainer/Exit/Thunder.play()


func _on_thunder_finished() -> void:
	get_tree().quit(0)


func _on_settings_close_pressed() -> void:
	$"../../../Overlay/Control/SettingsClose".visible = false


func _on_settings_pressed() -> void:
	$"../../../Overlay/Control/SettingsClose".visible = true
