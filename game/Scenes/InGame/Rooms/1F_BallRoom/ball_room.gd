extends Node3D

var wine_arr = ["","",""]

func _ready() -> void:
	$Pedastol.holding_changed.connect(_items_updated0)
	$Pedastol2.holding_changed.connect(_items_updated1)
	$Pedastol3.holding_changed.connect(_items_updated2)

func _items_updated0(nam):
	wine_arr[0] = nam
	_check_compleation()

func _items_updated1(nam):
	wine_arr[1] = nam
	_check_compleation()

func _items_updated2(nam):
	wine_arr[2] = nam
	_check_compleation()

func _check_compleation():
	print(wine_arr[0], " ",wine_arr[1], " ", wine_arr[2])
	if wine_arr[0] == "Convex Wine" and \
		wine_arr[1] == "Concave Wine" and \
		wine_arr[2] == "Thick Wine":
			$hiddenroom._openme()
