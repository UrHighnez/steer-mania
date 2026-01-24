extends Resource
class_name CarWheelResource

@export_group("Optik")
@export var name: String = "Standard Rad"
@export var mesh: ArrayMesh # Das 3D-Modell des Rades

@export_group("Physik & Handling")
@export var wheel_radius: float = 0.5 # Wichtig für Kollision
@export var wheel_friction_slip: float = 10.5 # Grip: Niedrig = Drift, Hoch = Kleben
@export var suspension_stiffness: float = 50.0 # Federungshärte
@export var damping: float = 3.0 # Wie stark die Federung nachschwingt (gegen Jitter)
