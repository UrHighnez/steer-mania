extends Node3D

@onready var win_label = $"HUD/UI/WinLabel"
@onready var time_label = $"HUD/UI/TimeLabel/CurrentTimeLabel"
@onready var best_time_label = $"HUD/UI/TimeLabel/PBTimeLabel"
@onready var fade_overlay = $"HUD/FadeOverlay"

@onready var finish_line = $"Track/FinishLine"
@onready var course_boundary = $"Track/CourseBoundary"

@export_file("*.tscn") var garage_scene_path: String

var elapsed_time: float = 0.0
var best_time: float = 999999.0
var is_racing: bool = false
const SAVE_PATH = "user://best_time.save"

func _ready():
	load_best_time()
	update_best_time_display()
	
	# Initial Fade-In
	fade_overlay.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, 1.0)
	
	is_racing = true
	
	if finish_line: 
		finish_line.body_entered.connect(_on_finish_line_entered)
	if course_boundary: 
		course_boundary.body_exited.connect(_on_course_boundary_exited)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		fade_and_exit()
	
	if is_racing:
		elapsed_time += delta
		time_label.text = format_time(elapsed_time)

func format_time(time_val: float) -> String:
	var minutes = int(time_val / 60)
	var seconds = int(time_val) % 60
	var milliseconds = int((time_val - int(time_val)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func update_best_time_display():
	if best_time < 999998.0:
		best_time_label.text = "PB: " + format_time(best_time)
	else:
		best_time_label.text = "PB: --:--.--"

func _on_finish_line_entered(body):
	if body.is_in_group("player") and is_racing:
		game_won()

func game_won():
	is_racing = false
	var is_new_record = false
	
	if elapsed_time < best_time:
		best_time = elapsed_time
		is_new_record = true
		save_best_time()
		update_best_time_display()
	
	if win_label:
		var text = "FINISH!"
		text += "\nTime: " + format_time(elapsed_time)
		if is_new_record:
			text += "\nNEW PERSONAL BEST!"
		win_label.text = text
		win_label.show()
	
	await get_tree().create_timer(3.0).timeout
	fade_and_exit()

func save_best_time():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_float(best_time)
		file.close()

func load_best_time():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			best_time = file.get_float()
			file.close()

func reset_level():
	get_tree().reload_current_scene()

func _on_course_boundary_exited(body):
	if body.is_in_group("player"):
		print("Off track! Resetting...")
		reset_level()

func fade_and_exit():
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.0)
	await tween.finished
	if garage_scene_path != "":
		get_tree().change_scene_to_file(garage_scene_path)
