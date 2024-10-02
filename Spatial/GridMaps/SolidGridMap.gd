extends GridMap

# Signal
# Onready
# Export
# Const

# Declare member variables here.
onready var gasGridMap : Node = get_node("../GasGridMap")
onready var playerScene : PackedScene = preload("res://Spatial/Entities/Player/Player.tscn")
onready var campfire_scene : PackedScene = preload("res://Spatial/FireCamp/Campfire.tscn")

var solidGridMapNoise : OpenSimplexNoise = OpenSimplexNoise.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Configure solidGridMapNoise
	randomize()
	solidGridMapNoise.seed = GenerationSettings.solidGridMapNoiseSeed
	
	generateSolidWorld()
	get_node("../LiquidGridMap").generateLiquidWorld()
	$GenerateVegetation.generateTrees()
	
	var campfire = campfire_scene.instance()
	campfire.set_translation(Vector3(0.5, int(solidGridMapNoise.get_noise_2d(0, 0))+1.0625, 0.5))
	add_child(campfire)
	
	
	
	# Add player to the main scene
	print("Adding player to the world ...")
	var player = playerScene.instance()
	player.set_translation(Vector3(0, 2+solidGridMapNoise.get_noise_2d(0, 0)*12.5, 0))
	get_node("/root/Game/Spatial").call_deferred("add_child", player) # Because parent node is busy setting up children


