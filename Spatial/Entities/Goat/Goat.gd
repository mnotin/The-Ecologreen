extends KinematicBody
class_name Goat

# Signal
# Onready
# Export
# Const

# Declare member variables here
const GRAVITY : float = -9.81

onready var solidGridMap : GridMap = get_node("/root/Game/Spatial/GridMaps/SolidGridMap")
onready var rayCast : RayCast = get_node("RayCast")
onready var walkingTimer : Timer = get_node("MovingTime/Walking")
onready var rotatingTimer : Timer = get_node("MovingTime/Rotating")
onready var idlingTimer : Timer = get_node("MovingTime/Idling")
onready var nextBleatTimer : Timer = get_node("NextBleat")
onready var satietyTimer : Timer = get_node("Satiety")

var velocity : Vector3 = Vector3(0, 0, 0)
var moveSpeed : int = 2.5
var jumpSpeed : float = sqrt(2*9.81*1.25) # sqrt(2*g*h), with h the height of the jump in meter(s)


var walkingTime : int
var wereWalking : bool
var rotatingTime : float
var rotate : bool
var idlingTime : int
var wereIdling : bool
var nextBleatTime : int

var satietyTime : int
var lastAnalysedBlockPos : Vector3



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	idling() # Begin by idling
	bleat()
	
	# Initialize satiety timer
	randomize()
	satietyTime = randi() % 10 + 5
	satietyTimer.set_wait_time(satietyTime)
	satietyTimer.start()


# Called when the monitor is refreshed. 'delta' is the elapsed time since the previous refresh.
func _physics_process(delta)-> void:
	var direction : Vector3 = Vector3(0, 0, 0)
	var cam_xform = get_global_transform()
	
	if idlingTimer.get_time_left() == 0 && walkingTimer.get_time_left() == 0 && wereIdling && rotatingTimer.get_time_left() == 0: # Finish idling ? So rotate or walk !
		if rotate: # Did it decide to rotate this time ?
			rotate = false
			rotating() # How long should it rotate ?
		else: # Did it decide to not rotate ?
			walking() # How long should it walk ?
	if walkingTimer.get_time_left() == 0 && idlingTimer.get_time_left() == 0 && wereWalking: # Finish walking ? So have a rest !
		idling()
	
	if $OnWater.is_colliding() && $OnWater.get_collider().get_name() == "LiquidGridMap" && is_on_floor():
		velocity.y = jumpSpeed
	
	#get_colliding_block_name(analyserRaycast.get_collision_point().floor(), analyserRaycast.get_collision_normal().round()) == blockList.solid["sand"] || \
	if rotatingTimer.get_time_left() > 0 || !get_node("HeadRayCasts/RayCastVoid").is_colliding() || get_node("HeadRayCasts/RayCastWall").is_colliding(): # In rotating process ?
		if satietyTimer.get_time_left() > 0 || \
		satietyTimer.get_time_left() == 0 && get_colliding_block_name(rayCast.get_collision_point().floor(), rayCast.get_collision_normal().round()) != blockList.solid["oak_log"]:
			rotate_y(deg2rad(2))
		
	if walkingTimer.get_time_left() > 0 || rotatingTimer.get_time_left() > 0: # Is moving ?
		$BodyMesh/Walking.play("Walking") # Play the moving animation
	
#	print(get_colliding_block_name(rayCast.get_collision_point().floor(), rayCast.get_collision_normal().round()))
	if satietyTimer.get_time_left() == 0 && rayCast.is_colliding(): # Hungry ?
		if get_colliding_block_name(rayCast.get_collision_point().floor(), rayCast.get_collision_normal().round()) == blockList.solid["oak_log"]:
			eat()
	
	if walkingTimer.get_time_left() > 0 && get_node("HeadRayCasts/RayCastVoid").is_colliding() && !$BodyMesh/Eating.is_playing(): # In walking process ?
		direction -= cam_xform.basis[0]
	
	direction.y = 0
	direction = direction.normalized()
	var horizontalVelocity = velocity
	horizontalVelocity.y = 0
	var target = direction * moveSpeed
	horizontalVelocity = horizontalVelocity.linear_interpolate(target, moveSpeed*delta)
	
	velocity.x = horizontalVelocity.x
	velocity.y += GRAVITY * delta
	if is_on_floor() && rayCast.is_colliding() && rayCast.get_collider().get_name() == "SolidGridMap" && walkingTimer.get_time_left() > 0 && !get_node("HeadRayCasts/RayCastWall").is_colliding():
		if satietyTimer.get_time_left() > 0 || !$BodyMesh/Eating.is_playing() && satietyTimer.get_time_left() == 0 && \
		get_colliding_block_name(rayCast.get_collision_point().floor(), rayCast.get_collision_normal().round()) != blockList.solid["oak_log"]:
			velocity.y = jumpSpeed
	velocity.z = horizontalVelocity.z
	
	velocity = move_and_slide(velocity, Vector3(0,1,0))


