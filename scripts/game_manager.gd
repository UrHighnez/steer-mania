extends Node

# Variablen für die Auswahl (Starten als 'null')
var selected_chassis: CarChassisResource
var selected_wheels: CarWheelResource
var selected_propulsion: CarPropulsionResource

func _ready():
	# --- TEST CODE: HIER PFAD ZU DEINER RESSOURCE EINTRAGEN ---
	# Rechtsklick auf die .tres Datei -> "Copy Path", dann hier einfügen
	if selected_propulsion == null:
		selected_propulsion = load("res://resources/propulsion_basic.tres")
		print("DEBUG: Test-Rakete wurde geladen!")

func _input(event):
	# Globaler Reset-Knopf für alle Szenen
	if event.is_action_pressed("Reset Scene"):
		get_tree().reload_current_scene()
