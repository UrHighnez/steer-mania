extends Control

# Referenz zum Auto in der Garage (Zieh den Assembler-Node vom Auto hier rein!)
@export var car_assembler: CarAssembler

# Die Bauteile (Zieh deine .tres Dateien hier rein!)
@export_group("Teile")
@export var chassis_light: CarChassisResource
@export var chassis_heavy: CarChassisResource
@export var wheel_wood: CarWheelResource
@export var wheel_rubber: CarWheelResource

# Pfad zur Rennstrecke (Zieh die .tscn Datei hier rein oder kopier den Pfad)
@export_file("*.tscn") var race_scene_path

func _ready():
	# Wenn wir die Garage betreten: Lade die aktuelle Auswahl
	if GameManager.selected_chassis:
		car_assembler._apply_chassis(GameManager.selected_chassis)
	if GameManager.selected_wheels:
		car_assembler._apply_wheels(GameManager.selected_wheels)

# --- BUTTON SIGNALS ---
# Verbinde diese Funktionen über den Node-Tab mit den Buttons!

func _on_btn_light_pressed():
	# 1. Im globalen Speicher merken
	GameManager.selected_chassis = chassis_light
	# 2. Direkt am Auto anwenden (Vorschau)
	car_assembler._apply_chassis(chassis_light)

func _on_btn_heavy_pressed():
	GameManager.selected_chassis = chassis_heavy
	car_assembler._apply_chassis(chassis_heavy)

func _on_btn_wood_pressed():
	GameManager.selected_wheels = wheel_wood
	car_assembler._apply_wheels(wheel_wood)

func _on_btn_rubber_pressed():
	GameManager.selected_wheels = wheel_rubber
	car_assembler._apply_wheels(wheel_rubber)

func _on_btn_start_race_pressed():
	if race_scene_path:
		var fehler = get_tree().change_scene_to_file(race_scene_path)
		if fehler != OK:
			print("Fehler beim Laden: ", fehler)
	else:
		print("FEHLER: Kein Pfad zugewiesen!")
