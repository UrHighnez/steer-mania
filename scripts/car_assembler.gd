extends Node
class_name CarAssembler

# Zugriff auf die Teile des Autos
@export_group("Referenzen")
@export var chassis_mesh_node: MeshInstance3D
@export var wheels_front: Array[VehicleWheel3D]
@export var wheels_back: Array[VehicleWheel3D]

func _ready():
	# 1. Daten abrufen (mit Fallback, falls leer)
	var chassis_data = GameManager.selected_chassis
	var wheel_data = GameManager.selected_wheels
	
	if chassis_data:
		_apply_chassis(chassis_data)
	
	if wheel_data:
		_apply_wheels(wheel_data)

func _apply_chassis(data: CarChassisResource):
	var car = get_parent() 
	
	# A) Physik setzen
	car.mass = data.mass
	
	# B) Optik setzen
	if chassis_mesh_node and data.mesh:
		chassis_mesh_node.mesh = data.mesh
	
	# C) Rad-Positionen anpassen
	var half_width = data.axle_width / 2.0
	
	# Vorderräder
	for wheel in wheels_front:
		var side = sign(wheel.position.x) # Berechnet: Links (+1) oder Rechts (-1)
		wheel.position.z = data.front_axle_offset
		wheel.position.x = side * half_width
		
	# Hinterräder
	for wheel in wheels_back:
		var side = sign(wheel.position.x) # WICHTIG: Hier müssen wir side neu berechnen!
		wheel.position.z = data.back_axle_offset
		wheel.position.x = side * half_width

func _apply_wheels(data: CarWheelResource):
	# Wir gehen alle Räder durch (Vorne + Hinten)
	var all_wheels = wheels_front + wheels_back
	
	for wheel in all_wheels:
		# A) Physik übernehmen
		wheel.wheel_radius = data.wheel_radius
		wheel.wheel_friction_slip = data.wheel_friction_slip
		wheel.suspension_stiffness = data.suspension_stiffness
		wheel.damping_compression = data.damping
		
		# B) Optik tauschen
		# Wir suchen das MeshInstance3D Kind im Rad
		var mesh_instance = _find_mesh_child(wheel)
		if mesh_instance and data.mesh:
			mesh_instance.mesh = data.mesh
			# Mesh skalieren, falls es nicht zum Radius passt?
			# Hier gehen wir davon aus, dass das Mesh schon die richtige Größe hat.

# Hilfsfunktion, um das Mesh im Rad zu finden
func _find_mesh_child(parent: Node) -> MeshInstance3D:
	for child in parent.get_children():
		if child is MeshInstance3D:
			return child
	return null
