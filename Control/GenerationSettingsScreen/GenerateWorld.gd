extends Button

func _on_Button_pressed():
	# SolidGridMap seed value settings
	var seedValue = get_node("../../../Settings/ContainerRight/SeedValue").get_text()
	if seedValue != "": # Something written ?
		GenerationSettings.solidGridMapNoiseSeed = int(seedValue)
	
	# Biome type Settings
	var selectedBiome = get_node("../../../Settings/ContainerRight/BiomeType").get_selected_id()
	if selectedBiome == 0: # Flat
		GenerationSettings.biomeType = 0
	elif selectedBiome == 1: # Plain
		GenerationSettings.biomeType = 12.5
	else: # Hill
		GenerationSettings.biomeType = 25.0
		GenerationSettings.sea_level = -13
	get_tree().change_scene("res://Control/LoadingScreen/LoadingScreen.tscn")
