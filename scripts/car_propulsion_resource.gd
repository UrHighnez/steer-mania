extends Resource
class_name CarPropulsionResource

@export_group("Visuals")
@export var display_name: String = ""
@export var propulsion_scene: PackedScene # Das 3D Modell (z.B. Feuerlöscher, Rakete)

@export_group("Physics")
@export var mass: float = 10.0      # Wie schwer ist der Tank? (Wichtig für Balance!)
@export var push_force: float = 500.0 # Wie stark schiebt es? (Newtons)
@export var fuel_duration: float = 3.0 # Wie viele Sekunden Schub?
