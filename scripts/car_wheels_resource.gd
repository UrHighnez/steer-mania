extends Resource
class_name CarWheelResource

@export_group("Optik")
@export var display_name: String = ""
@export var wheel_scene: PackedScene  # Hier ziehen wir später eine .tscn rein

@export_group("Physik & Handling")
@export var wheel_radius: float = 0.5 # Wichtig für Kollision
@export var wheel_friction_slip: float = 10.5 # Grip: Niedrig = Drift, Hoch = Kleben
@export var suspension_stiffness: float = 50.0 # Federungshärte
@export var damping: float = 3.0 # Wie stark die Federung nachschwingt (gegen Jitter)
