# Face object to store each face's:
# - Area
# - Centre Point
# - Normal

var area = 0
var normal = Vector3(0,0,0)
var centre = Vector3(0,0,0)

func set_area(area):
	self.area = area

func set_normal(normal):
	self.normal = normal

func set_centre_point(centre):
	self.centre = centre

func get_area():
	return area

func get_normal():
	return normal

func get_centre_point():
	return centre
