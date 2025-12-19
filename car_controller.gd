extends VehicleBody3D

@export var MAX_STEER = 0.7


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta):
	steering = move_toward(steering, Input.get_axis("Steer Right", "Steer Left") * MAX_STEER, delta * 5)