# What block is it colliding with ?
func get_colliding_block_name(coordinates : Vector3, collisionNormal : Vector3) -> int:
	if collisionNormal.x == 1 && solidGridMap.get_cell_item(int(coordinates.x-1), int(coordinates.y), int(coordinates.z)) != GridMap.INVALID_CELL_ITEM: # Aiming at something ?
		lastAnalysedBlockPos = Vector3(coordinates.x-1, coordinates.y, coordinates.z)
		return solidGridMap.get_cell_item(int(coordinates.x-1), int(coordinates.y), int(coordinates.z))
	elif collisionNormal.x == -1 && solidGridMap.get_cell_item(int(coordinates.x+1), int(coordinates.y), int(coordinates.z)) != GridMap.INVALID_CELL_ITEM: # Aiming at something ?
		lastAnalysedBlockPos = Vector3(coordinates.x+1, coordinates.y, coordinates.z)
		return solidGridMap.get_cell_item(int(coordinates.x+1), int(coordinates.y), int(coordinates.z))
	elif collisionNormal.y == 1 && solidGridMap.get_cell_item(int(coordinates.x), int(coordinates.y-1), int(coordinates.z)) != GridMap.INVALID_CELL_ITEM: # Aiming at something ?
		lastAnalysedBlockPos = Vector3(coordinates.x, coordinates.y-1, coordinates.z)
		return solidGridMap.get_cell_item(int(coordinates.x), int(coordinates.y-1), int(coordinates.z))
	elif collisionNormal.z == 1 && solidGridMap.get_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z-1)) != GridMap.INVALID_CELL_ITEM: # Aiming at something ?
		lastAnalysedBlockPos = Vector3(coordinates.x, coordinates.y, coordinates.z-1)
		return solidGridMap.get_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z-1))
	elif collisionNormal.z == -1 && solidGridMap.get_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z+1)) != GridMap.INVALID_CELL_ITEM: # Aiming at something ?
		lastAnalysedBlockPos = Vector3(coordinates.x, coordinates.y, coordinates.z+1)
		return solidGridMap.get_cell_item(int(coordinates.x), int(coordinates.y), int(coordinates.z+1))
	else: # Edge issue
		return GridMap.INVALID_CELL_ITEM


# How long should it walk ?
func walking() -> void:
	wereIdling = false
	wereWalking = true
	
	randomize()
	walkingTime = randi() % 15 + 7
	walkingTimer.set_wait_time(walkingTime)
	walkingTimer.start()


# How long should it rotate ?
func rotating() -> void:
	randomize()
	rotatingTime = randf() * 2.0 
	rotatingTimer.set_wait_time(rotatingTime)
	rotatingTimer.start()


# How long should it idle ?
func idling() -> void:
	wereWalking = false
	wereIdling = true
	
	randomize()
	idlingTime = randi() % 15 + 7
	idlingTimer.set_wait_time(idlingTime)
	idlingTimer.start()
	
	rotate = randi() % 2

# Eat and how long should it be replete ?
func eat() -> void:
	# Eating process
	$BodyMesh/Eating.play("Eating")
	var spawnBaby = get_node("/root/Game/Spatial/GridMaps/SolidGridMap/GenerateVegetation").eatTree(lastAnalysedBlockPos)
	
	if spawnBaby:
		# Make a baby
		var babyGoat = load("res://Spatial/Entities/Goat/Goat.tscn").instance()
		babyGoat.set_translation(Vector3(get_translation().x, get_translation().y+2, get_translation().z))
		babyGoat.set_scale(Vector3(0.5, 0.5, 0.5))
		get_node("/root/Game/Spatial/Animals/Goats").add_child(babyGoat)
	
		# Grow
		self.set_scale(Vector3(1, 1, 1))
	
	randomize()
	satietyTime = randi() % 60 + 30
	satietyTimer.set_wait_time(satietyTime)
	satietyTimer.start()


func bleat() -> void:
	$Bleating.play()
	
	randomize()
	nextBleatTime = randi() % 15 + 10
	nextBleatTimer.set_wait_time(nextBleatTime)
	nextBleatTimer.start()

func _on_NextBleat_timeout():
	bleat()
