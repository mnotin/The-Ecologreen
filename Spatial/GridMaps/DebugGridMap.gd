extends GridMap

# Signal
# Onready
# Export
# Const

# Declare member variables here
onready var solidGridMap = get_node("../SolidGridMap")

var blockPosition : Vector3
var lastBlockPosition : Vector3


func placeBlock(coordinates : Vector3, collisionNormal : Vector3, item : int, gridMapInteractionDelta : float) -> void:
	clear() # Display only one collision shape at the time

	# Display collision shape of aimed block
	if collisionNormal.x == 1 && solidGridMap.get_cell_item(coordinates.x-1, coordinates.y, coordinates.z) != INVALID_CELL_ITEM: # Aiming at something ?
		blockPosition = Vector3(coordinates.x-1, coordinates.y, coordinates.z) # In case place or break a solid block
		set_cell_item(int(coordinates.x-1), int(coordinates.y), int(coordinates.z), item) # Place the collision shape
		lastBlockPosition = Vector3(coordinates.x-1, coordinates.y, coordinates.z) # Edge issue
	elif collisionNormal.x == -1 && solidGridMap.get_cell_item(coordinates.x+1, coordinates.y, coordinates.z) != INVALID_CELL_ITEM: # Aiming at something ?
		blockPosition = Vector3(coordinates.x+1, coordinates.y, coordinates.z) # In case place or break a solid block
		set_cell_item(int(coordinates.x+1), int(coordinates.y), int(coordinates.z), item) # Place the collision shape
		lastBlockPosition = Vector3(coordinates.x+1, coordinates.y, coordinates.z) # Edge issue
	elif collisionNormal.y == 1 && solidGridMap.get_cell_item(coordinates.x, coordinates.y-1, coordinates.z) != INVALID_CELL_ITEM: # Aiming at something ?
		blockPosition = Vector3(coordinates.x, coordinates.y-1, coordinates.z) # In case place or break a solid block
		set_cell_item(int(coordinates.x), int(coordinates.y-1), int(coordinates.z), item) # Place the collision shape
		lastBlockPosition = Vector3(coordinates.x, coordinates.y-1, coordinates.z) # Edge issue
	elif collisionNormal.y == -1 && solidGridMap.get_cell_item(coordinates.x, coordinates.y+1, coordinates.z) != INVALID_CELL_ITEM: # Aiming at something ?
		blockPosition = Vector3(coordinates.x, coordinates.y+1, coordinates.z) # In case place or break a solid block
		set_cell_item(int(coordinates.x), int(coordinates.y+1), int(coordinates.z), item) # Place the collision shape
		lastBlockPosition = Vector3(coordinates.x, coordinates.y+1, coordinates.z) # Edge issue
	elif collisionNormal.z == 1 && solidGridMap.get_cell_item(coordinates.x, coordinates.y, coordinates.z-1) != INVALID_CELL_ITEM: # Aiming at something ?
		blockPosition = Vector3(coordinates.x, coordinates.y, coordinates.z-1) # In case place or break a solid block
		set_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z-1), item) # Place the collision shape
		lastBlockPosition = Vector3(coordinates.x, coordinates.y, coordinates.z-1) # Edge issue
	elif collisionNormal.z == -1 && solidGridMap.get_cell_item(coordinates.x, coordinates.y, coordinates.z+1) != INVALID_CELL_ITEM: # Aiming at something ?
		blockPosition = Vector3(coordinates.x, coordinates.y, coordinates.z+1) # In case place or break a solid block
		set_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z+1), item) # Place the collision shape
		lastBlockPosition = Vector3(coordinates.x, coordinates.y, coordinates.z+1) # Edge issue
	elif lastBlockPosition != null: # Edge issue
		blockPosition = Vector3(lastBlockPosition.x, lastBlockPosition.y, lastBlockPosition.z) # In case place or break a solid block
		set_cell_item(int(lastBlockPosition.x), int(lastBlockPosition.y), int(lastBlockPosition.z), item) # Place the collision shape
	
	# Place a solid block
	if Input.is_mouse_button_pressed(BUTTON_RIGHT) && gridMapInteractionDelta > 0.2: # Raycast already colliding since we're here
			get_node("/root/Game/Spatial/Player/Head/RightArm/Interact").play("Interact")
			solidGridMap.placeBlock(blockPosition, 0, collisionNormal)
	
	
	# Break a solid block
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && gridMapInteractionDelta > 0.2: # Raycast already colliding since we're here
			get_node("/root/Game/Spatial/Player/Head/RightArm/Interact").play("Interact")
			if solidGridMap.get_cell_item(blockPosition.x, blockPosition.y, blockPosition.z) == blockList.solid["oak_log"]:
				get_node("/root/Game/Control/GameUI/Wood/WoodAmount").set_value(get_node("/root/Game/Control/GameUI/Wood/WoodAmount").get_value()+1)
			solidGridMap.placeBlock(blockPosition, INVALID_CELL_ITEM)