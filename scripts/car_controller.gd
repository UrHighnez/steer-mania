extends VehicleBody3D

@export var MAX_STEER = 0.5
@export var STEER_SPEED = 5.0
@export var BRAKE_POWER = 5.0 # Tipp: Stell das im Inspektor ruhig mal auf 3.0 runter!

# Neu: Wie schnell zieht die Bremse an? (Niedriger = Weicher)
var brake_ramp_speed = 2.0 

func _physics_process(delta):
	var speed = linear_velocity.length()
	
	# 1. LENKUNG (Unverändert)
	var steer_input = Input.get_axis("Steer Right", "Steer Left")
	var steer_limit = clamp(MAX_STEER * (15.0 / (speed + 15.0)), 0.1, MAX_STEER)
	steering = move_toward(steering, steer_input * steer_limit, delta * STEER_SPEED)

	# 2. ANTRIEB & BREMSE
	var input_vertical = Input.get_axis("Brake", "Accelerate")
	
	if input_vertical < 0: # User drückt Bremse (S-Taste / Pfeil runter)
		engine_force = 0.0
		
		# --- NEUE BREMSLOGIK ---
		
		# A: Dynamische Kraft
		# Wenn wir schnell sind (>10), nutzen wir nur einen Bruchteil der Bremskraft.
		# Das verhindert, dass die Räder sofort blockieren und das Auto vorne überkippt.
		var current_max_brake = BRAKE_POWER
		if speed > 15.0:
			current_max_brake = BRAKE_POWER * 0.2 # Nur 20% Kraft bei Highspeed
		elif speed > 5.0:
			current_max_brake = BRAKE_POWER * 0.5 # 50% Kraft bei mittlerem Speed
		
		# Ziel-Bremswert berechnen
		var target_brake = current_max_brake * abs(input_vertical)
		
		# B: "Ramp Up" (Sanfter Anstieg)
		# Wir nähern uns dem Zielwert langsam an, statt ihn hart zu setzen.
		# Das sorgt für den längeren Bremsweg.
		brake = move_toward(brake, target_brake, delta * brake_ramp_speed)
		
		# C: Stabilisierung (Gegen seitliches Rotieren beim Bremsen)
		# Wir erhöhen kurzzeitig die Rotations-Dämpfung, während gebremst wird.
		angular_damp = 0.5
		
	else:
		# Gas geben oder Rollen
		brake = 0.0
		# Dämpfung wieder auf Normalwert (z.B. im Inspektor Standard 0.0 oder 0.5)
		angular_damp = 0.5 
		
		if input_vertical > 0:
			engine_force = 0.0 * input_vertical # Dein Gas-Wert (ggf. anpassen)
		else:
			engine_force = 0.0
