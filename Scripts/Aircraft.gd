extends RigidBody

export(bool) var DEBUG_MODE = false
export(Array, NodePath) var LIFTING_BODIES = []

var lifting_bodies = []

var accel = 0

func _ready():
	# Add all of the Lifting_Bodies to an array
	for node_path in LIFTING_BODIES:
		lifting_bodies.append(get_node(node_path))
		get_node(node_path).set_debug_mode(DEBUG_MODE)
	set_friction(0)
	
func _physics_process(delta):
	var velocity = Vector3(0,0,0).distance_to(linear_velocity)

	for lifting_body in lifting_bodies:
		add_force(lifting_body.calculate_lift(delta, velocity, linear_velocity).rotated((Vector3(0,1,0).cross(global_transform.basis.y)).normalized(), Vector3(0,1,0).angle_to(global_transform.basis.y)), lifting_body.translation)
		pass
	
	if Input.is_action_pressed("pitch_down"):
		add_force(global_transform.basis.y*300, global_transform.basis.z*5)
	
	if Input.is_action_pressed("pitch_up"):
		add_force(global_transform.basis.y*-300, global_transform.basis.z*5)
	
	if Input.is_action_pressed("roll_CW"):
		add_force(global_transform.basis.y*300, global_transform.basis.x * -3.246)
	
	if Input.is_action_pressed("roll_ACW"):
		add_force(global_transform.basis.y*300, global_transform.basis.x * 3.246)
	
	if Input.is_action_pressed("yaw_left"):
		add_force(global_transform.basis.x*300, global_transform.basis.z*5)
	
	if Input.is_action_pressed("yaw_right"):
		add_force(global_transform.basis.x*-300, global_transform.basis.z*5)
	
	
	
	if Input.is_action_pressed("acc"):
		accel += 1
	
	if Input.is_action_pressed("dec"):
		accel -= 1
	
	accel = clamp(accel, 0, 150)
	add_force(global_transform.basis.z*-accel*100, Vector3(0,0,0))
	print(accel)
	print(velocity)
	print(translation.y)
	
	
#	print(linear_velocity)
#	print(angular_velocity)
