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

	# Wir brauchen 'root' nur noch für den 'owner' (damit man die Bäume im Editor sieht/speichert)
	var root = get_tree().edited_scene_root
	if not root:
		root = get_tree().root 
	
	var space_state = get_world_3d().direct_space_state
	var hits = 0
	
	for i in range(tree_count):
		var random_pos = Vector3(
			randf_range(-spawn_area.x / 2, spawn_area.x / 2),
			ray_height,
			randf_range(-spawn_area.y / 2, spawn_area.y / 2)
		)
		
		# 1. Raycast (Global)
		# Wir rechnen random_pos relativ zu unserer eigenen globalen Position
		var global_ray_start = to_global(random_pos)
		var global_ray_end = global_ray_start + Vector3.DOWN * ray_length
		
		var query = PhysicsRayQueryParameters3D.create(global_ray_start, global_ray_end)
		var result = space_state.intersect_ray(query)
		
		if result and result.collider is StaticBody3D and result.collider.is_in_group("terrain"):
			hits += 1
			
			var tree_instance = MeshInstance3D.new()
			tree_instance.mesh = tree_mesh
			tree_instance.name = "GenTree_" + str(i)
			
			add_child(tree_instance) # Hängt es an 'self'
			
			# WICHTIG: Owner muss immer der Szenen-Root sein, sonst werden sie nicht gespeichert!
			tree_instance.owner = root 
		
			tree_instance.global_position = result.position
			tree_instance.global_position.y += y_offset
			
			tree_instance.rotate_y(randf() * TAU)
			var s = randf_range(min_scale, max_scale)
			tree_instance.scale = Vector3(s, s, s)
			
	print("FERTIG: ", hits, " Bäume als Kind von ", name, " gepflanzt.")

func _clear_generated_trees():
	print("Lösche alte Bäume aus ", name, "...")
	for child in get_children():
		if child.name.begins_with("GenTree_"):
			child.queue_free()
