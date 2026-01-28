extends VehicleBody3D

@export var MAX_STEER = 0.5
@export var STEER_SPEED = 5.0
@export var BRAKE_POWER = 5.0

func _physics_process(delta):
	# 1. LENKUNG
	var steer_input = Input.get_axis("Steer Right", "Steer Left")
	var speed = linear_velocity.length()
	
	var current_max_steer = MAX_STEER
	if speed > 10.0:
		current_max_steer = MAX_STEER * 0.5
		
	steering = move_toward(steering, steer_input * current_max_steer, delta * STEER_SPEED)

	# ANTRIEB & BREMSE
	var input_vertical = Input.get_axis("Brake", "Accelerate")
	
	if input_vertical < 0: # Bremsen
		if speed > 0.1:
			# Normales Bremsen (Federung darf arbeiten)
			brake = BRAKE_POWER * abs(input_vertical)
		else:
			# FAST STILLSTAND -> "Parkmodus"
			brake = 0.0 
			
			# Wir killen nur die horizontale Bewegung -> Kein Rutschen
			linear_velocity.x = 0
			linear_velocity.z = 0
			angular_velocity = Vector3.ZERO
			
		engine_force = 0.0
	else:
		brake = 0.0


func _on_chassis_prev_pressed() -> void:
	pass # Replace with function body.
