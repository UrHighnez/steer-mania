@tool
extends MultiMeshInstance3D

@export var tree_count: int = 100
@export var spawn_area: Vector2 = Vector2(500, 500)
@export var ray_height: float = 1000.0
@export var ray_length: float = 20000.0
@export var min_scale: float = 0.8
@export var max_scale: float = 1.2
@export var y_offset: float = 0.0
@export var show_debug_lines: bool = true

@export_category("Actions")
@export var generate: bool = false:
	set(value):
		generate = value
		if generate:
			plant_trees_forced()
			generate = false

var debug_draw_instance: MeshInstance3D = null

func plant_trees_forced():
	print("--- START FORCE-RESET SCATTER ---")
	
	if not multimesh or not multimesh.mesh:
		printerr("FEHLER: Kein Mesh zugewiesen!")
		return

	# 1. FORCE RESET: Wir zwingen den Node auf den Welt-Ursprung
	if not top_level:
		top_level = true
		print("ACHTUNG: 'Top Level' wurde aktiviert.")
	
	# FIX: Statt einzelner Zuweisungen setzen wir die komplette Matrix zurück.
	# Das umgeht den "Constant"-Fehler.
	global_transform = Transform3D.IDENTITY
	
	print("Node-Reset durchgeführt.")

	# Aufräumen Debug
	if debug_draw_instance: debug_draw_instance.queue_free()
	
	# Debug Mesh Setup
	var im_mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	
	debug_draw_instance = MeshInstance3D.new()
	debug_draw_instance.mesh = im_mesh
	debug_draw_instance.material_override = material
	debug_draw_instance.name = "DebugLines_DONT_SAVE"
	get_tree().root.add_child(debug_draw_instance)
	debug_draw_instance.global_position = Vector3.ZERO
	
	# Raycast Setup
	var space_state = get_world_3d().direct_space_state
	multimesh.instance_count = 0
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = tree_count
	
	var hits = 0
	im_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	for i in range(tree_count):
		var random_pos = Vector3(
			randf_range(-spawn_area.x / 2, spawn_area.x / 2),
			ray_height,
			randf_range(-spawn_area.y / 2, spawn_area.y / 2)
		)
		
		# Da wir jetzt auf 0,0,0 sind, ist local == global
		var global_ray_start = random_pos 
		var global_ray_end = global_ray_start + Vector3.DOWN * ray_length
		
		var query = PhysicsRayQueryParameters3D.create(global_ray_start, global_ray_end)
		var result = space_state.intersect_ray(query)
		
		var t = Transform3D()
		
		if result and result.collider is StaticBody3D:
			hits += 1
			var hit_pos = result.position
			
			# DEBUG LINES
			if show_debug_lines:
				im_mesh.surface_set_color(Color(0, 1, 0))
				im_mesh.surface_add_vertex(global_ray_start)
				im_mesh.surface_add_vertex(hit_pos)
				im_mesh.surface_set_color(Color(1, 0, 0))
				var s = 2.0
				im_mesh.surface_add_vertex(hit_pos + Vector3(-s, 0, 0))
				im_mesh.surface_add_vertex(hit_pos + Vector3(s, 0, 0))
				im_mesh.surface_add_vertex(hit_pos + Vector3(0, 0, -s))
				im_mesh.surface_add_vertex(hit_pos + Vector3(0, 0, s))
			
			# PLATZIERUNG
			t.origin = hit_pos 
			
			var safe_offset = y_offset if y_offset != null else 0.0
			t.origin.y += safe_offset
			
			t = t.rotated(Vector3.UP, randf() * TAU)
			var scale_val = randf_range(min_scale, max_scale)
			t = t.scaled(Vector3(scale_val, scale_val, scale_val))
			
		else:
			t.origin = Vector3(0, -99999, 0)
			t = t.scaled(Vector3.ZERO)
			
		multimesh.set_instance_transform(i, t)
	
	im_mesh.surface_end()
	print("FERTIG: ", hits, " Treffer.")
