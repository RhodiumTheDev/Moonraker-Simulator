extends MeshInstance

export(float) var AREOFOIL_COEFFICIENT = 0
export(NodePath) var ROTATION_PARENT = null
export(bool) var DEBUG_MODE = false
export(int, -1, 1, 1) var WING_AUTH = 0

var mdt = MeshDataTool.new()
var total_area = 0.00
var test_mode = false

var faces = []

var face_area = []
var face_centre = []

var face_normals = []

func _ready():
	# Figure out the area of the mesh
	print("Using mdt")
	mdt.create_from_surface(mesh, 0)
	
	# Iterate through each face, set the normals, face area, and add a face instance to the array of faces
	var verticies = mesh.get_faces()
	
	# Interstingly enough, mesh.get_faces() returns one too many faces which is a copy of the first one
	# This stores a reference of the first face, which the last face will check against
	# If they are equal, then the last face will be ignored
	var first_face = [verticies[0], verticies[1], verticies[2]]
#	print(first_face)
	
	var face = []
	# For every face:
	# mesh.get_surface_count()
	for i in range(mdt.get_face_count()):
		# Create a new instance of a face
		faces.append(load("res://Scripts/Face.gd").new())

		# Calculate the area of each triangular face
		# Get each edge of the tri
		# Calculate the area of the tri
		# Calculate the centre point of each tri

		# Get each vertex as a vector
		var a = mdt.get_vertex(mdt.get_face_vertex(i, 0))
		var b = mdt.get_vertex(mdt.get_face_vertex(i, 1))
		var c = mdt.get_vertex(mdt.get_face_vertex(i, 2))
		
#		print(a)
#		print(b)
#		print(c)

		# Get each edge length as the distance to each vertex
		var ab = a.distance_to(b)
#				print(ab)
		var bc = b.distance_to(c)
#				print(bc)
		var ac = a.distance_to(c)
#				print(ac)

		# Calcuate and set the surface area
		var s = (ab+bc+ac)/2
		faces[i].set_area(s)

		# Set the centre point of the face
		# This isn't an exact centre, but is accurate enough for now
		faces[i].set_centre_point((a+b+c)/2)
		
		# Set the tri's normal
		faces[i].set_normal((b - c).cross(a - b).normalized())
		
		# Reset face
		face = []
	
	# Get normals
#	for i in range(mesh.get_surface_count()):
#		face_normals = mesh.surface_get_arrays(i)[1]

#	var face = []
#	for vertex in mesh.get_faces():
#		face.append(vertex)
#		if(face.size() == 3):
#			# Calculate the area of each face
#			var a = Vector3(face[0]).distance_to(Vector3(face[1]))
##			print(a)
#			var b = Vector3(face[1]).distance_to(Vector3(face[2]))
##			print(b)
#			var c = Vector3(face[0]).distance_to(Vector3(face[2]))
##			print(c)
#
#			var s = (a+b+c)/2
#
#			face_area.append(sqrt(s*(s-a)*(s-b)*(s-c)))
#			face_centre.append((a+b+c)/2)
#
#			# Reset face
#			face = []
	
	# Calculate total area of mesh
	for i in faces:
		total_area += i.get_area()
	
	print (total_area)
	
	# Set shader params
	set_debug_mode(DEBUG_MODE)

func calculate_lift(delta, velocity, velocity_vector):
	var sine_average = 0
	var force_average = Vector3(0,0,0)
	var force = Vector3(0,0,0)
	
	# Best for aerofoils
#	# Get the average sine between the normal directions and the velocity direction
#	# This could possibly be changed to use the dot product in future implementations of the physics engine
#	# However, sign returns from -1 to 1, but a dot product is ~-3 to 1, so this could not work as intended.
#
#	for i in faces:
#		sine_average += cos((i.get_normal()[0] + parent_rotation + global_transform.basis.y).angle_to(velocity_vector))
#
#	sine_average /= faces.size()
#	print(parent_rotation)
#
#	# Return a Vector3 based off of the lift alcualtions for every normal, then divide it by the amount of normals
#	for i in faces:
#		force_average += Vector3(i.get_normal()[0]) + parent_rotation + global_transform.basis.y * i.get_area()
	$debug.clear()
	$debug.begin(Mesh.PRIMITIVE_LINES)
	for i in faces:
		# TODO: Change to remove reliance on global transform basis y
		# look_at might be useful
#		var loc_force = velocity_vector * i.get_area() * cos((i.get_normal() + parent_rotation  + (global_transform.basis.y * float(WING_AUTH))).angle_to(velocity_vector))
#		
		var loc_force = (i.get_normal()*cos(global_transform.basis.y.angle_to(velocity_vector))*-1*i.get_area() * velocity * 10) + (i.get_normal() * (sin(global_transform.basis.y.angle_to(velocity_vector)) * AREOFOIL_COEFFICIENT) * velocity)
		force_average += loc_force
		$debug.add_vertex(i.get_centre_point())
		$debug.add_vertex(i.get_centre_point()+loc_force*0.001)
	$debug.end()
	
	# Return a Vector3 based off of the lift alcualtions for every normal, then devide it by the amount of normals
	force_average /= faces.size()
	force = force_average * delta
	
	
	return force * 50
#	return force + parent_rotation

func set_debug_mode(mode):
	DEBUG_MODE = mode
	visible = mode
