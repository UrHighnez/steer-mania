extends Resource
class_name CarChassisResource

@export_group("Optik")
@export var display_name: String = ""
@export var chassis_scene: PackedScene # Hier ziehen wir später eine .tscn rein

@export_group("Physik")
@export var mass: float = 40.0 # Gewicht ist entscheidend für Speed bergab!
# Optional: Aerodynamik-Faktor könnte hier später rein

@export_group("Rad-Positionen")
# Wo sitzen die Räder relativ zur Mitte? (x ist breite, z ist länge)
# Standardwerte für eine normale Seifenkiste
@export var front_axle_offset: float = -0.8 # Wie weit vorne (negativ z oft in Godot)
@export var back_axle_offset: float = 0.8   # Wie weit hinten
@export var axle_width: float = 0.6         # Wie breit ist die Achse
