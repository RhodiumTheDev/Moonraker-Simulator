extends RigidBody

export(bool) var DEBUG_MODE = false
export(Array, NodePath) var LIFTING_BODIES = []

var lifting_bodies = []

var accel = 0

var test = true

func _ready():
	# Add all of the Lifting_Bodies to an array
	for node_path in LIFTING_BODIES:
		lifting_bodies.append(get_node(node_path))
		get_node(node_path).set_debug_mode(DEBUG_MODE)
	set_friction(0)

func _physics_process(delta):
	var velocity = Vector3(0,0,0).distance_to(linear_velocity)
	
	# Limits for loop output to only the first iteration
	test = true

	for lifting_body in lifting_bodies:
		# Although rotated, this is not offset
		# Force is added by getting the force from the lifting body
		# Rotating it based off of the orientation of the aircraft
		# Applying it based off of the orientation of the aircraft
		
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
		$H_Control.rotation = Vector3(0.5,0,0)
#		add_force(global_transform.basis.y*300, global_transform.basis.z*5)
	
	elif Input.is_action_pressed("pitch_up"):
		$H_Control.rotation = Vector3(-0.5,0,0)
#		add_force(global_transform.basis.y*-300, global_transform.basis.z*5)

	else:
		$H_Control.rotation = Vector3(0,0,0)
	
	if Input.is_action_pressed("roll_CW"):
		$Left_Control.rotation = Vector3(0.5,0,0)
		$Right_Control.rotation = Vector3(-0.5,0,0)
#		add_force(global_transform.basis.y*300, global_transform.basis.x * -3.246)
	
	elif Input.is_action_pressed("roll_ACW"):
		$Left_Control.rotation = Vector3(-0.5,0,0)
		$Right_Control.rotation = Vector3(0.5,0,0)
#		add_force(global_transform.basis.y*300, global_transform.basis.x * 3.246)
	
	else:
		$Left_Control.rotation = Vector3(0,0,0)
		$Right_Control.rotation = Vector3(0,0,0)
	
	if Input.is_action_pressed("yaw_left"):
#		$"V_Stab".rotation = Vector3(0,-0.4,0)
		add_force(global_transform.basis.x*300, global_transform.basis.z*5)
	
	elif Input.is_action_pressed("yaw_right"):
#		$"V_Stab".rotation = Vector3(0,0.4,0)
		add_force(global_transform.basis.x*-300, global_transform.basis.z*5)
		
	else:
#		$"V_Stab".rotation = Vector3(0,0,0)
		pass
	
	if Input.is_action_pressed("acc"):
		accel += 1
	
	if Input.is_action_pressed("dec"):
		accel -= 1
	
	accel = clamp(accel, 0, 150)
	add_force(global_transform.basis.z*-accel*50, Vector3(0,0,0))
#	print(accel)
#	print(velocity)
#	print(translation.y)
	
	
#	print(linear_velocity)
#	print(angular_velocity)
