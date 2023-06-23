class_name RigidBodyPlayer
extends RigidBody2D

@export var input_left : String = "move_left"
@export var input_right : String = "move_right"
@export var input_jump : String = "jump"
@export var  WALK_ACCEL:float = 500.0
@export var  WALK_DEACCEL:float = 500.0
@export var  WALK_MAX_VELOCITY:float = 140.0
@export var  AIR_ACCEL:float = 100.0
@export var  AIR_DEACCEL:float = 100.0
@export var  JUMP_VELOCITY:float = 380
@export var  STOP_JUMP_FORCE:float = 450.0
@export var  MAX_SHOOT_POSE_TIME:float = 0.3
@export var  MAX_FLOOR_AIRBORNE_TIME:float = 0.15

var siding_left = false
var jumping = false
var stopping_jump = false
var shooting = false

var floor_h_velocity = 0.0

var airborne_time = 1e20
var shoot_time = 1e20

@onready var sprite = $Sprite2D

func _integrate_forces(state):
	var lv = state.get_linear_velocity()
	var step = state.get_step()
	var new_siding_left = siding_left
	var move_left = Input.get_action_strength(input_left)
	var move_right = Input.get_action_strength(input_right)
	var jump = Input.is_action_pressed(input_jump)

	# Deapply prev floor velocity.
	lv.x -= floor_h_velocity
	floor_h_velocity = 0.0

	# Find the floor (a contact with upwards facing collision normal).
	var found_floor = false
	var floor_index = -1

	for x in range(state.get_contact_count()):
		var ci = state.get_contact_local_normal(x)

		if ci.dot(Vector2(0, -1)) > 0.6:
			found_floor = true
			floor_index = x
	# A good idea when implementing characters of all kinds,
	# compensates for physics imprecision, as well as human reaction delay.
	if found_floor:
		airborne_time = 0.0
	else:
		airborne_time += step # Time it spent in the air.

	var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME

	# Process jump.
	if jumping:
		if lv.y > 0:
			# Set off the jumping flag if going down.
			jumping = false
		elif not jump:
			stopping_jump = true

		if stopping_jump:
			lv.y += STOP_JUMP_FORCE * step

	if on_floor:
		# Process logic when character is on floor.
		if move_left and not move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= WALK_ACCEL * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += WALK_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= WALK_DEACCEL * step
			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv

		# Check jump.
		if not jumping and jump:
			lv.y = -JUMP_VELOCITY
			jumping = true
			stopping_jump = false
	else:
		# Process logic when the character is in the air.
		if move_left and not move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= AIR_ACCEL * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += AIR_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= AIR_DEACCEL * step

			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv

	# Update siding.
	if move_left > 0.0:
		sprite.scale.x = -1
	elif move_right > 0.0:
		sprite.scale.x = 1

	# Apply floor velocity.
	if found_floor:
		floor_h_velocity = state.get_contact_collider_velocity_at_position(floor_index).x
		lv.x += floor_h_velocity

	# Finally, apply gravity and set back the linear velocity.
	lv += state.get_total_gravity() * step
	state.set_linear_velocity(lv)
