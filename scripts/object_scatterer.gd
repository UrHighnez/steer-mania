@tool
extends Node3D

@export_category("Multi-Mesh Settings")
# Deine Meshes (Baum, Stein, Busch)
@export var scatter_meshes: Array[Mesh] = []
# Deine Wahrscheinlichkeiten (z.B. 10.0, 5.0, 1.0)
@export var scatter_weights: Array[float] = []
# NEU: Individuelle Höhenkorrektur pro Mesh (z.B. -0.2, 0.0, 1.5)
# Muss die gleiche Reihenfolge/Länge haben wie scatter_meshes!
@export var scatter_y_offsets: Array[float] = []

@export_category("General Settings")
@export var object_count: int = 100
@export var spawn_area: Vector2 = Vector2(500, 500)
@export var center_offset: Vector3 = Vector3.ZERO 

@export var ray_height: float = 1000.0
@export var ray_length: float = 20000.0
@export var min_scale: float = 0.8
@export var max_scale: float = 1.2
# Das hier gilt für ALLE (Globaler Offset)
@export var global_y_offset: float = 0.0

@export_category("Placement Rules")
@export_range(0.0, 90.0) var max_slope_angle: float = 30.0 

@export_category("Actions")
@export var spawn_objects: bool = false:
	set(value):
		if value:
			_spawn_real_nodes()
			spawn_objects = false

@export var clear_objects: bool = false:
	set(value):
		if value:
			_clear_generated_objects()
			clear_objects = false

func _spawn_real_nodes():
	print("--- START SPAWN MULTI-OBJECTS V3 ---")
	
	if scatter_meshes.is_empty():
		printerr("FEHLER: 'Scatter Meshes' Array ist leer!")
		return

	var root = get_tree().edited_scene_root
	if not root:
		root = get_tree().root 
	
	var space_state = get_world_3d().direct_space_state
	var hits = 0
	var attempts = 0
	var max_attempts = object_count * 5 
	
	while hits < object_count and attempts < max_attempts:
		attempts += 1
		
		# Zufallsposition
		var random_x = randf_range(-spawn_area.x / 2, spawn_area.x / 2) + center_offset.x
		var random_z = randf_range(-spawn_area.y / 2, spawn_area.y / 2) + center_offset.z
		var start_y = ray_height + center_offset.y
		
		var global_ray_start = to_global(Vector3(random_x, start_y, random_z))
		var global_ray_end = global_ray_start + Vector3.DOWN * ray_length
		
		var query = PhysicsRayQueryParameters3D.create(global_ray_start, global_ray_end)
		var result = space_state.intersect_ray(query)
		
		if result and result.collider is StaticBody3D and result.collider.is_in_group("terrain"):
			
			# Slope Check
			var normal = result.normal
			var slope_angle = rad_to_deg(normal.angle_to(Vector3.UP))
			if slope_angle > max_slope_angle:
				continue 

			hits += 1
			
			# 1. Wir ermitteln den INDEX des gewählten Meshes
			var selected_index = _get_weighted_index()
			var selected_mesh = scatter_meshes[selected_index]
			
			# 2. Wir suchen das passende individuelle Offset
			var individual_offset = 0.0
			if selected_index < scatter_y_offsets.size():
				individual_offset = scatter_y_offsets[selected_index]
			
			var obj_instance = MeshInstance3D.new()
			obj_instance.mesh = selected_mesh
			obj_instance.name = "GenObject_" + str(hits)
			
			add_child(obj_instance)
			obj_instance.owner = root 
			
			obj_instance.global_position = result.position
			
			# 3. Addition: Globale Höhe + Individuelle Korrektur
			obj_instance.global_position.y += global_y_offset + individual_offset
			
			obj_instance.rotate_y(randf() * TAU)
			var s = randf_range(min_scale, max_scale)
			obj_instance.scale = Vector3(s, s, s)
			
	print("FERTIG: ", hits, " Objekte gepflanzt. Versuche: ", attempts)

# Gibt jetzt den INDEX zurück, nicht das Mesh, damit wir auch das Offset finden
func _get_weighted_index() -> int:
	var mesh_count = scatter_meshes.size()
	
	# Fallback: Zufall, wenn Weights fehlen oder falsch sind
	if scatter_weights.is_empty() or scatter_weights.size() != mesh_count:
		return randi() % mesh_count
	
	var total_weight = 0.0
	for w in scatter_weights:
		total_weight += w
	
	var random_val = randf() * total_weight
	var current_sum = 0.0
	
	for i in range(mesh_count):
		current_sum += scatter_weights[i]
		if random_val <= current_sum:
			return i
	
	return 0
	
func _clear_generated_objects():
	print("Lösche alte Objekte aus ", name, "...")
	for child in get_children():
		if child.name.begins_with("GenObject_"):
			child.queue_free()
