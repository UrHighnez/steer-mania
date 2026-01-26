extends Node3D

@onready var win_label = $HUD/Label # Pfad zu deinem Label anpassen!
@onready var finish_line = $"Track/Finish Line" # Pfad zu deiner Area3D anpassen!
@onready var course_boundary = $"Track/Course Boundary" # Dein Bereich um die Strecke

@export_file("*.tscn") var garage_scene_path: String

func _ready():
	# Ziellinie: Wenn man REINFÄHRT, hat man gewonnen
	if finish_line:
		finish_line.body_entered.connect(_on_finish_line_entered)
	
	# Begrenzung: Wenn man RAUSFÄHRT, wird zurückgesetzt
	if course_boundary:
		course_boundary.body_exited.connect(_on_course_boundary_exited)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		go_to_garage()

func _on_finish_line_entered(body):
	if body.is_in_group("player"):
		game_won()

# Diese Funktion wird aufgerufen, sobald das Auto die Box verlässt
func _on_course_boundary_exited(body):
	if body.is_in_group("player"):
		print("Strecke verlassen! Neustart...")
		reset_level()

func game_won():
	if win_label:
		win_label.show()
	await get_tree().create_timer(3.0).timeout
	go_to_garage()

func reset_level():
	get_tree().reload_current_scene()

func go_to_garage():
	if garage_scene_path != "":
		get_tree().change_scene_to_file(garage_scene_path)
