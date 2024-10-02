extends ProgressBar

func _physics_process(delta):
	if get_value() <= 0:
		get_tree().quit()
