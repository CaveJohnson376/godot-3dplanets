extends KinematicBody

const gravity = 98/2       # gravity accel
const sprintspeed = 1000   # speed when sprinting
const defspeed = 250       # speed when walking
var speed = 250            # current speed
const jumpspd = 15         # speed of jump. Jump height depends on this
const sensetivity = -0.005 # mouse input sensetivity
var velocity = Vector3()   # player character movement stuff
var mousemotion            # mouse motion
var tile = 0               # result of copying code from other project [LEGACY]

# don't touch this
onready var cam = $offset/primarycam

func _ready():
	# make cursor captured
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _process(_delta):
	# lock/unlock mouse cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# it is cool to see stuff in the dark
	if Input.is_action_just_pressed("flashlight"):
		$offset/primarycam/SpotLight.visible = !$offset/primarycam/SpotLight.visible
	

func _physics_process(delta):
	# don't touch that
	var pos = translation
	var up = pos.normalized()
	
	# rotate player camera
	if mousemotion:
		cam.rotation.x = clamp(cam.rotation.x + (mousemotion.y * sensetivity), deg2rad(0), deg2rad(180))
		$offset.rotate_z(mousemotion.x*sensetivity)
		pass
	mousemotion = null # reset this or else it will mess things up
	
	# set active speed for player charcter
	speed = (sprintspeed if Input.is_action_pressed("speedup") else defspeed)*scale.x
	
	# convert velocity to local space
	velocity = $vectorconvertor.vector_global_to_local(Transform($offset.global_transform.basis, Vector3()), velocity)
	
	# apply vertical forces
	velocity.z += jumpspd * int(Input.is_action_pressed("jump")) * int(is_on_floor()) 
	velocity.z -= gravity * delta
	
	# apply horizontal forces (not perfect solution. TODO: remake and polish this)
	var move = Vector3()
	move.y = -int(Input.is_action_pressed("backward"))+int(Input.is_action_pressed("forward"))
	move.x = int(Input.is_action_pressed("straferight"))-int(Input.is_action_pressed("strafeleft"))
	velocity.y = move.y * speed * delta
	velocity.x = move.x * speed * delta
	
	# convert velocity back to global space
	velocity = $vectorconvertor.vector_local_to_global(Transform($offset.global_transform.basis, Vector3()), velocity)
	
	# apply velocity to player character
	velocity = move_and_slide(velocity, up, true)
	
	# planetary magic, completely not stolen from https://gitlab.com/LowBudgetTech/godot_walk_around_planet_3d
	transform = transform.orthonormalized()
	if transform.basis.y.normalized().cross(-up) != Vector3():
		look_at(Vector3(0, 0, 0), transform.basis.y)
	elif transform.basis.x.normalized().cross(-up) != Vector3():
		look_at(Vector3(0, 0, 0), transform.basis.x)
	
	pass

func _input(event):
	# read mouse motions
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mousemotion = event.relative
		pass
	
