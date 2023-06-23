class_name Player
extends CharacterBody2D

@export var input_left : String = "move_left"
@export var input_right : String = "move_right"
@export var input_jump : String = "jump"
@export var walk_force : float = 600
@export var walk_max_speed : float = 200
@export var stop_force : float = 1300
@export var jump_speed : float = 200

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var gravity_vector = ProjectSettings.get_setting("physics/2d/default_gravity_vector")

# taken from https://github.com/godotengine/godot-demo-projects/blob/3.5-9e68af3/2d/kinematic_character/player/player.gd
func _physics_process(delta):
	var walk = walk_force * (Input.get_action_strength(input_right) - Input.get_action_strength(input_left))
	# Slow down the player if they're not trying to move.
	if abs(walk) < walk_force * 0.2:
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, stop_force * delta)
	else:
		velocity.x += walk * delta
	# Clamp to the maximum horizontal movement speed.
	velocity.x = clamp(velocity.x, -walk_max_speed, walk_max_speed)
	
# 	Vertical movement code. Apply gravity.
	velocity += gravity * gravity_vector * delta
	
	# Move based on the velocity and snap to the ground.
	move_and_slide()

	# Check for jumping. is_on_floor() must be called after movement code.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_speed
