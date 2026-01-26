extends Node3D

@onready var win_label = $HUD/Label # Pfad zu deinem Label anpassen!
@onready var finish_line = $"Track/Finish Area" # Pfad zu deiner Area3D anpassen!

# Hier den Pfad zu deiner Garage-Szene eintragen (Rechtsklick auf Datei -> Copy Path)
@export_file("*.tscn") var garage_scene_path: String

func _ready():
	# Wir verbinden das Signal der Ziellinie via Code (sauberer als im Editor)
	# "body_entered" ist das Signal, das feuert, wenn was in die Area fliegt
	finish_line.body_entered.connect(_on_finish_line_entered)

func _process(delta):
	# ESC Taste Logik (Standardmäßig ist ui_cancel auf ESC gemappt)
	if Input.is_action_just_pressed("Exit"):
		go_to_garage()

func _on_finish_line_entered(body):
	# Wir prüfen, ob das Objekt, das durchgefahren ist, in der Gruppe "player" ist
	if body.is_in_group("player"):
		game_won()

func game_won():
	print("Ziel erreicht!")
	win_label.show() # Text anzeigen
	
	# Optional: Spiel pausieren, damit man nicht weiterfährt
	# get_tree().paused = true 

func go_to_garage():
	# Optional: Pause aufheben, falls gesetzt, sonst bleibt das Menü auch pausiert
	# get_tree().paused = false
	
	if garage_scene_path == "":
		printerr("FEHLER: Kein Pfad zur Garage im Inspektor zugewiesen!")
		return
		
	get_tree().change_scene_to_file(garage_scene_path)
