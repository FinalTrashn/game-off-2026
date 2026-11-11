extends PanelContainer

@onready var sound_slider = $MarginContainer/VBoxContainer/Volume/Sound/HSlider
@onready var music_slider = $MarginContainer/VBoxContainer/Volume/Music/HSlider
@onready var master_slider = $MarginContainer/VBoxContainer/Volume/Everything/HSlider

@onready var sound_bus_id = AudioServer.get_bus_index("Sounds")
@onready var music_bus_id = AudioServer.get_bus_index("Music")
@onready var master_bus_id = AudioServer.get_bus_index("Master")

func _ready() -> void:
	sound_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sound_bus_id)-10)
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_id)-10)
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_id)-10)

var last_sound_val = 0.0
var first = true #ignores first fire because of _ready
func _on_sound_slider_value_changed(value: float) -> void:
	if first:
		first = false
		return
	
	AudioServer.set_bus_volume_db(sound_bus_id, linear_to_db(sound_slider.value)+10)
	if abs(last_sound_val - sound_slider.value) > 0.2:
		$MarginContainer/VBoxContainer/Volume/Sound/TestSound.play()
		last_sound_val = sound_slider.value

func _on_mmusic_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(music_slider.value)+10)


func _on_every_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_id, linear_to_db(master_slider.value)+10)
