extends Node

# Variablen für die Auswahl (Starten als 'null')
var selected_chassis: CarChassisResource
var selected_wheels: CarWheelResource

func _input(event):
	# Globaler Reset-Knopf für alle Szenen
	if event.is_action_pressed("Reset Scene"):
		get_tree().reload_current_scene()
