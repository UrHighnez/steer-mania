extends VehicleBody3D

@export var MAX_STEER = 0.5
@export var STEER_SPEED = 6.0 
@export var BRAKE_POWER = 6.0 

var brake_ramp_speed = 2.0 

# Dämpfungswerte
var damp_loose = 0.5  # Normales Fahren
var damp_stable = 3.0  # Bremsen
var damp_boost = 6.0   # Raketen-Modus

# Propulsion Vars
var prop_force: float = 0.0
var fuel_max: float = 0.0
var fuel_current: float = 0.0
var has_propulsion: bool = false

func _physics_process(delta):
	var speed = linear_velocity.length()
	
	# 1. LENKUNG
	var steer_input = Input.get_axis("Steer Right", "Steer Left")
	
	# TWEAK: Bei Boost-Speed (>25) lenken wir noch weniger, um Ausbrechen zu verhindern
	var steer_limit_factor = 15.0
	if has_propulsion and fuel_current > 0 and Input.get_axis("Brake", "Accelerate") > 0:
		steer_limit_factor = 30.0 # Lenkung wird 'tauber' beim Boost
		
	var steer_limit = clamp(MAX_STEER * (15.0 / (speed + steer_limit_factor)), 0.05, MAX_STEER)
	var target_steer = steer_input * steer_limit
	steering = lerp(steering, target_steer, delta * STEER_SPEED)

	# 2. INPUT LOGIK
	var input_vertical = Input.get_axis("Brake", "Accelerate")
	
	if input_vertical < 0: # BREMSEN
		engine_force = 0.0
		var current_max_brake = BRAKE_POWER
		if speed > 15.0: current_max_brake = BRAKE_POWER * 0.2
		elif speed > 5.0: current_max_brake = BRAKE_POWER * 0.5
		
		var target_brake = current_max_brake * abs(input_vertical)
		brake = move_toward(brake, target_brake, delta * brake_ramp_speed)
		angular_damp = damp_stable
		
	else: # FAHREN / ROLLEN
		brake = 0.0
		
		# Standard-Annahme: Wir sind "locker"
		angular_damp = damp_loose 
		
		if input_vertical > 0:
			# PROPULSION LOGIK
			if has_propulsion and fuel_current > 0:
				# 1. Kraft anwenden
				var force_dir = -global_transform.basis.z
				apply_central_force(force_dir * prop_force)
				
				# 2. FIX: STABILISIERUNG!
				# Wir erhöhen die Dämpfung massiv, damit das Heck nicht den Kopf überholt.
				angular_damp = damp_boost 
				
				# Tank leeren
				fuel_current -= delta
			
			engine_force = 0.0 
		else:
			engine_force = 0.0
			
# Setup Funktion bleibt gleich
func setup_propulsion(p_force: float, p_duration: float):
	has_propulsion = true
	prop_force = p_force
	fuel_max = p_duration
	fuel_current = p_duration
