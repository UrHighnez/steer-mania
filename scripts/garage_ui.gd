extends Control

# --- EXPORTS: NODES ---
@export_group("Required Nodes")
@export var car_assembler: CarAssembler
@export var pb_label: Label
@export var fade_overlay: ColorRect

@export_group("UI Labels")
@export var lbl_chassis_name: Label
@export var lbl_wheel_name: Label

# --- EXPORTS: LISTS ---
@export_group("Car Part Lists")
@export var chassis_options: Array[CarChassisResource] = []
@export var wheel_options: Array[CarWheelResource] = []

# --- EXPORTS: SCENES ---
@export_group("Navigation")
@export_file("*.tscn") var race_scene_path: String

# --- INTERNE VARIABLEN ---
var current_chassis_index: int = 0
var current_wheel_index: int = 0
const SAVE_PATH = "user://best_time.save"

func _ready():
	if fade_overlay:
		var tween = create_tween()
		tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
	
	_display_personal_best()
	_load_current_setup()

func _load_current_setup():
	# --- 1. CHASSIS LADEN ---
	if GameManager.selected_chassis != null:
		var found_index = chassis_options.find(GameManager.selected_chassis)
		current_chassis_index = found_index if found_index != -1 else 0
	else:
		current_chassis_index = 0
	
	_select_chassis_by_index(current_chassis_index)

	# --- 2. REIFEN LADEN ---
	if GameManager.selected_wheels != null:
		var found_index = wheel_options.find(GameManager.selected_wheels)
		current_wheel_index = found_index if found_index != -1 else 0
	else:
		current_wheel_index = 0
		
	_select_wheels_by_index(current_wheel_index)

# --- AUSWAHL LOGIK ---

func _select_chassis_by_index(index: int):
	if chassis_options.is_empty(): return
	
	var selected = chassis_options[index]
	
	# 1. Speichern & Anwenden
	GameManager.selected_chassis = selected
	car_assembler._apply_chassis(selected)
	
	# 2. UI Aktualisieren (Zentral gesteuert!)
	_update_ui_labels()

func _select_wheels_by_index(index: int):
	if wheel_options.is_empty(): return
	
	var selected = wheel_options[index]
	
	GameManager.selected_wheels = selected
	car_assembler._apply_wheels(selected)
	
	_update_ui_labels()

# --- UI UPDATE (Zentral) ---

func _update_ui_labels():
	# CHASSIS TEXT
	if not chassis_options.is_empty() and lbl_chassis_name:
		var res = chassis_options[current_chassis_index]
		var txt = res.display_name
		
		# Fallbacks
		if txt == "": txt = res.resource_name
		if txt == "": txt = "Chassis " + str(current_chassis_index + 1)
		
		lbl_chassis_name.text = txt
		print("UI Update Chassis: ", txt) # Debug
		
	# WHEEL TEXT
	if not wheel_options.is_empty() and lbl_wheel_name:
		var res = wheel_options[current_wheel_index]
		var txt = res.display_name
		
		if txt == "": txt = res.resource_name
		if txt == "": txt = "Wheel " + str(current_wheel_index + 1)
		
		lbl_wheel_name.text = txt
		print("UI Update Wheel: ", txt) # Debug

# --- BUTTON SIGNALS ---

func _on_chassis_prev_pressed():
	if chassis_options.is_empty(): return
	current_chassis_index -= 1
	if current_chassis_index < 0: current_chassis_index = chassis_options.size() - 1
	_select_chassis_by_index(current_chassis_index)

func _on_chassis_next_pressed():
	if chassis_options.is_empty(): return
	current_chassis_index += 1
	if current_chassis_index >= chassis_options.size(): current_chassis_index = 0
	_select_chassis_by_index(current_chassis_index)

func _on_wheels_prev_pressed():
	if wheel_options.is_empty(): return
	current_wheel_index -= 1
	if current_wheel_index < 0: current_wheel_index = wheel_options.size() - 1
	_select_wheels_by_index(current_wheel_index)

func _on_wheels_next_pressed():
	if wheel_options.is_empty(): return
	current_wheel_index += 1
	if current_wheel_index >= wheel_options.size(): current_wheel_index = 0
	_select_wheels_by_index(current_wheel_index)

# --- SZENENWECHSEL ---

func _on_btn_start_race_pressed():
	if not race_scene_path: return
	if fade_overlay:
		var tween = create_tween()
		tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
		await tween.finished
	get_tree().change_scene_to_file(race_scene_path)

# --- HELPER (PB) ---

func _display_personal_best():
	if not pb_label: return
	var pb = _load_best_time()
	pb_label.text = "PB: " + (_format_time(pb) if pb < 999998.0 else "--:--")

func _load_best_time() -> float:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file: return file.get_float()
	return 999999.0

func _format_time(time_val: float) -> String:
	var minutes = int(time_val / 60)
	var seconds = int(time_val) % 60
	var milliseconds = int((time_val - int(time_val)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
