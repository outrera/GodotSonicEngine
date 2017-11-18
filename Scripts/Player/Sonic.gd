extends KinematicBody2D

var move_dir = Vector2 (0, 0)
var dir_sign = Vector2 (0, 0)
var speed = Vector2 (0, 0)
var velocity = Vector2 (0, 0)
var break_time = 0
var anim_speed = 0

export(int) var rings = 0		# Number of rings the player has.
export(int) var lives = 3		# Lives left.
export(int) var score = 0		# Score.
export(Vector2) var checkpoint_pos	# Where was the last checkpoint? Make sure to set this to (0, 0) when on a new level etc.

# Set up sprite_anim and sprite_anim_node. The _node variable points to the animation node, of course.
# sprite_anim contains the animation currently playing.
onready var sprite_anim_node = get_node ("AnimatedSprite")
onready var sprite_anim = sprite_anim_node.get_animation ()	# Make sure sprite_anim contains the default animation value.
onready var sprite_anim_frames = sprite_anim_node.get_sprite_frames ()

const ACCEL_RATE = 0.046875
const DECEL_RATE = 0.5
const FRICTION = ACCEL_RATE
const TOP_SPEED = Vector2 (6, 6)

func _ready():
	print ("Sonic entered the world at ", get_pos ())
	set_fixed_process (true)
	return

# change_anim
# func change_anim (new_anim)
# Changes the currently playing animation to one specified (by new_anim). Won't change the animation if it's already playing.
# Returns true if the animation has changed, false otherwise.
# TODO: Maybe make this function able to change direction animation plays in, etc.?
func change_anim (new_anim):
	if (new_anim != sprite_anim):	# This is a new animation...
		sprite_anim = new_anim		# ...so set sprite_anim to new_anim.
		sprite_anim_node.set_animation (sprite_anim)	# And make the sprite animation node play the new animation.
#		sprite_anim_node.set_animation_speed (sprite_anim, anim_speed)	#Changes the the speed by frames
#		sprite_anim_frames.set_animation_speed (sprite_anim, anim_speed)	#Changes the the speed by frames
		return (true)
	return (false)

func _fixed_process (delta):
	if (dir_sign.x != 0):	# If the direction isn't 0, make sure it's consistent.
		move_dir.x = dir_sign.x	# move_dir.x is used to calculate the direction of movement in the x axis; dir_sign.x is for changing it.

	# Direction is -1 if Sonic is moving left/up, 1 if right/down, and 0 otherwise.
	# Can only move in one direction at a time (so pressing left while holding down right won't work)!
	if (Input.is_action_pressed ("move_left") && dir_sign.x != 1):
		dir_sign.x = -1
		sprite_anim_node.set_flip_h (true)
	elif (Input.is_action_pressed ("move_right") && dir_sign.x != -1):
		dir_sign.x = 1
		sprite_anim_node.set_flip_h (false)
	else:
		dir_sign.x = 0

	if (Input.is_action_pressed ("move_jump")):
		print ("AAAA")

	if (dir_sign.x):
		if (speed.x < TOP_SPEED.x):
			speed.x += ACCEL_RATE	# Speed Sonic up until he is at top speed.
	else:
		if (speed.x > 0):
			speed.x -= FRICTION	# Slow Sonic down according to the friction rating.

	#AnimationChange
#	anim_speed = max(4-(abs(speed.x)), 1)
	
	if (speed.x > 0 && speed.x < 3):
		change_anim ("Walk")
	elif (speed.x >= 3):
		change_anim ("Jog")
	else:
		change_anim ("Idle")	# This is the default animation.

	### KEEP THESE AT THE BOTTOM OF THE FUNCTION, THESE ACTUALLY DO THE MOVEMENT AFTER EVERYTHING ELSE IS PROCESSED AND CALCULATED.
	velocity.x = (speed.x * move_dir.x)	# Set the velocity for Sonic's movement on the x axis.
	velocity.y = (speed.y * move_dir.y)	# Ditto for the y axis.
	move (Vector2 (velocity.x, velocity.y))	# And move Sonic appropriately.

	return

