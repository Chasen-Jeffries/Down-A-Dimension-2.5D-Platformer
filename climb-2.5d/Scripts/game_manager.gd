extends Node2D

# Variables
var player                    # Reference to the player node
var level_manager             # Reference to the Level Manager
var current_axis = "x"        # Active axis (x for X-Y plane, z for Y-Z plane)
var fixed_value = 0           # Fixed value for the current axis
var game_timer = 0.0          # Track elapsed time
var game_completed = false    # Prevent multiple victory triggers
var input_enabled = false     # Flag to enable input after 1 second
var gameplay_disabled = false # Flag to disable gameplay after victory

func _ready():
	# Find the player and level manager nodes
	player = get_node("/root/World/Player")
	level_manager = get_node("/root/World/Level_Manager")
	
	if not player:
		push_error("Player node not found!")
	if not level_manager:
		push_error("Level_Manager node not found!")
	else:
		print("GameManager: Level Manager found.")
		
		# Check if level_matrix is loaded
		if level_manager.level_matrix.size() > 0:
			level_manager.update_visible_platforms("x", 0)  # Start on X-Y plane
		else:
			push_error("LevelManager's level_matrix is empty.")


func _process(delta):
	if gameplay_disabled:
		if input_enabled and Input.is_action_just_pressed("move_left"):  # A key
			get_tree().reload_current_scene()  # Restart the current scene
		return  # Stop updating game logic
	
	# Update game timer
	game_timer += delta

	# Check for plane switching input
	if Input.is_action_just_pressed("turn"):
		_switch_plane()

	# Check if the player has reached the victory condition
	_check_victory()

func _switch_plane():
	# Toggle the axis
	if current_axis == "x":
		current_axis = "z"
		fixed_value = player.position.x / level_manager.cell_size.x  # Lock current X
		player.simulated_z = fixed_value  # Update simulated Z
	else:
		current_axis = "x"
		fixed_value = player.simulated_z  # Use the simulated Z value
		print("Switching back to X-Y plane at simulated Z:", player.simulated_z)

	fixed_value = int(fixed_value)  # Round to nearest grid cell
	print("Switching to axis:", current_axis, "at fixed value:", fixed_value)

	# Update visible platforms
	level_manager.update_visible_platforms(current_axis, fixed_value)


func _check_victory():
	# Detect if player moves above the top of the screen
	if player.position.y < -50 and not game_completed:
		game_completed = true
		gameplay_disabled = true
		_show_victory_screen()

func _show_victory_screen():
	# Get viewport size for dynamic positioning
	var viewport_size = get_viewport_rect().size

	# Create a container for the victory message
	var victory_container = ColorRect.new()
	victory_container.color = Color(1.0, 0.97, 0.88, 1)  # Creme color
	victory_container.size = Vector2(viewport_size.x * 0.8, viewport_size.y * 0.3)
	victory_container.position = (viewport_size - victory_container.size) / 2
	add_child(victory_container)

	# Add a VBoxContainer to center text
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	victory_container.add_child(vbox)

	# "Victory!" Label
	var victory_label = Label.new()
	victory_label.text = "Victory!"
	victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_label.set("theme_override_font_sizes/font_size", 48)
	victory_label.set("theme_override_colors/font_color", Color(0, 0, 0, 1))
	vbox.add_child(victory_label)

	# Time Label
	var time_label = Label.new()
	time_label.text = "Time: %.2f s" % game_timer
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.set("theme_override_font_sizes/font_size", 24)
	time_label.set("theme_override_colors/font_color", Color(0, 0, 0, 1))
	vbox.add_child(time_label)

	# "Next Level" Label
	var next_level = Label.new()
	next_level.text = "Next level: [D]"
	next_level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	next_level.set("theme_override_font_sizes/font_size", 20)
	next_level.set("theme_override_colors/font_color", Color(0, 0, 0, 1))
	vbox.add_child(next_level)

	# "Try Again" Label
	var try_again = Label.new()
	try_again.text = "Try Again: [A]"
	try_again.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	try_again.set("theme_override_font_sizes/font_size", 20)
	try_again.set("theme_override_colors/font_color", Color(0, 0, 0, 1))
	vbox.add_child(try_again)

	# Enable input after 1 second
	await get_tree().create_timer(1.0).timeout
	input_enabled = true
