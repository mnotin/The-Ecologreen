extends GridMap

func placeBlock(coordinates : Vector3, item : int) -> void:
	set_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z), item)