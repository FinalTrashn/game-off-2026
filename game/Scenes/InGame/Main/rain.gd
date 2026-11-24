extends AudioStreamPlayer

@onready var bus_idx = AudioServer.get_bus_index("Ambiance")

func _ready() -> void:
	%Player.room_changed.connect(_player_room_change)
	#default
	AudioServer.set_bus_effect_enabled(bus_idx, 0, false)
	AudioServer.set_bus_effect_enabled(bus_idx, 1, false)

func _player_room_change(name:String):
	if name != "Cortyard":
		AudioServer.set_bus_effect_enabled(bus_idx, 0, true)
		AudioServer.set_bus_effect_enabled(bus_idx, 1, true)
	else:
		AudioServer.set_bus_effect_enabled(bus_idx, 0, false)
		AudioServer.set_bus_effect_enabled(bus_idx, 1, false)
