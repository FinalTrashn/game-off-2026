extends Node


func _ready() -> void:
	var sprites = get_all_sprite3ds(get_tree().root)
	
	for s in sprites:
		s.render_priority = s.global_position.z*10


func get_all_sprite3ds(node: Node) -> Array[Node3D]:
	var sprites: Array[Node3D] = []
	
	if node is Sprite3D or node is AnimatedSprite3D:
		sprites.append(node)
	
	for n in node.get_children():
		sprites.append_array(get_all_sprite3ds(n))
	
	return sprites
