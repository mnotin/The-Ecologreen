extends KinematicBody
class_name Player


# Declare member variables here
onready var oakSaplingScene = preload("res://Spatial/Items//OakSapling/OakSapling.tscn")
onready var head = get_node("Head") # Used to get head information : camera and RayCast

const GRAVITY : float = -9.81

var move_speed : int = 5
var jump_speed : float = sqrt(2*9.81*1.25) # sqrt(2*g*h), with h the height of the jump in meter(s)
var velocity : Vector3 = Vector3()
var rayCast : RayCast
var gridMapInteractionDelta : float 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rayCast = $Head/RayCast


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	gridMapInteractionDelta += delta
	
	if rayCast.is_colliding() && rayCast.get_collider().get_name() == "SolidGridMap": # Looking at a solid block ?
		rayCast.get_collider().get_node("../DebugGridMap").placeBlock((rayCast.get_collision_point()).floor(), rayCast.get_collision_normal().round(), 0, gridMapInteractionDelta)
	else:
		get_node("/root/Game/Spatial/GridMaps/DebugGridMap").clear() # Not looking at a solid block ?
	
	if gridMapInteractionDelta > 0.2 && (Input.is_mouse_button_pressed(BUTTON_LEFT) || Input.is_mouse_button_pressed(BUTTON_RIGHT)) && rayCast.is_colliding() && rayCast.get_collider().get_name() == "SolidGridMap":
		gridMapInteractionDelta = 0.0
	
	if Input.get_action_strength("move_sneak"): # Sneak
		$CollisionShape.shape.set_extents(Vector3(0.25, 0.7125, 0.25))
		move_speed = 2.5
	elif !Input.is_action_just_released("move_sneak"): # Stand up
		$CollisionShape.shape.set_extents(Vector3(0.25, 0.95, 0.25))
		move_speed = 5
	
# Called when the monitor is refreshed. 'delta' is the elapsed time since the previous refresh.
func _physics_process(delta : float) -> void:
	var direction : Vector3 = Vector3(0, 0, 0)
	var cam_xform = head.get_global_transform()
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if Input.is_key_pressed(KEY_Z):
			direction -= cam_xform.basis[2]
		if Input.is_key_pressed(KEY_Q):
			direction -= cam_xform.basis[0]
		if Input.is_key_pressed(KEY_S):
			direction += cam_xform.basis[2]
		if Input.is_key_pressed(KEY_D):
			direction += cam_xform.basis[0]
	
	direction.y = 0
	direction = direction.normalized()
	var horizontalVelocity = velocity
	horizontalVelocity.y = 0
	var target = direction * move_speed
	horizontalVelocity = horizontalVelocity.linear_interpolate(target, move_speed*delta)
	
	velocity.x = horizontalVelocity.x
	velocity.y += GRAVITY * delta
	
	if is_on_floor():
		velocity.y = 0
		if Input.get_action_strength("move_up"):
			velocity.y = jump_speed
	velocity.z = horizontalVelocity.z
	
	velocity = move_and_slide(velocity, Vector3(0,1,0))


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion: # Mouse motion
		# Move the head
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			head.rotate_x(deg2rad(event.relative.y * 0.05 * -1))
			rotate_y(deg2rad(event.relative.x * 0.05 * -1))
			
			var cameraRotation = head.rotation_degrees
			cameraRotation.x = clamp(cameraRotation.x, -89.9, 89.9)
			head.set_rotation_degrees(cameraRotation)
		
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			# Killing a goat
			if rayCast.is_colliding() && rayCast.get_collider() is Goat:
				var meat = load("res://Spatial/Items/Meat/Meat.tscn").instance()
				meat.set_translation(rayCast.get_collider().get_translation())
				get_node("/root/Game/Spatial").add_child(meat)
				rayCast.get_collider().free()
	
	
	if event is InputEventKey: # Keyboard event
		if Input.is_key_pressed(KEY_E): # Interaction with items
			print(rayCast.get_collider().get_name())
			if rayCast.is_colliding() && rayCast.get_collider() is OakSapling: # pick up a sapling ?
				if $Head/RightArm/Hand.get_child_count() == 0:
					var oakSapling = oakSaplingScene.instance()
					$Head/RightArm/Hand.add_child(oakSapling)
					rayCast.get_collider().free()
			elif rayCast.is_colliding() && rayCast.get_collider().get_name() == "SolidGridMap" && $Head/RightArm/Hand.get_child_count() == 1:
				var newTreePos = rayCast.get_collider().get_translation().round()
				$Head/RightArm/Hand/OakSapling.free()
				var oakSapling = oakSaplingScene.instance()
				oakSapling.set_translation(Vector3(rayCast.get_collision_point().x, rayCast.get_collision_point().y+0.25, rayCast.get_collision_point().z))
				oakSapling.set_mode(RigidBody.MODE_STATIC)
				get_node("/root/Game/Spatial").add_child(oakSapling)
			elif rayCast.is_colliding() && rayCast.get_collider() is Apple:
				rayCast.get_collider().free()
				get_node("/root/Game/Control/GameUI/CenterContainer2/Hunger").set_value(get_node("/root/Game/Control/GameUI/CenterContainer2/Hunger").get_value()+5)
				$EatingSound.play()
			elif rayCast.is_colliding() && rayCast.get_collider() is Meat: 
				rayCast.get_collider().free()
				get_node("/root/Game/Control/GameUI/CenterContainer2/Hunger").set_value(get_node("/root/Game/Control/GameUI/CenterContainer2/Hunger").get_value()+15)
				$EatingSound.play()
			elif rayCast.is_colliding() && rayCast.get_collider().get_name() == "FireArea": # Campfire
				if get_node("/root/Game/Control/GameUI/Wood/WoodAmount").get_value() > 0:
					get_node("/root/Game/Control/GameUI/Wood/WoodAmount").set_value(get_node("/root/Game/Control/GameUI/Wood/WoodAmount").get_value()-1)
					var omni_light = get_node("/root/Game/Spatial/GridMaps/SolidGridMap/Campfire/OmniLight")
					var fire_range = omni_light.get_param(3)
					if fire_range < 10:
						fire_range += 2
						omni_light.set_param(3, fire_range)
		
		
		# Capture or free the cursor
		if Input.is_action_just_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
