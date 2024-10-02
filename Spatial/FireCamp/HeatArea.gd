extends Area

func _physics_process(delta):
	var heat_bar = get_node("/root/Game/Control/GameUI/CenterContainer3/Heat")
	var heat_value = heat_bar.get_value() - 0.005
	if overlaps_body(get_node("/root/Game/Spatial/Player")) && heat_bar.get_value() < 100 && \
	get_node("../Particles").is_emitting():
		heat_value = heat_bar.get_value() + 0.01
	heat_bar.set_value(heat_value)
	if heat_bar.get_value() <= 0:
		get_tree().quit()
