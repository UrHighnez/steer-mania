extends Camera3D

@export var target_vehicle: VehicleBody3D

@export var follow_distance = 5.0
@export var follow_height = 2.5
@export var smooth_speed = 3.0

func _physics_process(delta):
	if target_vehicle == null:
		return
	
	var car_pos = target_vehicle.global_position
	
	var target_rotation_y = target_vehicle.global_transform.basis.get_euler().y
	
	var offset = Vector3(0, follow_height, follow_distance).rotated(Vector3.UP, target_rotation_y)
	
	var desired_position = car_pos + offset
	
	var look_at_target = car_pos + Vector3(0, 1.0, 0)

	global_position = global_position.lerp(desired_position, delta * smooth_speed)

	look_at(look_at_target, Vector3.UP)
	
	# Dynamisches FOV für Speed-Effekt
	var speed = target_vehicle.linear_velocity.length()
	var target_fov = 75.0 + (speed * 0.5) # Basis 75, plus Speed-Bonus
	fov = lerp(fov, clamp(target_fov, 75.0, 110.0), delta * 2.0)