func placeBlock(coordinates : Vector3, item : int, collisionNormal : Vector3 = Vector3(0, 0, 0)) -> void:
	var liquidGridMap : GridMap = get_node("../LiquidGridMap")
	
	if collisionNormal != Vector3(0, 0, 0): # Player wants to place a block ?
		var playerPosFeet : Vector3 = get_node("/root/Game/Spatial/Player").get_translation().floor()
		var playerPosHead : Vector3 = get_node("/root/Game/Spatial/Player").get_translation().floor()
		playerPosHead.y += 1
		
		if collisionNormal.x == 1 && playerPosFeet != Vector3(coordinates.x+1, coordinates.y, coordinates.z) && playerPosHead != Vector3(coordinates.x+1, coordinates.y, coordinates.z):
			set_cell_item(int(coordinates.x+1), int(coordinates.y), int(coordinates.z), item)
			if int(coordinates.y) == -1: # Need to delete liquid ?
				liquidGridMap.placeBlock(Vector3(coordinates.x+1, -1, coordinates.z), INVALID_CELL_ITEM)
		if collisionNormal.x == -1 && playerPosFeet != Vector3(coordinates.x-1, coordinates.y, coordinates.z) && playerPosHead != Vector3(coordinates.x-1, coordinates.y, coordinates.z):
			set_cell_item(int(coordinates.x-1), int(coordinates.y), int(coordinates.z), item)
			if int(coordinates.y) == -1: # Need to delete liquid ?
				liquidGridMap.placeBlock(Vector3(coordinates.x-1, -1, coordinates.z), INVALID_CELL_ITEM)
		if collisionNormal.y == 1 && playerPosFeet != Vector3(coordinates.x, coordinates.y+1, coordinates.z) && playerPosHead != Vector3(coordinates.x, coordinates.y+1, coordinates.z): # Looking at the top
			set_cell_item(int(coordinates.x), int(coordinates.y+1), int(coordinates.z), item)
			if int(coordinates.y+1) == -1: # Need to delete liquid ?
				liquidGridMap.placeBlock(Vector3(coordinates.x, -1, coordinates.z), INVALID_CELL_ITEM)
		if collisionNormal.y == -1 && playerPosFeet != Vector3(coordinates.x, coordinates.y-1, coordinates.z) && playerPosHead != Vector3(coordinates.x, coordinates.y-1, coordinates.z): # Looking at the bottom
			set_cell_item(int(coordinates.x), int(coordinates.y-1), int(coordinates.z), item)
			if int(coordinates.y-1) == -1: # Need to delete liquid ?
				liquidGridMap.placeBlock(Vector3(coordinates.x, -1, coordinates.z), INVALID_CELL_ITEM)
		if collisionNormal.z == 1 && playerPosFeet != Vector3(coordinates.x, coordinates.y, coordinates.z+1) && playerPosHead != Vector3(coordinates.x, coordinates.y, coordinates.z+1):
			set_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z+1), item)
			if int(coordinates.y) == -1: # Need to delete liquid ?
				liquidGridMap.placeBlock(Vector3(coordinates.x, -1, coordinates.z+1), INVALID_CELL_ITEM)
		if collisionNormal.z == -1 && playerPosFeet != Vector3(coordinates.x, coordinates.y, coordinates.z-1) && playerPosHead != Vector3(coordinates.x, coordinates.y, coordinates.z-1):
			set_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z-1), item)
			if int(coordinates.y) == -1: # Need to delete liquid ?
				liquidGridMap.placeBlock(Vector3(coordinates.x, -1, coordinates.z-1), INVALID_CELL_ITEM)
	
	elif item == INVALID_CELL_ITEM: # Remove block ?
		# Fill holes
		if gasGridMap.get_cell_item(int(coordinates.x-1), int(coordinates.y), int(coordinates.z)) == INVALID_CELL_ITEM && coordinates.y < getNoise(coordinates.x-1, coordinates.z):
			set_cell_item(int(coordinates.x-1), int(coordinates.y), int(coordinates.z), 0) # Plug the hole
		if gasGridMap.get_cell_item(int(coordinates.x+1), int(coordinates.y), int(coordinates.z)) == INVALID_CELL_ITEM && coordinates.y < getNoise(coordinates.x+1, coordinates.z):
			set_cell_item(int(coordinates.x+1), int(coordinates.y), int(coordinates.z), 0) # Plug the hole
		if gasGridMap.get_cell_item(int(coordinates.x), int(coordinates.y-1), int(coordinates.z)) == INVALID_CELL_ITEM && (coordinates.y-1) < getNoise(coordinates.x, coordinates.z):
			set_cell_item(int(coordinates.x), int(coordinates.y-1), int(coordinates.z), 0) # Plug the hole
		if gasGridMap.get_cell_item(int(coordinates.x), int(coordinates.y+1), int(coordinates.z)) == INVALID_CELL_ITEM && (coordinates.y+1) < getNoise(coordinates.x, coordinates.z):
			set_cell_item(int(coordinates.x), int(coordinates.y+1), int(coordinates.z), 0) # Plug the hole
		if gasGridMap.get_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z-1)) == INVALID_CELL_ITEM && coordinates.y < getNoise(coordinates.x, coordinates.z-1):
			set_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z-1), 0) # Plug the hole
		if gasGridMap.get_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z+1)) == INVALID_CELL_ITEM && coordinates.y < getNoise(coordinates.x, coordinates.z+1):
			set_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z+1), 0) # Plug the hole
		
		gasGridMap.placeBlock(coordinates, 0) # Tell the gasGridMap that you've placed a block here once
		set_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z), INVALID_CELL_ITEM) # Delete the wanted block
		get_node("../DebugGridMap").lastBlockPosition = Vector3() # Delete the collision shape of the block you have broken
		
		# Water physics
		if liquidGridMap.get_cell_item(coordinates.x-1, -1, coordinates.z) == blockList.liquid["water"]:
			liquidGridMap.placeBlock(Vector3(coordinates.x, GenerationSettings.sea_level, coordinates.z), blockList.liquid["water"])
		if liquidGridMap.get_cell_item(coordinates.x+1, GenerationSettings.sea_level, coordinates.z) == blockList.liquid["water"]:
			liquidGridMap.placeBlock(Vector3(coordinates.x, GenerationSettings.sea_level, coordinates.z), blockList.liquid["water"])
		if liquidGridMap.get_cell_item(coordinates.x-1, GenerationSettings.sea_level, coordinates.z+1) == blockList.liquid["water"]:
			liquidGridMap.placeBlock(Vector3(coordinates.x, GenerationSettings.sea_level, coordinates.z), blockList.liquid["water"])
		if liquidGridMap.get_cell_item(coordinates.x+1, GenerationSettings.sea_level, coordinates.z+1) == blockList.liquid["water"]:
			liquidGridMap.placeBlock(Vector3(coordinates.x, GenerationSettings.sea_level, coordinates.z), blockList.liquid["water"])
		if liquidGridMap.get_cell_item(coordinates.x, -1, coordinates.z-1) == blockList.liquid["water"]:
			liquidGridMap.placeBlock(Vector3(coordinates.x, GenerationSettings.sea_level, coordinates.z), blockList.liquid["water"])
		if liquidGridMap.get_cell_item(coordinates.x, GenerationSettings.sea_level, coordinates.z+1) == blockList.liquid["water"]:
			liquidGridMap.placeBlock(Vector3(coordinates.x, GenerationSettings.sea_level, coordinates.z), blockList.liquid["water"])
		if liquidGridMap.get_cell_item(coordinates.x-1, GenerationSettings.sea_level, coordinates.z-1) == blockList.liquid["water"]:
			liquidGridMap.placeBlock(Vector3(coordinates.x, GenerationSettings.sea_level, coordinates.z), blockList.liquid["water"])
		if liquidGridMap.get_cell_item(coordinates.x+1, GenerationSettings.sea_level, coordinates.z-1) == blockList.liquid["water"]:
			liquidGridMap.placeBlock(Vector3(coordinates.x, GenerationSettings.sea_level, coordinates.z-1), blockList.liquid["water"])
		
		
		
	else: # Place a block from code ?
		set_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z), item) # Place the wanted block


