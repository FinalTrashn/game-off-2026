extends PanelContainer

func _ready() -> void:
	$"../../../Overlay/Control/SettingsClose".visible = false

func _on_exit_pressed() -> void:
	$"../../../Overlay/Control/ColorRect/AnimationPlayer".play("fade_out")
	$"../../../Sounds/Thunder".play()


func _on_thunder_finished() -> void:
	get_tree().quit(0)


func _on_settings_close_pressed() -> void:
	$"../../../Sounds/PgameClick202611111353".play()
	$"../../../Overlay/Control/SettingsClose".visible = false


func _on_settings_pressed() -> void:
	$"../../../Sounds/PgameClick202611111353".play()
	$"../../../Overlay/Control/SettingsClose".visible = true


func _on_start_mouse_entered() -> void:
	$"../../../Sounds/PgameHover202611111348".play()


func _on_start_pressed() -> void:
	$"../../../Sounds/PgameClick202611111353".play()
