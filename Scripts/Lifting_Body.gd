# TODO: Cange all the arrays sotring face data into an array of object instances

extends MeshInstance

export(float) var AREOFOIL_COEFFICIENT = 0
export(NodePath) var ROTATION_PARENT = null
export(bool) var DEBUG_MODE = false

var mdt = MeshDataTool.new()
var total_area = 0.00
var test_mode = false

var faces = []

var face_area = []
var face_centre = []

var face_normals = []

func _ready():
	# Figure out the area of the mesh
	
	# Iterate through each face, set the normals, face area, and add a face instance to the array of faces
	var verticies = mesh.get_faces()
	var face = []
	# For every face:
	for i in range(mesh.get_surface_count()):
		# Create a new instance of a face
		faces.append(load("res://Scripts/Face.gd").new())
		# Set the normal of the face
		faces[i].set_normal(mesh.surface_get_arrays(i)[1])
		# Set the area of the face
		for vertex in range(i * 3, (i * 3) + 3):
			face.append(verticies[vertex])
			if(face.size() == 3):
				# Calculate the area of each face
				var a = Vector3(face[0]).distance_to(Vector3(face[1]))
#				print(a)
				var b = Vector3(face[1]).distance_to(Vector3(face[2]))
#				print(b)
				var c = Vector3(face[0]).distance_to(Vector3(face[2]))
#				print(c)
				
				var s = (a+b+c)/2
				
				faces[i].set_area(sqrt(s*(s-a)*(s-b)*(s-c)))
				faces[i].set_centre_point((a+b+c)/2)
				
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

func calculate_lift(delta, mass, velocity_vector, parent_rotation):
	
	
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
#	# Return a Vector3 based off of the lift alcualtions for every normal, then devide it by the amount of normals
#	for i in faces:
#		force_average += Vector3(i.get_normal()[0]) + parent_rotation + global_transform.basis.y * i.get_area()

	for i in faces:
		force_average += velocity_vector * i.get_area() * cos((i.get_normal()[0] + parent_rotation + global_transform.basis.y).angle_to(velocity_vector))
	# Return a Vector3 based off of the lift alcualtions for every normal, then devide it by the amount of normals

	force_average /= faces.size()
	force = force_average * delta
	$debug.clear()
	$debug.begin(Mesh.PRIMITIVE_LINES)
	$debug.add_vertex(Vector3(0,0,0))
	$debug.add_vertex(force)
	$debug.end()
	
	return force + parent_rotation + global_transform.basis.y

func set_debug_mode(mode):
	DEBUG_MODE = mode
	visible = mode
