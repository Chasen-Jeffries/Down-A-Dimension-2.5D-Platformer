extends CharacterBody2D

@export var speed = 300
@export var gravity = 30
@export var jump_force = 300

var start_position = Vector2()  # To store the starting position

func _ready():
	# Save the player's starting position when the game begins
	start_position = position

func _physics_process(delta):
	# Apply gravity if the player is not on the floor
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:  # Cap the falling velocity
			velocity.y = 1000

	# Check if the player has fallen below the map
	_check_fall_off_map()

	# Jumping input
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force

	# Horizontal movement
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	velocity.x = speed * horizontal_direction

	move_and_slide()

func _check_fall_off_map():
	# Check if the player's Y position is below a certain threshold
	if position.y > 1000:  # Adjust threshold as needed
		position = start_position  # Reset position to starting point
		velocity = Vector2()       # Reset velocity
