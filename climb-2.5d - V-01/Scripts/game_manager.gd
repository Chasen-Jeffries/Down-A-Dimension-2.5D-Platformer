extends Node2D

# Variables
var player               # Reference to the player node
var game_timer = 0.0     # Track elapsed time
var game_completed = false  # Prevent multiple victory triggers
var input_enabled = false  # Flag to enable input after 1 second
var gameplay_disabled = false  # Flag to disable gameplay after victory

func _ready():
	# Find the player node
	player = get_node("../Player")  # Adjust path if needed

func _process(delta):
	if gameplay_disabled:
		if input_enabled and Input.is_action_just_pressed("move_left"):  # A key
			get_tree().reload_current_scene()  # Restart the current scene
		return  # Stop updating game logic
	
	# Update game timer
	game_timer += delta

	# Check if the player has reached the victory condition
	_check_victory()

func _check_victory():
	# Detect if player moves above the top of the screen
	if player.position.y < -50:
		game_completed = true
		gameplay_disabled = true
		_show_victory_screen()

func _show_victory_screen():
	# Get viewport size for dynamic positioning
	var viewport_size = get_viewport_rect().size

	# Create a container for the victory message
	var victory_container = ColorRect.new()
	victory_container.color = Color(1.0, 0.97, 0.88, 1)  # Creme color
	victory_container.size = Vector2(viewport_size.x * 0.8, viewport_size.y * 0.3)  # 80% width, 30% height
	victory_container.position = (viewport_size - victory_container.size) / 2  # Center the container
	add_child(victory_container)

	# Add a VBoxContainer to center text vertically and horizontally
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.anchor_top = 0.0
	vbox.anchor_bottom = 1.0
	vbox.anchor_left = 0.0
	vbox.anchor_right = 1.0
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER  # Center content inside the VBox
	victory_container.add_child(vbox)

	# Add the "Victory!" label
	var victory_label = Label.new()
	victory_label.text = "Victory!"
	victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_label.set("theme_override_font_sizes/font_size", 48)  # Large font for Victory
	victory_label.set("theme_override_colors/font_color", Color(0, 0, 0, 1))  # Set text color to black
	victory_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(victory_label)

	# Add a label for the time
	var time_label = Label.new()
	time_label.text = "Time: %.2f s" % game_timer  # Use 's' for seconds
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.set("theme_override_font_sizes/font_size", 24)  # Smaller font size
	time_label.set("theme_override_colors/font_color", Color(0, 0, 0, 1))  # Set text color to black
	time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(time_label)

# Add the "next_level!" label
	var next_level = Label.new()
	next_level.text = "Next level: [D]"
	next_level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	next_level.set("theme_override_font_sizes/font_size", 20)  # Large font for Victory
	next_level.set("theme_override_colors/font_color", Color(0, 0, 0, 1))  # Set text color to black
	next_level.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(next_level)
	
	
# Add the "Try Again!" label
	var try_again = Label.new()
	try_again.text = "Try Again: [A]"
	try_again.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	try_again.set("theme_override_font_sizes/font_size", 20)  # Large font for Victory
	try_again.set("theme_override_colors/font_color", Color(0, 0, 0, 1))  # Set text color to black
	try_again.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(try_again)
	
	# Enable input after 1 second
	await get_tree().create_timer(1.0).timeout
	input_enabled = true
