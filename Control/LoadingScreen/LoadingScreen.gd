extends Control

func _on_Timer_timeout(): # In order to display the "Loading" message
	get_tree().change_scene("res://Game.tscn")
