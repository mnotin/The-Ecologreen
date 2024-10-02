extends DirectionalLight

var environment : Object = preload("res://default_env.tres")
var sunLatitude : float = 0

func _physics_process(delta) -> void:
	
	rotate_x(-deg2rad(sunLatitude))
	environment.background_sky.set_sun_latitude(get_rotation_degrees().x + 180)
	
	sunLatitude = delta * (180.0/600.0)# 180.0 / day (or night) in seconds .0
