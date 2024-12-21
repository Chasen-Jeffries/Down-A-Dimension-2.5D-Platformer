extends Node2D

# References
var player
var level_manager
var start_menu  # Store the start menu for later use

# Game state
var game_timer = 0.0    # Timer for tracking gameplay duration
var input_enabled = false
var game_completed = false
var gameplay_disabled = false
var pre_turn_level = 0  # Store the level before the turn
var started_game = false

var start_screen = true
var victory_screen = false

func _ready():
	# Find player and level manager
	player = get_node("/root/World/Player")
	level_manager = get_node("/root/World/Level_Manager")

	if not player or not level_manager:
		push_error("Player or Level Manager node not found!")
		
	_check_start()
	
func _process(delta):
	if start_screen:
		_handle_start_input()
		return  # Skip gameplay logic until start menu is dismissed
	
	if gameplay_disabled:
		_handle_victory_input()
		return  # Stop gameplay updates when game is completed

	# Update game timer
	game_timer += delta

	# Check for level switching
	if Input.is_action_just_pressed("turn"):
		var trigger_tile = _get_trigger_tile()  # Check if the player is on a valid trigger tile
		if _is_player_stationary() and _get_trigger_tile() >= 2:
			pre_turn_level = level_manager.current_level  # Store current level before turning
			_switch_level()
			_teleport_on_turn(pre_turn_level)  # Handle teleportation

	# Check victory condition
	_check_victory()

func _check_start():
	if not started_game:
		_show_start_menu()
		started_game = true
		
func _show_start_menu():
	var viewport_size = get_viewport_rect().size

	# Create start menu container
	var start_container = ColorRect.new()
	start_container.name = "StartMenu"
	start_container.color = Color(0, 0, 0, 0.7)  # Semi-transparent black
	start_container.size = viewport_size
	start_container.position = Vector2(0, 0)
	add_child(start_container)

	# Centered text container
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	start_container.add_child(vbox)
	
	# Title label
	var title_label = Label.new()
	title_label.text = "Welcome!"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.set("theme_override_font_sizes/font_size", 36)  # Smaller font size
	title_label.set("theme_override_colors/font_color", Color(1, 1, 1, 1))
	vbox.add_child(title_label)

	# Subtitle label
	var subtitle_label = Label.new()
	subtitle_label.text = "Press Any Button to Begin"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.set("theme_override_font_sizes/font_size", 18)  # Smaller font size
	subtitle_label.set("theme_override_colors/font_color", Color(1, 1, 1, 1))
	vbox.add_child(subtitle_label)


func _handle_start_input():
	if start_screen and Input.is_anything_pressed():
		_start_game()

func _start_game():
	# Remove start menu
	var start_container = get_node_or_null("StartMenu")
	if start_container:
		start_container.queue_free()
	start_screen = false


func _is_player_stationary() -> bool:
	# Replace this with the actual logic to determine if the player is stationary
	if abs(player.velocity.x) < 0.01 and abs(player.velocity.y) < 0.01:
		return true  # Player is stationary
	return false

func _teleport_on_turn(level_before_turn):
	var target_x = 0  # Default value in case no match is found

	# Determine target X based on the level before the turn
	if level_before_turn == 0 or level_before_turn == 5:
		target_x = 28  # Teleport to X1
	elif level_before_turn == 1 or level_before_turn == 6:
		target_x = 86  # Teleport to X2
	elif level_before_turn == 2 or level_before_turn == 7:
		target_x = 144  # Teleport to X3
	elif level_before_turn == 3 or level_before_turn == 8:
		target_x = 201  # Teleport to X4
	elif level_before_turn == 4 or level_before_turn == 9:
		target_x = 259  # Teleport to X5

	# Debugging: Print the level and target X position
	print("Level before turn:", level_before_turn, " -> Teleporting to X:", target_x)

	# Perform teleport if target_x is valid
	if target_x > 0:
		_change_player_x(target_x)
		player.update_respawn_point(Vector2(target_x, player.position.y))  # Update respawn point



