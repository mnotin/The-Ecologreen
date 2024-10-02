extends Node

onready var solidGridMap : GridMap = get_node("..")
onready var solidGridMapNoise : OpenSimplexNoise = get_node("..").solidGridMapNoise

const TRUNK_HEIGHT : int = 3
const FOLIAGE_HEIGHT : int = 2

var treesNoise : OpenSimplexNoise = OpenSimplexNoise.new()


func _ready() -> void:
	randomize()
	treesNoise.seed = randi()

func generateTrees() -> void:
	print("Planting trees ...")
	
	var treeSpacing : int = 0 # Avoid layers of trees
	var nextTree : int = randi() % 16 + 4
	var foliageCrown : int = 0
	
	for x in range(-75, 75):
		for z in range(-75, 75):
			if (x < -5 || x > 5) && (z < -5 || z > 5): # Avoid fire under the tree
				if treesNoise.get_noise_2d(x, z) > 0.0 && treeSpacing >= nextTree && int(solidGridMap.solidGridMapNoise.get_noise_2d(x, z)*GenerationSettings.biomeType) > -1:
					# Plant a tree
					treeSpacing = 0
					nextTree = randi() % 256 + 128
					
					# Place the foliage
					for yFoliage in range(int(solidGridMapNoise.get_noise_2d(x, z)*GenerationSettings.biomeType)+TRUNK_HEIGHT, int(solidGridMapNoise.get_noise_2d(x, z)*GenerationSettings.biomeType)+TRUNK_HEIGHT+FOLIAGE_HEIGHT+2):
						if yFoliage == (int(solidGridMapNoise.get_noise_2d(x, z)*GenerationSettings.biomeType)+TRUNK_HEIGHT+FOLIAGE_HEIGHT+1):
							foliageCrown = 1
						for xFoliage in range(x - FOLIAGE_HEIGHT + foliageCrown, x + FOLIAGE_HEIGHT + 1 - foliageCrown):
							for zFoliage in range(z - FOLIAGE_HEIGHT + foliageCrown, z + FOLIAGE_HEIGHT + 1 - foliageCrown):
								get_node("..").placeBlock(Vector3(xFoliage, yFoliage+1, zFoliage ), blockList.solid["oak_foliage"])
					
					# Place the trunk
					for yTrunk in range(TRUNK_HEIGHT+2):
						get_node("..").placeBlock(Vector3(x, int(solidGridMapNoise.get_noise_2d(x, z)*GenerationSettings.biomeType)+yTrunk+1, z), blockList.solid["oak_log"])
				foliageCrown = 0
				treeSpacing += 1

func plantTree(rootPos : Vector3) -> void:
	var foliageCrown : int = 0
	
	for yFoliage in range(rootPos.y+TRUNK_HEIGHT-1, rootPos.y+TRUNK_HEIGHT+FOLIAGE_HEIGHT+1):
		if yFoliage == (rootPos.y+TRUNK_HEIGHT+FOLIAGE_HEIGHT):
			foliageCrown = 1
		for xFoliage in range(rootPos.x - FOLIAGE_HEIGHT + foliageCrown, rootPos.x + FOLIAGE_HEIGHT + 1 - foliageCrown):
			for zFoliage in range(rootPos.z - FOLIAGE_HEIGHT + foliageCrown, rootPos.z + FOLIAGE_HEIGHT + 1 - foliageCrown):
				get_node("..").placeBlock(Vector3(xFoliage, yFoliage+1, zFoliage ), blockList.solid["oak_foliage"])
		foliageCrown = 0
		
	# Delete the trunk
	for yTrunk in range(TRUNK_HEIGHT+2):
		get_node("..").placeBlock(Vector3(rootPos.x, rootPos.y + yTrunk, rootPos.z), blockList.solid["oak_log"])

func eatTree(rootPos : Vector3) -> bool:
	var foliageCrown : int = 0
	var loot : bool = false
	
	for yFoliage in range(rootPos.y+TRUNK_HEIGHT-1, rootPos.y+TRUNK_HEIGHT+FOLIAGE_HEIGHT+1):
		if yFoliage == (rootPos.y+TRUNK_HEIGHT+FOLIAGE_HEIGHT+1):
			foliageCrown = 1
		for xFoliage in range(rootPos.x - FOLIAGE_HEIGHT + foliageCrown, rootPos.x + FOLIAGE_HEIGHT + 1 - foliageCrown):
			for zFoliage in range(rootPos.z - FOLIAGE_HEIGHT + foliageCrown, rootPos.z + FOLIAGE_HEIGHT + 1 - foliageCrown):
				if solidGridMap.get_cell_item(xFoliage, yFoliage + 1, zFoliage) == blockList.solid["oak_foliage"]:
					loot = true
					get_node("..").placeBlock(Vector3(xFoliage, yFoliage+1, zFoliage ), GridMap.INVALID_CELL_ITEM)
		foliageCrown = 0
		
	# Delete the trunk
	for yTrunk in range(TRUNK_HEIGHT+2):
		get_node("..").placeBlock(Vector3(rootPos.x, rootPos.y + yTrunk, rootPos.z), blockList.solid["oak_log"])
	
	if loot: # Does the tree have a foliage ?
		# Drop an oak sapling
		var oakSapling = load("res://Spatial/Items/OakSapling/OakSapling.tscn").instance()
		oakSapling.set_translation(Vector3(rootPos.x+1, rootPos.y+4, rootPos.z))
		get_node("/root/Game/Spatial").add_child(oakSapling)
		
		var apple = load("res://Spatial/Items/Apple/Apple.tscn").instance()
		apple.set_translation(Vector3(rootPos.x+1, rootPos.y+4, rootPos.z))
		get_node("/root/Game/Spatial").add_child(apple)
	
	return loot
	