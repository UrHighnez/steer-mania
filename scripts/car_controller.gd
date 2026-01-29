extends VehicleBody3D

@export var MAX_STEER = 0.5
# Etwas niedrigerer Speed, da lerp sich anders anfühlt als move_toward
@export var STEER_SPEED = 6.0 
@export var BRAKE_POWER = 6.0 

var brake_ramp_speed = 2.0 

# Dämpfungswerte für "Charakter" vs. "Sicherheit"
var damp_loose = 0.05  # Niedrig = Wackelig / Lebendig (für normales Rollen)
var damp_stable = 0.8  # Hoch = Stabil / "Festhaltend" (nur beim Bremsen)

func _physics_process(delta):
	var speed = linear_velocity.length()
	
	# -----------------------------------------------------------
	# 1. LENKUNG (Jetzt "Organic" mit Lerp)
	# -----------------------------------------------------------
	var steer_input = Input.get_axis("Steer Right", "Steer Left")
	
	# Deine Logik: Weniger Lenkeinschlag bei hohem Speed
	var steer_limit = clamp(MAX_STEER * (15.0 / (speed + 15.0)), 0.1, MAX_STEER)
	var target_steer = steer_input * steer_limit
	
	# ÄNDERUNG: lerp statt move_toward
	# Das macht die Lenkung am Anfang reaktiv, aber zum Ende hin "weich".
	# Es verhindert das zackige "Einrasten" auf den vollen Winkel.
	steering = lerp(steering, target_steer, delta * STEER_SPEED)

	# -----------------------------------------------------------
	# 2. BREMSE & WACKEL-LOGIK
	# -----------------------------------------------------------
	var input_vertical = Input.get_axis("Brake", "Accelerate")
	
	if input_vertical < 0: # Bremsen
		engine_force = 0.0
		
		# Dynamische Bremskraft (Verhindert Front-Flip)
		var current_max_brake = BRAKE_POWER
		if speed > 15.0:
			current_max_brake = BRAKE_POWER * 0.2
		elif speed > 5.0:
			current_max_brake = BRAKE_POWER * 0.5
		
		var target_brake = current_max_brake * abs(input_vertical)
		brake = move_toward(brake, target_brake, delta * brake_ramp_speed)
		
		# ÄNDERUNG: Starke Dämpfung NUR beim Bremsen
		# Hier wollen wir Kontrolle, damit das Heck nicht ausbricht oder er kippt.
		angular_damp = damp_stable
		
	else: # Rollen / Fahren
		brake = 0.0
		
		# ÄNDERUNG: "Leine loslassen"
		# Wir reduzieren die Dämpfung massiv. 
		# Das erlaubt dem Auto, auf Bodenwellen leicht hin und her zu schaukeln (Body Roll).
		angular_damp = damp_loose 
		
		if input_vertical > 0:
			# Da Seifenkiste: Eventuell hier engine_force ganz rausnehmen 
			# oder nur minimalen "Push" erlauben (Cheating für Gameplay)
			engine_force = 0.0 
		else:
			engine_force = 0.0
