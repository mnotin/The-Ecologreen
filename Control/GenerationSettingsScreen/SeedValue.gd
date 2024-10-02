extends LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	set_text(str(GenerationSettings.solidGridMapNoiseSeed))
