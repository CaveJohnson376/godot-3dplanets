extends Spatial
# Object tracker by CaveJ376 v.1.0 special edition
#
# Orientation space is used for translation reasons only!
# most of this is shitcode mostly rn, later on i will clean this up

# EDIT THESE FROM INSPECTOR ONLY!!!
export (NodePath) var object_to_track
export (int) var mult = 1 
export (int, "physics", "render") var process_type = false
export (int, "global", "global-space offset", "local") var tracker_translation_space = 0
export (int, "global", "global-space offset", "local") var object_translation_space = 0

func check_for_errors():
	if (object_to_track == "."):
		push_error("Object tracker: Invalid path - empty path!")
		return false
	elif (not get_node(object_to_track)):
		push_error("Object tracker: Invalid path - Node is not found!")
		return false
	elif not (get_node(object_to_track) is Spatial):
		push_error("Object tracker: Tracked object is NOT Spatial!")
		return false
	else:
		return true

func track():
	var object = get_node(object_to_track)
	var objpar = object.get_node("..")
	var pos = Vector3()
	
	# get offset pos
	match object_translation_space:
		0: # global space
			pos = object.global_transform.origin
		1: # global space, but parent is in (0, 0, 0)
			if objpar is Spatial:
				pos = object.global_transform.origin - objpar.global_transform.origin
			else:
				pos = object.global_transform.origin
		2: # local to parent's space
			pos = object.translation
		_:
			push_error("Object tracker: unexistant space mode")
	
	# multiplier, because why not
	pos *= mult
	
	# change tracker pos
	match tracker_translation_space:
		0: # global space
			global_transform.origin = pos
		1: # global space, but parent is in (0, 0, 0)
			if objpar is Spatial:
				global_transform.origin = pos + $"..".global_transform.origin
			else:
				global_transform.origin = pos
		2: # local to parent's space
			translation = pos
		_:
			push_error("Object tracker: unexistant space mode")
	
	pass

func _process(delta):
	
	if check_for_errors() and not process_type:
		track()
	
	

func _physics_process(delta):
	if check_for_errors() and process_type:
		track()
