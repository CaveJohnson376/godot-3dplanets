extends KinematicBody

const gravity = 98/2       # gravity accel
const sprintspeed = 12.5     # speed when sprinting
const defspeed = 7.5        # speed when walking
const accel = 20           # acceleration
var speed = 0              # current speed
const jumpspd = 12         # speed of jump. Jump height depends on this
const sensetivity = -0.005 # mouse input sensetivity
var velocity = Vector3(0, 0, 1)   # player character movement stuff
var mousemotion            # mouse motion
var tile = 0               # result of copying code from other project [LEGACY]
var isflying = false       # flying (for debug reasons)
var cratescene = preload("res://models/cubeblock_temp/cubeblock_crate.tscn")
var crate

# don't touch this
onready var cam = $offset/primarycam
onready var vecconv = $vectorconvertor

func _ready():
	# create crate preview
	crate = cratescene.instance()
	$"../builds".add_child(crate)
	
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
	
	# T key by default
	if Input.is_action_just_pressed("flight"):
		isflying = not isflying

func _physics_process(delta):
	# building preview
	if crate and $offset/primarycam/placeablock.is_colliding():
		var raypos = $offset/primarycam/placeablock.get_collision_point()
		var norm = $offset/primarycam/placeablock.get_collision_normal()
		crate.transform = $offset.global_transform
		crate.translation = raypos + norm * 0.5
	if not crate and $offset/primarycam/placeablock.is_colliding():
		crate = cratescene.instance()
		$"../builds".add_child(crate)
	if crate and not $offset/primarycam/placeablock.is_colliding():
		crate.queue_free()
	
	# building and deconstruct
	if Input.is_action_just_pressed("place"):
		crate.get_node("collider").disabled = false
		crate.add_to_group("block")
		crate = cratescene.instance()
		$"../builds".add_child(crate)
	if Input.is_action_just_pressed("remove"):
		var crate = $offset/primarycam/placeablock.get_collider()
		if crate and crate.is_in_group("block"):
			crate.queue_free()
		pass
	
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
	velocity = vecconv.vector_global_to_local(Transform($offset.global_transform.basis, Vector3()), velocity)
	
	# apply vertical forces (and move vertical movement to separate var)
	var vert_vel = velocity.z + jumpspd * int(Input.is_action_pressed("jump")) * (0.1 if isflying else int(is_on_floor())) - gravity * delta
	velocity.z = 0
	
	# apply horizontal forces (not perfect solution. TODO: moar polish and fix bunnyhop)
	var move = Vector3()
	move.y = -int(Input.is_action_pressed("backward"))+int(Input.is_action_pressed("forward"))
	move.x = int(Input.is_action_pressed("straferight"))-int(Input.is_action_pressed("strafeleft"))
	move = move.normalized()
	velocity = velocity.linear_interpolate(move * speed, accel * delta) if is_on_floor() else (velocity + (move * speed * delta))
	
	# restore vertical movement variable
	velocity.z = vert_vel
	
	# convert velocity back to global space
	velocity = vecconv.vector_local_to_global(Transform($offset.global_transform.basis, Vector3()), velocity)
	
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
	
