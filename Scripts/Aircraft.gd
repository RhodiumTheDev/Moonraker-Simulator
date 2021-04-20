extends RigidBody

export(bool) var DEBUG_MODE = false
export(Array, NodePath) var LIFTING_BODIES = []

var lifting_bodies = []

func _ready():
	# Add all of the Lifting_Bodies to an array
	for node_path in LIFTING_BODIES:
		lifting_bodies.append(get_node(node_path))
		get_node(node_path).set_debug_mode(DEBUG_MODE)
	
func _physics_process(delta):
	for lifting_body in lifting_bodies:
		add_force(lifting_body.calculate_lift(delta, mass, linear_velocity, global_transform.basis.y), lifting_body.translation)
		pass
	
#	print(linear_velocity)
#	print(angular_velocity)
