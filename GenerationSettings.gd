extends Node

# Declare member variables here.
var solidGridMapNoiseSeed
var biomeType : float # Used during solidGridMap generation
var sea_level = -4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	solidGridMapNoiseSeed = randi() % int(pow(100000.0, 100000.0))