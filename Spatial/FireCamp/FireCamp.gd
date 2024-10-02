extends Spatial
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var fire_range = $OmniLight.get_param(3)
	if fire_range > 0:
		$Particles.set_emitting(true)
		fire_range -= 0.0005
		$OmniLight.set_param(3, fire_range)
	else:
		$Particles.set_emitting(false)
	
#	var light = $OmniLight.get_param(0)
#	light -= 0.01
#	$OmniLight.set_param(0, light)
