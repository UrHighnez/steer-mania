extends Node
class_name CarAssembler

# Zugriff auf die Teile des Autos
@export_group("Referenzen")
@export var wheels_front: Array[VehicleWheel3D]
@export var wheels_back: Array[VehicleWheel3D]

func _ready():
	print("Assembler gestartet!")
	
	# 1. Daten abrufen
	var chassis_data = GameManager.selected_chassis
	var wheel_data = GameManager.selected_wheels
	
	# 2. Anwenden
	if chassis_data:
		_apply_chassis(chassis_data)
	else:
		print("ACHTUNG: Kein Chassis im GameManager ausgewählt.")
	
	if wheel_data:
		_apply_wheels(wheel_data)

func _apply_chassis(data: CarChassisResource):
	var car = get_parent() # Das ist der VehicleBody
	
	# Wir suchen unseren neuen Mount-Point
	var mount_point = car.get_node_or_null("ChassisMount")
	
	if not mount_point:
		print("FEHLER: 'ChassisMount' Node fehlt in der Auto-Szene! Bitte hinzufügen!")
		return

	# --- 1. AUFRÄUMEN ---
	# Wir löschen das alte Chassis aus dem Mount-Point
	for child in mount_point.get_children():
		child.queue_free()

	# Wir löschen auch eventuell alte transplantierten Shapes am Auto selbst
	var old_shape = car.get_node_or_null("ActiveChassisShape")
	if old_shape:
		old_shape.queue_free()
	
	# Physik-Masse am Auto setzen (das darf direkt ans Auto)
	car.mass = data.mass
	
	# --- 2. NEUES LADEN ---
	if data.chassis_scene:
		var new_chassis_root = data.chassis_scene.instantiate()
		new_chassis_root.name = "ActiveChassis"
		
		# --- SCHRITT 3: COLLISION TRANSPLANTATION ---
		# (Bleibt gleich: Shape ans Auto, Rest an den Mount-Point)
		var found_shape = null
		for child in new_chassis_root.get_children():
			if child is CollisionShape3D:
				found_shape = child
				break
		
		if found_shape:
			new_chassis_root.remove_child(found_shape)
			found_shape.name = "ActiveChassisShape"
			# Shape MUSS an den VehicleBody (Physik zu Physik)
			# Wir nutzen call_deferred zur Sicherheit
			car.add_child.call_deferred(found_shape)
			print("CollisionShape transplantiert.")
		
		# --- SCHRITT 4: VISUALS HINZUFÜGEN ---
		# Das Chassis kommt jetzt an den sicheren Mount-Point!
		# WICHTIG: call_deferred verhindert Konflikte während _ready
		mount_point.add_child.call_deferred(new_chassis_root)
		
		# Positionen müssen wir hier meist nicht setzen, da der MountPoint bei 0,0,0 ist
		# Aber sicher ist sicher:
		new_chassis_root.position = Vector3.ZERO
		new_chassis_root.rotation = Vector3.ZERO
		
		print("Chassis Visuals an Mount-Point übergeben.")
	
	# --- SCHRITT 5: RÄDER ANPASSEN ---
	var half_width = data.axle_width / 2.0
	
	for wheel in wheels_front:
		var side = sign(wheel.position.x)
		if side == 0: side = 1 
		wheel.position.z = data.front_axle_offset
		wheel.position.x = side * half_width
		
	for wheel in wheels_back:
		var side = sign(wheel.position.x)
		if side == 0: side = 1
		wheel.position.z = data.back_axle_offset
		wheel.position.x = side * half_width

func _apply_wheels(data: CarWheelResource):
	var all_wheels = wheels_front + wheels_back
	
	for wheel in all_wheels:
		wheel.wheel_radius = data.wheel_radius
		wheel.wheel_friction_slip = data.wheel_friction_slip
		wheel.suspension_stiffness = data.suspension_stiffness
		wheel.damping_compression = data.damping
		
		for child in wheel.get_children():
			wheel.remove_child(child)
			child.queue_free() 
		
		if data.wheel_scene:
			var new_visuals = data.wheel_scene.instantiate()
			wheel.add_child(new_visuals)
