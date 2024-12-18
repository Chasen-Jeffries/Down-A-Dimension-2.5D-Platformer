extends Node2D

# References
var player
var level_manager

# Game state
var current_axis = "x"  # Active plane: "x" or "z"
var game_timer = 0.0    # Timer for tracking gameplay duration
var game_completed = false
var gameplay_disabled = false
var input_enabled = false

func _ready():
	# Find player and level manager
	player = get_node("/root/World/Player")
	level_manager = get_node("/root/World/Level_Manager")

	if not player or not level_manager:
		push_error("Player or Level Manager node not found!")

func _process(delta):
	if gameplay_disabled:
		if input_enabled and Input.is_action_just_pressed("move_left"):  # Restart scene
			get_tree().reload_current_scene()
		return  # Stop updating game logic

	# Update game timer
	game_timer += delta

	# Check for plane switching input
	if Input.is_action_just_pressed("turn"):
		_switch_plane()

	# Check victory condition
	_check_victory()

func _switch_plane():
	if _can_flip():
		if current_axis == "x":
			current_axis = "z"
			level_manager._initialize_plane("z")
		else:
			current_axis = "x"
			level_manager._initialize_plane("x")

		_align_player_to_plane()
		
		# Update respawn point after switching planes
		player.update_respawn_point(player.position)
		
		print("Switched to plane:", current_axis)


func _can_flip():
	# Check if the player is on a '2' tile
	var tile_x = int(player.position.x / 64)
	var tile_y = int(player.position.y / 64)
	var current_plane_matrix = level_manager.plane_x_matrix if current_axis == "x" else level_manager.plane_z_matrix

	if tile_y >= 0 and tile_y < current_plane_matrix.size():
		if tile_x >= 0 and tile_x < current_plane_matrix[tile_y].size():
			return current_plane_matrix[tile_y][tile_x] == 2
	return false

func _align_player_to_plane():
	# Snap the player to the grid on the new plane
	player.position.x = round(player.position.x / 64) * 64
	player.position.y = round(player.position.y / 64) * 64

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
