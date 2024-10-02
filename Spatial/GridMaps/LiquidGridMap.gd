extends GridMap

func placeBlock(coordinates : Vector3, item : int) -> void:
	set_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z), item)

func generateLiquidWorld() -> void:
	var solidGridMap : GridMap = get_node("../SolidGridMap")
	
	# Place grass blocks
	print("Generating liquids ...")
	for x in range(-75, 75):
		for z in range(-75, 75):
			if solidGridMap.get_cell_item(x, GenerationSettings.sea_level, z) == INVALID_CELL_ITEM && int(solidGridMap.solidGridMapNoise.get_noise_2d(x, z)*GenerationSettings.biomeType) < GenerationSettings.sea_level:
				placeBlock(Vector3(x, GenerationSettings.sea_level, z), blockList.liquid["water"])
	
	solidGridMap.generateBeach()