extends Area3D

var player = null

func _ready() -> void:
	update_gui()
	print(" my name is ",name)
	var sprite = ItemSource.get_item_sprite_from_name(name)
	if sprite:
		$Sprite3D.texture = sprite
	else:
		$Sprite3D.texture = load("res://Common/Item/Sprites/Types/test.png")

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		$ButtonPrompt.visible = true
		player = body

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		$ButtonPrompt.visible = false
		player = null

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player:
		player.get_node("Workers/InventoryManager").hold_item_prim(name) # using name of node cause why not
		queue_free()

func set_item_name(new_name:String):
	name = new_name
	update_gui()

func update_gui():
	$ButtonPrompt.visible = false
	$ButtonPrompt/Label3D.text = "Pickup "+str(name)
