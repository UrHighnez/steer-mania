extends Camera3D

@export var target_vehicle: VehicleBody3D

@export var follow_distance = 5.0
@export var follow_height = 2.5
@export var smooth_speed = 3.0

@export var rotation_speed = 3.0     # Wie schnell dreht man die Kamera manuell?
@export var auto_center_speed = 2.0  # Wie schnell geht sie zurück hinter das Auto?
@export var input_deadzone = 0.1     # Ab wann reagiert der Stick?

# Speichert, wie weit wir die Kamera gerade verdreht haben
var current_rotation_offset = 0.0

func _physics_process(delta):
	if target_vehicle == null:
		return
	
	# --- 1. Manuelle Kamera-Eingabe (Rechter Stick) ---
	var cam_input = Input.get_axis("Camera Right", "Camera Left")

	if abs(cam_input) > input_deadzone:
		# Spieler dreht aktiv: Offset erhöhen
		current_rotation_offset += cam_input * rotation_speed * delta
	else:
		# Spieler macht nichts: Automatisch zurück zur Mitte (0.0)
		current_rotation_offset = lerp(current_rotation_offset, 0.0, delta * auto_center_speed)

	# --- 2. Position berechnen ---
	var car_pos = target_vehicle.global_position
	
	# Basis-Rotation des Autos holen
	var car_y_rotation = target_vehicle.global_transform.basis.get_euler().y
	
	# Wir addieren unseren manuellen Offset zur Auto-Rotation dazu
	var final_y_rotation = car_y_rotation + current_rotation_offset
	
	# Offset berechnen mit der kombinierten Rotation
	var offset = Vector3(0, follow_height, follow_distance).rotated(Vector3.UP, final_y_rotation)
	
	var desired_position = car_pos + offset
	var look_at_target = car_pos + Vector3(0, 1.0, 0)

	# --- 3. Bewegung anwenden ---
	global_position = global_position.lerp(desired_position, delta * smooth_speed)

	look_at(look_at_target, Vector3.UP)
	
	# --- 4. FOV Effekt ---
	var speed = target_vehicle.linear_velocity.length()
	var target_fov = 75.0 + (speed * 0.5) 
	fov = lerp(fov, clamp(target_fov, 75.0, 110.0), delta * 2.0)
