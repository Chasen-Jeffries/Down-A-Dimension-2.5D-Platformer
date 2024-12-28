extends Node2D

# Array to hold all level matrices
var level_matrices = []  # List of matrices for each level
var current_level = 0    # Active level (index)
var cell_size = Vector2(64, 64)  # Grid cell size
var current_map = 0    # Active level (maps)

# List of map (level) paths
var level_paths = {
	0: "res://levels/level_0.json",
	1: "res://levels/level_1.json",
	2: "res://levels/level_2.json",
	3: "res://levels/level_3.json",
	4: "res://levels/level_4.json",
	5: "res://levels/level_5.json",
	6: "res://levels/level_6.json",
	7: "res://levels/level_7.json",
	8: "res://levels/level_8.json",
	9: "res://levels/level_9.json",
	10: "res://levels/level_10.json"
}

func _ready():
	_load_level_data(current_map)
	_initialize_level(0)  # Start at Level 0

func _load_level_data(level_index):
	if level_index in level_paths:
		var level_path = level_paths[level_index]
		var file = FileAccess.open(level_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json = JSON.parse_string(content)
			print("Loaded JSON content:", json)  # Debugging
			if json and "levels" in json:
				level_matrices = json["levels"]  # Use "levels" key
				print("Levels loaded successfully:", level_matrices.size(), "levels.")
			else:
				push_error("Invalid JSON structure. 'levels' key not found.")
			file.close()
		else:
			push_error("Failed to load level data.")

func _initialize_level(level_index):
	if level_index >= 0 and level_index < level_matrices.size():
		clear_platforms()
		current_level = level_index
		_draw_level(level_matrices[level_index])
		_clamp_player_position()
		print("Initialized Level:", current_level)
	else:
		push_error("Invalid level index:", level_index)

func _draw_level(matrix):
	print("Drawing level with matrix size:", matrix.size())
	for y in range(matrix.size()):
		for x in range(matrix[y].size()):
			var value = matrix[y][x]
			if value > 0:  # Platform or trigger
				_create_platform(x, y, value)

func clear_platforms():
	for child in get_children():
		child.queue_free()

func _create_platform(x, y, value):
	var platform = StaticBody2D.new()
	var shape = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	rectangle.size = Vector2(cell_size.x, cell_size.y / 4)
	shape.shape = rectangle
	platform.add_child(shape)

	platform.position = Vector2(x * cell_size.x + cell_size.x / 2, y * cell_size.y + cell_size.y / 2)
	add_child(platform)

	var visual = ColorRect.new()
	visual.color = Color(1, 0.8, 0, 1) if value >= 2 else Color(0.3, 0.8, 0.7, 1)
	visual.size = rectangle.size
	visual.position = Vector2(-rectangle.size.x / 2, -rectangle.size.y / 2)
	platform.add_child(visual)

# Clamp player position after initializing level
func _clamp_player_position():
	var player = get_node("/root/World/Player")
	if player:
		var grid_width = level_matrices[current_level][0].size() * cell_size.x
		var grid_height = level_matrices[current_level].size() * cell_size.y
		player.position.x = clamp(player.position.x, cell_size.x / 2, grid_width - cell_size.x / 2)
		player.position.y = clamp(player.position.y, cell_size.y / 2, grid_height - cell_size.y / 2)
		print("Clamped Player Position:", player.position)

func set_current_level(level_index):
	if level_index >= 0 and level_index < level_paths.size():
		current_map = level_index  # Update the current level here
		_load_level_data(current_map)
		_initialize_level(current_map)
	else:
		print("No more levels! Game completed.")
