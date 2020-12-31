extends MeshInstance

export(float) var AREOFOIL_COEFFICIENT = 0
export(NodePath) var ROTATION_PARENT = null
export(bool) var DEBUG_MODE = false

var mdt = MeshDataTool.new()
var total_area = 0.00
var test_mode = false

var face_area = []
var face_centre = []

var face_normals = []

func _ready():
	
	# Figure out the area of the mesh
	
	# Get normals
	for i in range(mesh.get_surface_count()):
		face_normals = mesh.surface_get_arrays(i)[1]
	
	var face = []
	for vertex in mesh.get_faces():
		face.append(vertex)
		if(face.size() == 3):
			# Calculate the area of each face
			var a = Vector3(face[0]).distance_to(Vector3(face[1]))
#			print(a)
			var b = Vector3(face[1]).distance_to(Vector3(face[2]))
#			print(b)
			var c = Vector3(face[0]).distance_to(Vector3(face[2]))
#			print(c)
			
			var s = (a+b+c)/2
			
			face_area.append(sqrt(s*(s-a)*(s-b)*(s-c)))
			face_centre.append((a+b+c)/2)
			
			# Reset face
			face = []
	
	# Calculate total area of mesh
	for area in face_area:
		total_area += area
	
	print (total_area)
	
	# Set shader params
	set_debug_mode(DEBUG_MODE)

func calculate_lift(delta, mass, velocity_vector, parent_rotation):
	
	var sine_average = 0
	
	var count = 0
	
	for i in face_normals:
		sine_average += sin((Vector3(i) + parent_rotation + global_transform.basis.y).angle_to(velocity_vector))
	
	sine_average /= face_area.size()
	print(sine_average)
	
	return Vector3(0,0,0)

func set_debug_mode(mode):
	DEBUG_MODE = mode
	visible = mode
