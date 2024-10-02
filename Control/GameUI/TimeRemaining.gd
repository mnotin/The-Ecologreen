extends Label

var timeRemaining = 0

func _process(delta):
	set_text("Time survived : " + str(int(timeRemaining/60/60)) + " h")
	timeRemaining += delta * 144

