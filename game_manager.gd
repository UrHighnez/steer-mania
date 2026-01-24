extends Node

func _input(event):
	if event.is_action_pressed("Reset Scene"):
		# Lädt die aktuell aktive Szene komplett neu
		get_tree().reload_current_scene()
