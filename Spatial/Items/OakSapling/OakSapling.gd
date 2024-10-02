extends RigidBody
class_name OakSapling

func _process(delta):
	if get_mode() == MODE_STATIC && $Grow.get_time_left() == 0:
		$Grow.start()
		$Wind.show()

func _physics_process(delta):
	if $Grow.get_time_left() != 0:
		var current_scale = get_scale()
		current_scale.y += 0.001
		set_scale(current_scale)

func _on_Grow_timeout():
	get_node("/root/Game/Spatial/GridMaps/SolidGridMap/GenerateVegetation").plantTree(get_translation().floor())
	queue_free()
