extends Node

@export var starting_insanity: float = 0
@export var sanity_drain: float = 0.02
@export var sanity_drain_worsen_percentage: float = 1.15
@export var vignette_max_out: float = 1.5
@export var vignette_max_in: float = 0.85
var insanity_ratio: float

@onready var sanity_filter: TextureRect = $"../../CanvasLayer/SanityFilter"
@onready var gradient: GradientTexture2D = sanity_filter.texture

signal insanity(float)


func _ready() -> void:
	insanity_ratio = starting_insanity
	sanity_filter.modulate.a = starting_insanity


func reset_sanity():
	var tween = create_tween()
	tween.tween_property(self, "insanity_ratio", 0, 0.5)
	
	sanity_drain *= sanity_drain_worsen_percentage
	if sanity_drain > 0.3:
		# TODO: disable shroom function
		pass


func _process(delta: float) -> void:
	insanity_ratio += sanity_drain * delta
	insanity_ratio = clampf(insanity_ratio, 0.0, 1.0)
	insanity.emit(insanity_ratio)
	
	gradient.fill_to.x = lerp(vignette_max_out, vignette_max_in, insanity_ratio)
	sanity_filter.modulate.a = insanity_ratio


func _on_sanity_fill_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		reset_sanity()
