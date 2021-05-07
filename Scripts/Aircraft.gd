extends RigidBody

export(bool) var DEBUG_MODE = false
export(Array, NodePath) var LIFTING_BODIES = []
export(float) var CONTROL_SURFACE_SPEED = 1
export(float, 1, 15) var THROTTLE_BIAS = 1

var lifting_bodies = []

var throttle = 300
var accel = 300

var test = true

func _ready():
	# Add all of the Lifting_Bodies to an array
	for node_path in LIFTING_BODIES:
		lifting_bodies.append(get_node(node_path))
		get_node(node_path).set_debug_mode(DEBUG_MODE)
	set_friction(0)
	# Initial speed
	linear_velocity = global_transform.basis.z * -150

func _physics_process(delta):
	var velocity = Vector3(0,0,0).distance_to(linear_velocity)
	
	# Limits for loop output to only the first iteration
	test = true

	for lifting_body in lifting_bodies:
		# Force is added by getting the force from the lifting body;
		# Rotating it based off of the orientation of the aircraft;
		# Offsetting it based off of the orientation of the aircraft
		
		# Get the force vector from the lifting body
		var force = lifting_body.calculate_lift(delta, velocity, linear_velocity)
#		if(test): print(force)
		
		# Rotational axis is the cross product of "global up" and the aircraft's current "up" vector
		var axis = Vector3(0,1,0).cross(global_transform.basis.y).normalized()
#		if(test): print(axis)
		
		# Rotational angle is the angle between global "up" and the aircraft's current "up" vector
		var angle = Vector3(0,1,0).angle_to(global_transform.basis.y.normalized())
#		if(test): print(angle)
		
		# The force rotated local to the aircraft
		# If there is no axis, then apply the force as-is,
		# Otherwise, rotate the force
		var rotated_force = force
		if(axis != Vector3(0,0,0)):
			rotated_force = force.rotated(axis, angle)
#		if(test): print(rotated_force)
		
		
#		add_force(lifting_body.calculate_lift(delta, velocity, linear_velocity).rotated(Vector3(0,1,0).cross(global_transform.basis.y).normalized(),Vector3(0,1,0).angle_to(global_transform.basis.y)), lifting_body.translation)
		# Add force uses the global co-ordinate system, so the translation of the lifting body needs to be offset
		var x_moved = global_transform.basis.x * lifting_body.translation.x
		var y_moved = global_transform.basis.y * lifting_body.translation.y
		var z_moved = global_transform.basis.z * lifting_body.translation.z
		
		add_force(rotated_force, x_moved + y_moved + z_moved)
		
		test = false
		pass
	
	if Input.is_action_pressed("pitch_down"):
		$H_Control.rotation = lerp($H_Control.rotation, Vector3(0.5,0,0) * Input.get_action_strength("pitch_down"), CONTROL_SURFACE_SPEED*delta)
#		$H_Control.rotation = Vector3(0.5,0,0)
#		add_force(global_transform.basis.y*300, global_transform.basis.z*5)
	
	elif Input.is_action_pressed("pitch_up"):
		$H_Control.rotation = lerp($H_Control.rotation, Vector3(-0.5,0,0) * Input.get_action_strength("pitch_up"), CONTROL_SURFACE_SPEED*delta)
#		$H_Control.rotation = Vector3(-0.5,0,0)
#		add_force(global_transform.basis.y*-300, global_transform.basis.z*5)

	else:
		$H_Control.rotation = lerp($H_Control.rotation, Vector3(0,0,0), CONTROL_SURFACE_SPEED*delta)
#		$H_Control.rotation = Vector3(0,0,0)
	
	if Input.is_action_pressed("roll_CW"):
		$Left_Control.rotation = lerp($Left_Control.rotation, Vector3(0.5,0,0) * Input.get_action_strength("roll_CW"), CONTROL_SURFACE_SPEED*delta)
#		$Left_Control.rotation = Vector3(0.5,0,0)
		$Right_Control.rotation = lerp($Right_Control.rotation, Vector3(-0.5,0,0) * Input.get_action_strength("roll_CW"), CONTROL_SURFACE_SPEED*delta)
#		$Right_Control.rotation = Vector3(-0.5,0,0)
#		add_force(global_transform.basis.y*300, global_transform.basis.x * -3.246)
	
	elif Input.is_action_pressed("roll_ACW"):
		$Left_Control.rotation = lerp($Left_Control.rotation, Vector3(-0.5,0,0) * Input.get_action_strength("roll_ACW"), CONTROL_SURFACE_SPEED*delta)
#		$Left_Control.rotation = Vector3(-0.5,0,0)
		$Right_Control.rotation = lerp($Right_Control.rotation, Vector3(0.5,0,0) * Input.get_action_strength("roll_ACW"), CONTROL_SURFACE_SPEED*delta)
#		$Right_Control.rotation = Vector3(0.5,0,0)
#		add_force(global_transform.basis.y*300, global_transform.basis.x * 3.246)
	
	else:
		$Left_Control.rotation = lerp($Left_Control.rotation, Vector3(0,0,0), CONTROL_SURFACE_SPEED*delta)
#		$Left_Control.rotation = Vector3(0,0,0)
		$Right_Control.rotation = lerp($Right_Control.rotation, Vector3(0,0,0), CONTROL_SURFACE_SPEED*delta)
#		$Right_Control.rotation = Vector3(0,0,0)
	
	if Input.is_action_pressed("yaw_left"):
#		$"V_Stab".rotation = Vector3(0,-0.4,0)
		add_force(global_transform.basis.x*300 * Input.get_action_strength("yaw_left"), global_transform.basis.z*5)
	
	elif Input.is_action_pressed("yaw_right"):
#		$"V_Stab".rotation = Vector3(0,0.4,0)
		add_force(global_transform.basis.x*-300 * Input.get_action_strength("yaw_right"), global_transform.basis.z*5)
		
	else:
#		$"V_Stab".rotation = Vector3(0,0,0)
		pass
	
	if Input.is_action_pressed("acc"):
		throttle += 1
	
	if Input.is_action_pressed("dec"):
		throttle -= 1
	
	throttle = clamp(throttle, 0, 300)
	
	# Slower to accelerate than deccelarate
	if(throttle >= accel):
		accel = lerp(accel, throttle, THROTTLE_BIAS * delta)
	else:
		accel = lerp(accel, throttle, THROTTLE_BIAS * 10 * delta)
	
	accel = clamp(accel, 10, 300)
	
	# Change the pitch of the engine sound, between 1 and 1.8, depending on the accelaration value
	$engine.pitch_scale = accel * 0.003  + 1
	$object/spitfirePropSlow.rotate_z(-accel*0.1)
	add_force(global_transform.basis.z*-accel*20, Vector3(0,0,0))
	#Add drag
	add_force(linear_velocity * -velocity * 0.001, Vector3(0,0,0))
	print(throttle)
	print(accel)
	print(velocity)
	
	# Purely for fun
	if Input.is_action_pressed("fire"):
		$object/leftGun.emitting = true
		$object/rightGun.emitting = true
	
	else:
		$object/leftGun.emitting = false
		$object/rightGun.emitting = false
	
#	print(accel)
#	print(velocity)
#	print(translation.y)
	
	
#	print(linear_velocity)
#	print(angular_velocity)
