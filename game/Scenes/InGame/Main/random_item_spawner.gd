extends Node

func _ready() -> void:
	var seed = 2323232
	var spawners = get_tree().get_nodes_in_group("ItemSpawnerRandom")
	var items: Array = ItemSource.rando_items
	
	if items.size() > spawners.size():
		OS.crash("Not enough spawners: %d items but only %d spawners" % [items.size(), spawners.size()])
		return
	
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	
	for i in range(spawners.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = spawners[i]
		spawners[i] = spawners[j]
		spawners[j] = tmp

	for i in items.size():
		var spawner = spawners[i]
		spawner.spawn_item(items[i])
