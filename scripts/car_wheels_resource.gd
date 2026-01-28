extends Resource
class_name CarWheelResource

@export_group("Optik")
@export var display_name: String = ""
@export var wheel_scene: PackedScene

@export_group("Physik & Handling")
# NEU: Das Gewicht pro Rad. 4 Räder machen das Auto schwerer!
@export var mass: float = 5.0 

@export var wheel_radius: float = 0.5 
@export var wheel_friction_slip: float = 10.5 # Das ist unser GRIP Wert
@export var suspension_stiffness: float = 50.0 
@export var damping: float = 3.0
