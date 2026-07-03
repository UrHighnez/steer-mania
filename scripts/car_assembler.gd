extends Node
class_name CarAssembler

@export_group("References")
@export var wheels_front: Array[VehicleWheel3D]
@export var wheels_back: Array[VehicleWheel3D]

func _ready():	
	# 1. Daten abrufen
	var chassis_data = GameManager.selected_chassis
	var wheel_data = GameManager.selected_wheels
	var prop_data = GameManager.selected_propulsion # NEU
	
	# 2. Reihenfolge ist wichtig für Physics-Calculation!
	if chassis_data:
		_apply_chassis(chassis_data)
	
	# Erst den Antrieb montieren (fügt Masse hinzu)
	if prop_data:
		_apply_propulsion(prop_data)
	
	# Dann die Räder (berechnet Stiffness basierend auf Gesamtmasse)
	if wheel_data:
		_apply_wheels(wheel_data)

func _apply_chassis(data: CarChassisResource):
	# ... (Dein existierender Code für Chassis hier 1:1 lassen) ...
	# (Aus Platzgründen hier gekürzt, da unverändert zu deinem Code)
	var car = get_parent()
	var mount_point = car.get_node_or_null("ChassisMount")
	if not mount_point: return
	for child in mount_point.get_children(): child.queue_free()
	var old_shape = car.get_node_or_null("ActiveChassisShape")
	if old_shape: old_shape.queue_free()
	
	# Basis-Masse setzen
	car.mass = data.mass
	
	if data.chassis_scene:
		var new_chassis = data.chassis_scene.instantiate()
		new_chassis.name = "ActiveChassis"
		# Collision Logic
		var shapes = new_chassis.find_children("*", "CollisionShape3D", true, false)
		if shapes.size() > 0:
			var found_shape = shapes[0]
			found_shape.get_parent().remove_child(found_shape)
			found_shape.owner = null
			found_shape.name = "ActiveChassisShape"
			car.add_child.call_deferred(found_shape)
		mount_point.add_child.call_deferred(new_chassis)
		new_chassis.position = Vector3.ZERO
		new_chassis.rotation = Vector3.ZERO

	# Achsen setzen
	var half_width = data.axle_width / 2.0
	for wheel in wheels_front:
		var side = sign(wheel.position.x); if side == 0: side = 1 
		wheel.position.z = data.front_axle_offset; wheel.position.x = side * half_width
	for wheel in wheels_back:
		var side = sign(wheel.position.x); if side == 0: side = 1
		wheel.position.z = data.back_axle_offset; wheel.position.x = side * half_width


# --- NEUE FUNKTION ---
func _apply_propulsion(data: CarPropulsionResource):
	var car = get_parent()
	
	# Wir brauchen einen Mount-Point hinten am Auto
	var mount_point = car.get_node_or_null("PropulsionMount")
	
	if mount_point:
		# Aufräumen
		for child in mount_point.get_children():
			child.queue_free()
			
		# Visuals laden
		if data.propulsion_scene:
			var vis = data.propulsion_scene.instantiate()
			mount_point.add_child(vis)
	
	# Wir addieren das Gewicht der Rakete zum Chassis
	car.mass += data.mass
	
	# Daten an den Controller übergeben
	if car.has_method("setup_propulsion"):
		car.setup_propulsion(data.push_force, data.fuel_duration)


func _apply_wheels(data: CarWheelResource):
	var car = get_parent()
	var all_wheels = wheels_front + wheels_back
	
	# --- MASSE BERECHNUNG ---
	# Wir holen die AKTUELLE Masse (Chassis + Propulsion wurde oben schon gesetzt)
	var current_body_mass = car.mass 
	
	# Jetzt addieren wir die Räder
	var total_mass = current_body_mass + (data.mass * 4.0)
	car.mass = total_mass
	
	# --- STIFFNESS BERECHNUNG ---
	# Dynamische Härte basierend auf dem neuen Gesamtgewicht
	var stiffness_factor = 35.0 
	var target_stiffness = clamp((total_mass / 4.0) * stiffness_factor, 10.0, 400.0)
	
	print("CarAssembler: Total Mass (Chassis+Prop+Wheels): ", total_mass)
	
	for wheel in all_wheels:
		wheel.wheel_radius = data.wheel_radius
		if wheel in wheels_back:
			wheel.wheel_friction_slip = data.wheel_friction_slip * 1.2 #20% mehr Friction für Hinterfräder
		else:
			wheel.wheel_friction_slip = data.wheel_friction_slip		
		
		# Berechnete Stiffness statt Resource-Wert
		wheel.suspension_stiffness = target_stiffness
		wheel.damping_compression = data.damping
		
		# Visuals (Dein Code)
		for child in wheel.get_children():
			wheel.remove_child(child)
			child.queue_free() 
		if data.wheel_scene:
			var new_visuals = data.wheel_scene.instantiate()
			wheel.add_child(new_visuals)
