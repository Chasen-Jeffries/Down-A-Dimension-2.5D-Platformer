extends Node2D

# References
var player
var level_manager

# Game state
var game_timer = 0.0    # Timer for tracking gameplay duration

func _ready():
	# Find player and level manager
	player = get_node("/root/World/Player")
	level_manager = get_node("/root/World/Level_Manager")

	if not player or not level_manager:
		push_error("Player or Level Manager node not found!")

func _process(delta):
	# Update game timer
	game_timer += delta

	# Handle plane switching
	if Input.is_action_just_pressed("turn"):
		_switch_level()

func _switch_level():
	_align_player_to_grid()  # Align player to the grid first
	var next_level = _get_trigger_tile()
	
	if next_level >= 2:  # Level triggers are >= 2
		level_manager._initialize_level(next_level - 2)
		player.update_respawn_point(player.position)
		print("Switched to Level:", next_level - 2)
	else:
		print("No valid trigger tile detected.")

func _get_trigger_tile():
	# Use the player's center position for more accurate grid alignment
	var center_x = player.position.x + (player.scale.x / 2)
	var center_y = player.position.y + (player.scale.y / 2)

	var tile_x = int(center_x / 64)
	var tile_y = int(center_y / 64)
	var current_matrix = level_manager.level_matrices[level_manager.current_level]

	# Check current and neighboring tiles
	var directions = [
		Vector2(0, 0),  # Current tile
		Vector2(1, 0),  # Right tile
		Vector2(-1, 0), # Left tile
		Vector2(0, 1),  # Down tile
		Vector2(0, -1)  # Up tile
	]

	for dir in directions:
		var check_x = tile_x + dir.x
		var check_y = tile_y + dir.y

		if check_y >= 0 and check_y < current_matrix.size():
			if check_x >= 0 and check_x < current_matrix[check_y].size():
				var tile_value = current_matrix[check_y][check_x]
				if tile_value >= 2:  # Trigger tiles
					print("Valid Trigger Tile Found at:", check_x, check_y, "Value:", tile_value)
					return tile_value

	print("No valid trigger tile detected.")
	return 0

func _align_player_to_grid():
	player.position.x = round(player.position.x / 64) * 64
	player.position.y = round(player.position.y / 64) * 64
	print
