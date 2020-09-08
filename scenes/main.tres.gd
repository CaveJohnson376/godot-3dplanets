extends Spatial

# Do not touch these (use inspector instead)
export var colordark = Color() # color of sky during night time
export var colorlight = Color() # color of sky during day time
export(Curve) var colorramp # this controls, how sky changes the color
export var daylightcycleduration = 600 # daylight cycle duration, in seconds

func _ready():
	# this one is required to work properly
	colorramp.bake()
	pass

func _process(delta):
	# daylight cycle! 
	$rotating_sun.rotation_degrees.z -= delta * 360/daylightcycleduration
	
	if colorramp:
		# sky color depends on player position relative to sun position
		var lookingatsun = range_lerp($player.translation.normalized().dot($rotating_sun/offset/sunlight.global_transform.origin.normalized()), -1, 1, 0, 1)
		# this generates resulting sky color
		var skycolor = colordark.linear_interpolate(colorlight, colorramp.interpolate(lookingatsun))
		# and this sets sky color
		$WorldEnvironment.environment.background_color = skycolor
		$WorldEnvironment.environment.fog_color = skycolor
	pass

func _input(event):
	# restart everything in case something went wrong
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
