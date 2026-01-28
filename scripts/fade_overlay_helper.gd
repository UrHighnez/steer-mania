@tool # This allows the script to run inside the Godot Editor
extends ColorRect

func _ready():
	if Engine.is_editor_hint():
		# We are in the Editor! Make it invisible so we can see our work.
		hide()
	else:
		# We are in the Game! Make it visible and pitch black immediately.
		show()
		modulate.a = 1.0
