extends PanelContainer

@onready var sound_slider = $MarginContainer/VBoxContainer/Volume/Sound/HSlider
@onready var music_slider = $MarginContainer/VBoxContainer/Volume/Music/HSlider
@onready var master_slider = $MarginContainer/VBoxContainer/Volume/Everything/HSlider

@onready var sound_bus_id = AudioServer.get_bus_index("Sounds")
@onready var music_bus_id = AudioServer.get_bus_index("Music")
@onready var master_bus_id = AudioServer.get_bus_index("Master")

func _ready() -> void:
	var old_sound_vol = SaveManager.get_value("sound-volume")
	var old_music_vol = SaveManager.get_value("music-volume")
	var old_master_vol = SaveManager.get_value("master-volume")
	
	##setting saved volume to bus
	if old_sound_vol:
		AudioServer.set_bus_volume_db(sound_bus_id, linear_to_db(float(old_sound_vol))+10)
	if old_music_vol:
		AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(float(old_music_vol))+10)
	if old_master_vol:
		AudioServer.set_bus_volume_db(master_bus_id, linear_to_db(float(old_master_vol))+10)
	
	##using bus volume to set slider
	# this is not using the old_... values, because if they are null we would need to use else etc. which sucks
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
	SaveManager.set_value("sound-volume", str(sound_slider.value))
	if abs(last_sound_val - sound_slider.value) > 0.2:
		$MarginContainer/VBoxContainer/Volume/Sound/TestSound.play()
		last_sound_val = sound_slider.value

func _on_mmusic_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(music_slider.value)+10)
	SaveManager.set_value("music-volume", str(music_slider.value))


func _on_every_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_id, linear_to_db(master_slider.value)+10)
	SaveManager.set_value("master-volume", str(master_slider.value))


func _on_volume_reset_pressed() -> void:
	first = true
	sound_slider.value = 0.5
	music_slider.value = 0.5
	master_slider.value = 0.5
