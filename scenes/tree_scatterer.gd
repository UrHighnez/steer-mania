@tool
extends Node3D

@export_category("Settings")
@export var tree_mesh: Mesh 
@export var tree_count: int = 100
@export var spawn_area: Vector2 = Vector2(500, 500)
@export var ray_height: float = 1000.0
@export var ray_length: float = 20000.0
@export var min_scale: float = 0.8
@export var max_scale: float = 1.2
@export var y_offset: float = 0.0

@export_category("Placement Rules")
# 0° = nur komplett flach, 45° = steil, 90° = Wände erlaubt.
@export_range(0.0, 90.0) var max_slope_angle: float = 30.0 

@export_category("Actions")
@export var spawn_trees: bool = false:
	set(value):
		if value:
			_spawn_real_nodes()
			spawn_trees = false

@export var clear_trees: bool = false:
	set(value):
		if value:
			_clear_generated_trees()
			clear_trees = false

func _spawn_real_nodes():
	print("--- START SPAWN (Parenting to Self) ---")
	
	if not tree_mesh:
		printerr("FEHLER: Bitte weise ein 'Tree Mesh' im Inspektor zu!")
		return

	var root = get_tree().edited_scene_root
	if not root:
		root = get_tree().root 
	
	var space_state = get_world_3d().direct_space_state
	var hits = 0
	
	# Um Endlosschleifen zu vermeiden, versuchen wir es max X mal, 
	# falls wir nur steile Wände treffen.
	var attempts = 0
	var max_attempts = tree_count * 5 
	
	while hits < tree_count and attempts < max_attempts:
		attempts += 1
		
		var random_pos = Vector3(
			randf_range(-spawn_area.x / 2, spawn_area.x / 2),
			ray_height,
			randf_range(-spawn_area.y / 2, spawn_area.y / 2)
		)
		
		var global_ray_start = to_global(random_pos)
		var global_ray_end = global_ray_start + Vector3.DOWN * ray_length
		
		var query = PhysicsRayQueryParameters3D.create(global_ray_start, global_ray_end)
		var result = space_state.intersect_ray(query)
		
		if result and result.collider is StaticBody3D and result.collider.is_in_group("terrain"):
			
			# --- Steigungs-Check ---
			var normal = result.normal
			var slope_angle = rad_to_deg(normal.angle_to(Vector3.UP))
			
			if slope_angle > max_slope_angle:
				# Zu steil! Wir brechen diesen Versuch ab und probieren eine neue Position.
				continue 
			# ----------------------------

			hits += 1
			
			var tree_instance = MeshInstance3D.new()
			tree_instance.mesh = tree_mesh
			tree_instance.name = "GenTree_" + str(hits) # Name basiert jetzt auf Hits, nicht Loop-Index
			
			add_child(tree_instance)
			tree_instance.owner = root 
			
			tree_instance.global_position = result.position
			tree_instance.global_position.y += y_offset
			
			# Rotation: Wir richten den Baum immer noch stur nach oben aus (Y-Achse),
			# auch wenn er am Hang steht. Das sieht bei Bäumen meist natürlicher aus.
			# Wenn er senkrecht zum Hang wachsen soll: tree_instance.basis.y = result.normal (komplexer)
			tree_instance.rotate_y(randf() * TAU)
			
			var s = randf_range(min_scale, max_scale)
			tree_instance.scale = Vector3(s, s, s)
			
	print("FERTIG: ", hits, " Bäume gepflanzt (Slope < ", max_slope_angle, "°). Versuche: ", attempts)

func _clear_generated_trees():
	print("Lösche alte Bäume aus ", name, "...")
	for child in get_children():
		if child.name.begins_with("GenTree_"):
			child.queue_free()
