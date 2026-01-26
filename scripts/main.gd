extends Node3D

@onready var win_label = $"HUD/Win Label" # Pfad zu Label
@onready var time_label = $"HUD/Time Label" # Label für die Uhr

@onready var finish_line = $"Track/Finish Line" # Pfad zu Area3D
@onready var course_boundary = $"Track/Course Boundary" # Bereich um die Strecke

@onready var fade_overlay = $"HUD/Fade Overlay"

@export_file("*.tscn") var garage_scene_path: String

var elapsed_time: float = 0.0
var is_racing: bool = false

func _ready():
	# Fade-In am Start
	fade_overlay.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, 1.0)
	
	# Rennen starten
	is_racing = true
	
	if finish_line:
		finish_line.body_entered.connect(_on_finish_line_entered)
	if course_boundary:
		course_boundary.body_exited.connect(_on_course_boundary_exited)

func _process(delta):
	# ESC Taste
	if Input.is_action_just_pressed("ui_cancel"):
		fade_and_exit()
	
	# Zeitmessung
	if is_racing:
		elapsed_time += delta
		update_time_display()

func update_time_display():
	# Umrechnung in Minuten, Sekunden und Millisekunden
	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60
	var milliseconds = int((elapsed_time - int(elapsed_time)) * 100)
	
	# Formatierung als String (00:00.00)
	time_label.text = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func _on_finish_line_entered(body):
	if body.is_in_group("player") and is_racing:
		game_won()

func _on_course_boundary_exited(body):
	if body.is_in_group("player"):
		reset_level()

func game_won():
	is_racing = false # Timer stoppen
	
	if win_label:
		# Den Sieg-Text mit der finalen Zeit ergänzen
		win_label.text = win_label.text + "\nYour Time: " + time_label.text
		win_label.show()
	
	await get_tree().create_timer(2.0).timeout
	fade_and_exit()

func fade_and_exit():
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.0)
	await tween.finished
	go_to_garage()

func reset_level():
	get_tree().reload_current_scene()

func go_to_garage():
	if garage_scene_path != "":
		get_tree().change_scene_to_file(garage_scene_path)