func _change_player_x(new_x: float):
	if player:
		# Debugging: Print the player's old and new positions
		print("Changing player position from X:", player.position.x, " to X:", new_x)
		player.position.x = new_x
		

func _switch_level():
	_align_player_to_grid()
	var next_level = _get_trigger_tile()
	
	if next_level >= 2:
		var target_level = level_manager.current_level - 1 if level_manager.current_level + 2 == next_level else next_level - 2
		level_manager._initialize_level(target_level)
		player.update_respawn_point(player.position)
		print("Switched to Level:", target_level)
	else:
		print("No valid trigger tile detected.")

func _get_trigger_tile():
	var center_x = player.position.x + (player.scale.x / 2)
	var center_y = player.position.y + (player.scale.y / 2)

	var tile_x = int(center_x / 64)
	var tile_y = int(center_y / 64)
	var current_matrix = level_manager.level_matrices[level_manager.current_level]

			
	var directions = [Vector2(0, 0), Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	for dir in directions:
		var check_x = tile_x + dir.x
		var check_y = tile_y + dir.y

		if check_y >= 0 and check_y < current_matrix.size():
			if check_x >= 0 and check_x < current_matrix[check_y].size():
				var tile_value = current_matrix[check_y][check_x]
				if tile_value >= 2:
					return tile_value
					
	# Out of bounds or no valid tile
	print("Player is out of bounds or no valid tile found.")
	
	return 0

func _align_player_to_grid():
	player.position.x = round(player.position.x / 64) * 64
	player.position.y = round(player.position.y / 64) * 64

func _check_victory():
	# Detect if player moves above the top of the screen
	if player.position.y < -50 and not game_completed:
		game_completed = true
		gameplay_disabled = true
		_show_victory_screen()

func _show_victory_screen():
	var viewport_size = get_viewport_rect().size
	var victory_screen = true

	# Victory container
	var victory_container = ColorRect.new()
	victory_container.name = "VictoryContainer"  # To clean up later
	victory_container.color = Color(1.0, 0.97, 0.88, 1)  # Creme color
	victory_container.size = Vector2(viewport_size.x * 0.8, viewport_size.y * 0.3)
	victory_container.position = (viewport_size - victory_container.size) / 2
	add_child(victory_container)

	# VBoxContainer for centered text
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	victory_container.add_child(vbox)

	# Victory label
	var victory_label = Label.new()
	victory_label.text = "Victory!"
	victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_label.set("theme_override_font_sizes/font_size", 48)
	victory_label.set("theme_override_colors/font_color", Color(0, 0, 0, 1))
	vbox.add_child(victory_label)

	# Time label
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
	
	# Restart prompt
	var try_again_label = Label.new()
	try_again_label.text = "Try Again: [A]"
	try_again_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	try_again_label.set("theme_override_font_sizes/font_size", 20)
	try_again_label.set("theme_override_colors/font_color", Color(0, 0, 0, 1))
	vbox.add_child(try_again_label)

	# Delay enabling input for 1 second
	await get_tree().create_timer(1.0).timeout
	input_enabled = true

func _handle_victory_input():
	if input_enabled and Input.is_action_just_pressed("move_left"):  # "A" to restart
		_restart_game()

func _restart_game():
	print("Restarting game...")
	
	# Reset game state
	game_timer = 0.0
	game_completed = false
	gameplay_disabled = false
	input_enabled = false
	victory_screen = false
	
	# Clear victory screen
	var victory_container = get_node_or_null("VictoryContainer")
	if victory_container:
		victory_container.queue_free()

	# Reset level and player
	level_manager._initialize_level(0)  # Restart at Level 0
	player.position = player.start_position  # Move player to initial position
	player.update_respawn_point(player.start_position)
	print("Game restarted.")
