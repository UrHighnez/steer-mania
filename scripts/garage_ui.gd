extends Control

# --- EXPORTS: NODES ---
@export_group("Required Nodes")
@export var car_assembler: CarAssembler
@export var pb_label: Label
@export var fade_overlay: ColorRect

# --- EXPORTS: RESOURCES ---
@export_group("Car Parts")
@export var chassis_light: CarChassisResource
@export var chassis_heavy: CarChassisResource
@export var wheel_wood: CarWheelResource
@export var wheel_rubber: CarWheelResource

# --- EXPORTS: SCENES ---
@export_group("Navigation")
@export_file("*.tscn") var race_scene_path: String

# --- CONSTANTS ---
const SAVE_PATH = "user://best_time.save"

func _ready():
	# 1. Setup UI Appearance
	if fade_overlay:
		fade_overlay.modulate.a = 1.0
		var tween = create_tween()
		tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.8)
	
	# 2. Display Personal Best
	_display_personal_best()
	
	# 3. Load previous selection from GameManager
	if GameManager.selected_chassis:
		car_assembler._apply_chassis(GameManager.selected_chassis)
	if GameManager.selected_wheels:
		car_assembler._apply_wheels(GameManager.selected_wheels)

# --- PB LOGIC ---

func _display_personal_best():
	if not pb_label: return
	
	var pb = _load_best_time()
	if pb < 999998.0:
		pb_label.text = "PERSONAL BEST: " + _format_time(pb)
	else:
		pb_label.text = "PERSONAL BEST: --:--.--"

func _load_best_time() -> float:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var time = file.get_float()
			file.close()
			return time
	return 999999.0

func _format_time(time_val: float) -> String:
	var minutes = int(time_val / 60)
	var seconds = int(time_val) % 60
	var milliseconds = int((time_val - int(time_val)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

# --- BUTTON SIGNALS ---

func _on_btn_light_pressed():
	GameManager.selected_chassis = chassis_light
	car_assembler._apply_chassis(chassis_light)

func _on_btn_heavy_pressed():
	GameManager.selected_chassis = chassis_heavy
	car_assembler._apply_chassis(chassis_heavy)

func _on_btn_wood_pressed():
	GameManager.selected_wheels = wheel_wood
	car_assembler._apply_wheels(wheel_wood)

func _on_btn_rubber_pressed():
	GameManager.selected_wheels = wheel_rubber
	car_assembler._apply_wheels(wheel_rubber)

func _on_btn_start_race_pressed():
	if not race_scene_path:
		printerr("ERROR: Race scene path is missing!")
		return
	
	# Smooth Fade Out before changing scene
	if fade_overlay:
		var tween = create_tween()
		tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.5)
		await tween.finished
		
	get_tree().change_scene_to_file(race_scene_path)
