extends Node

signal progress_changed(value: float)  # 0.0 - 1.0
signal load_failed(path: String)

const LOADING_SCREEN := "res://Scenes/Menus/Loading/loading.tscn"

## DER SCHEIẞ HIER IS GROD NO KI SLOP
## DER MUAS NO GECHECKT WERDEN, WEIL KA WIE MA DES MIM SWITCHES MIT ANIMATION MOCHT

## Minimum time the loading screen stays visible. 0 = skip it entirely
## when the scene is already loaded by the time the first fade finishes.
var min_loading_time := 0.0
var fade_time := 0.4
var fade_color := Color.BLACK

var progress := 0.0
var busy := false

var _overlay: ColorRect
var _tween: Tween


func _ready() -> void:
	# Overlay above everything, invisible until a fade starts
	var layer := CanvasLayer.new()
	layer.layer = 128
	add_child(layer)

	_overlay = ColorRect.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.modulate.a = 0.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_overlay)


## path: scene to load (a String, never a loaded scene)
## properties: {"variable_name": value}, set on the new scene before it starts
func go_to(path: String, properties: Dictionary = {}) -> void:
	if busy:
		push_warning("SceneLoader: already busy, ignoring request for '%s'." % path)
		return

	# The one and only load request. It runs in the background during the fade.
	var err := ResourceLoader.load_threaded_request(path)
	if err != OK:
		push_error("SceneLoader: could not start loading '%s' (error %d)" % [path, err])
		load_failed.emit(path)
		return

	busy = true
	progress = 0.0
	_run(path, properties)  # coroutine, no need to await it


func _run(path: String, properties: Dictionary) -> void:
	await _fade(1.0)  # old scene fades out while loading already runs

	var status := ResourceLoader.load_threaded_get_status(path)

	# Only show the loading screen if we actually have to wait
	if status != ResourceLoader.THREAD_LOAD_LOADED or min_loading_time > 0.0:
		_swap_scene((load(LOADING_SCREEN) as PackedScene).instantiate())
		await _fade(0.0)

		var elapsed := 0.0
		while true:
			var info := []
			status = ResourceLoader.load_threaded_get_status(path, info)

			if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				_set_progress(info[0])
			elif status == ResourceLoader.THREAD_LOAD_LOADED:
				_set_progress(1.0)
				if elapsed >= min_loading_time:
					break
			else:
				push_error("SceneLoader: failed to load '%s'" % path)
				busy = false
				load_failed.emit(path)
				await _fade(0.0)
				return

			await get_tree().process_frame
			elapsed += get_process_delta_time()

		await _fade(1.0)  # loading screen fades out

	# Screen is fully covered: fetch, configure and swap the new scene
	var scene := (ResourceLoader.load_threaded_get(path) as PackedScene).instantiate()

	for key in properties:
		if key in scene:
			scene.set(key, properties[key])
		else:
			push_warning("SceneLoader: '%s' has no property '%s'" % [path, key])

	_swap_scene(scene)
	await _fade(0.0)  # new scene fades in
	busy = false


func _fade(target_alpha: float) -> void:
	if _tween:
		_tween.kill()
	_overlay.color = fade_color
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP  # block clicks while fading

	_tween = create_tween()
	_tween.tween_property(_overlay, "modulate:a", target_alpha, fade_time)
	await _tween.finished

	if target_alpha == 0.0:
		_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _swap_scene(new_scene: Node) -> void:
	var tree := get_tree()
	var old := tree.current_scene
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene
	if old:
		old.queue_free()


func _set_progress(value: float) -> void:
	if value != progress:
		progress = value
		progress_changed.emit(progress)