func getNoise(blockPositionX, blockPositionZ) -> int:
	return int(solidGridMapNoise.get_noise_2d(blockPositionX, blockPositionZ)*GenerationSettings.biomeType)

func generateSolidWorld() -> void:
	# Place grass blocks
	print("Generating map ...")
	for z in range(-75, 75):
		for x in range(-75, 75):
			placeBlock(Vector3(x, int(solidGridMapNoise.get_noise_2d(x, z)*GenerationSettings.biomeType), z), blockList.solid["grass"])
	
func generateBeach() -> void:
	var liquidGridMap : GridMap = get_node("../LiquidGridMap")

	# Place sans blocks
	print("Generating beach ...")
	for x in range(-75, 75):
		for z in range(-75, 75):
			if liquidGridMap.get_cell_item(x, GenerationSettings.sea_level, z) == INVALID_CELL_ITEM: # Do not place on water
				if liquidGridMap.get_cell_item(x-1, GenerationSettings.sea_level, z) == blockList.liquid["water"]:
					placeBlock(Vector3(x, GenerationSettings.sea_level, z), blockList.solid["sand"])
				if liquidGridMap.get_cell_item(x+1, GenerationSettings.sea_level, z) == blockList.liquid["water"]:
					placeBlock(Vector3(x, GenerationSettings.sea_level, z), blockList.solid["sand"])
				if liquidGridMap.get_cell_item(x-1, GenerationSettings.sea_level, z+1) == blockList.liquid["water"]:
					placeBlock(Vector3(x, GenerationSettings.sea_level, z), blockList.solid["sand"])
				if liquidGridMap.get_cell_item(x+1, GenerationSettings.sea_level, z+1) == blockList.liquid["water"]:
					placeBlock(Vector3(x, GenerationSettings.sea_level, z), blockList.solid["sand"])
				if liquidGridMap.get_cell_item(x, GenerationSettings.sea_level, z-1) == blockList.liquid["water"]:
					placeBlock(Vector3(x, GenerationSettings.sea_level, z), blockList.solid["sand"])
				if liquidGridMap.get_cell_item(x, GenerationSettings.sea_level, z+1) == blockList.liquid["water"]:
					placeBlock(Vector3(x, GenerationSettings.sea_level, z), blockList.solid["sand"])
				if liquidGridMap.get_cell_item(x-1, GenerationSettings.sea_level, z-1) == blockList.liquid["water"]:
					placeBlock(Vector3(x, GenerationSettings.sea_level, z), blockList.solid["sand"])
				if liquidGridMap.get_cell_item(x+1, GenerationSettings.sea_level, z-1) == blockList.liquid["water"]:
					placeBlock(Vector3(x, GenerationSettings.sea_level, z-1), blockList.solid["sand"])
