extends VehicleBody3D

@export var MAX_STEER = 0.7
@export var ENGINE_POWER = 100


func _physics_process(delta):
	steering = move_toward(steering, Input.get_axis("Steer Right", "Steer Left") * MAX_STEER, delta * 5)
	engine_force = Input.get_axis("Down", "Up") * ENGINE_POWER
