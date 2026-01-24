extends Node

# Hier speichern wir die aktuell ausgewählten Teile
# Wir geben Standardwerte vor, damit das Spiel nicht abstürzt, wenn man nichts wählt
var selected_chassis: CarChassisResource
var selected_wheels: CarWheelResource

# Platzhalter für später: Liste aller verfügbaren Teile für das Menü
var all_chassis = []
var all_wheels = []

func _input(event):
	if event.is_action_pressed("Reset Scene"):
		# Lädt die aktuell aktive Szene komplett neu
		get_tree().reload_current_scene()
