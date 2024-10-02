extends ProgressBar


func _physics_process(delta):
	var hunger = get_value() - 0.005
	set_value(hunger)
	if get_value() <= 0:
		get_tree().quit()