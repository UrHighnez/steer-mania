@tool
extends Node3D

@export_category("Settings")
@export var object_mesh: Mesh 
@export var object_count: int = 100
@export var spawn_area: Vector2 = Vector2(500, 500)

# Verschiebt das Zentrum der Generierung (relativ zum Node)
@export var center_offset: Vector3 = Vector3.ZERO 

@export var ray_height: float = 1000.0
@export var ray_length: float = 20000.0
@export var min_scale: float = 0.8
@export var max_scale: float = 1.2
@export var y_offset: float = 0.0

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
	print("--- START SPAWN OBJECTS (Parenting to Self) ---")
	
	if not object_mesh:
		printerr("FEHLER: Bitte weise ein 'Object Mesh' im Inspektor zu!")
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
		
		# Zufall im Bereich + Offset
		var random_x = randf_range(-spawn_area.x / 2, spawn_area.x / 2) + center_offset.x
		var random_z = randf_range(-spawn_area.y / 2, spawn_area.y / 2) + center_offset.z
		
		# Y-Startpunkt
		var start_y = ray_height + center_offset.y
		
		var random_pos = Vector3(random_x, start_y, random_z)
		
		var global_ray_start = to_global(random_pos)
		var global_ray_end = global_ray_start + Vector3.DOWN * ray_length
		
		var query = PhysicsRayQueryParameters3D.create(global_ray_start, global_ray_end)
		var result = space_state.intersect_ray(query)
		
		if result and result.collider is StaticBody3D and result.collider.is_in_group("terrain"):
			
			# Steigungs-Check
			var normal = result.normal
			var slope_angle = rad_to_deg(normal.angle_to(Vector3.UP))
			
			if slope_angle > max_slope_angle:
				continue 

			hits += 1
			
			var obj_instance = MeshInstance3D.new()
			obj_instance.mesh = object_mesh
			# Umbenannt zu "GenObject_"
			obj_instance.name = "GenObject_" + str(hits)
			
			add_child(obj_instance)
			obj_instance.owner = root 
			
			obj_instance.global_position = result.position
			obj_instance.global_position.y += y_offset
			
			obj_instance.rotate_y(randf() * TAU)
			var s = randf_range(min_scale, max_scale)
			obj_instance.scale = Vector3(s, s, s)
			
	print("FERTIG: ", hits, " Objekte gepflanzt (Slope < ", max_slope_angle, "°). Versuche: ", attempts)

func _clear_generated_objects():
	print("Lösche alte Objekte aus ", name, "...")
	for child in get_children():
		# Löscht nur Objekte, die mit "GenObject_" beginnen
		if child.name.begins_with("GenObject_"):
			child.queue_free()
