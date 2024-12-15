extends Node2D

# Platform data
var level_matrix = []  # 3D matrix [Z][Y][X]

# Grid settings
var grid_width = 5
var grid_height = 10
var cell_size = Vector2()

func _ready():
	# Wait for the viewport to initialize
	await get_tree().process_frame  

	_load_level_data("res://level_1.json")

	# Calculate cell size dynamically
	var viewport_size = get_viewport_rect().size
	cell_size.x = viewport_size.x / grid_width
	cell_size.y = viewport_size.y / grid_height
	print("Cell size calculated:", cell_size)

	# Initialize the first plane (Y–X, Z = 0)
	if level_matrix.size() > 0:
		update_visible_platforms("x", 0)
	else:
		push_error("Level matrix is empty. Check your JSON file and path.")



func _load_level_data(json_path):
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.parse_string(content)
		if json and json.has("level_1"):
			level_matrix = json["level_1"]
			print("Level Matrix Loaded: ", level_matrix)  # Debugging output
		else:
			push_error("Invalid or missing 'level_1' key in JSON data.")
		file.close()
	else:
		push_error("Failed to load level data from: " + json_path)

func update_visible_platforms(current_axis, fixed_value):
	# Clear existing platforms
	for child in get_children():
		if child is StaticBody2D:
			remove_child(child)
			child.queue_free()

	print("Updating platforms for axis:", current_axis, " fixed value:", fixed_value)

	# Draw the new slice of platforms
	if current_axis == "x":
		_draw_yx_plane(fixed_value)
	else:
		_draw_yz_plane(fixed_value)

func _draw_yx_plane(z_index):
	print("Drawing Y-X Plane at Z =", z_index)
	for y in range(level_matrix[z_index].size()):
		for x in range(level_matrix[z_index][y].size()):
			if level_matrix[z_index][y][x] == 1:
				print("Creating platform at X:", x, " Y:", y)  # Debug output
				_create_platform(x, y)

func _draw_yz_plane(x_index):
	for z in range(level_matrix.size()):
		for y in range(level_matrix[z].size()):
			if level_matrix[z][y][x_index] == 1:
				_create_platform(z, y)

func _create_platform(x, y):
	var platform = StaticBody2D.new()
	var collision_shape = CollisionShape2D.new()
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.size = Vector2(cell_size.x, cell_size.y / 5)  # Platform size
	collision_shape.shape = rectangle_shape
	platform.add_child(collision_shape)

	# Correctly calculate the platform position
	platform.position = Vector2(
		x * cell_size.x + cell_size.x / 2,  # Horizontal position
		(grid_height - y - 1) * cell_size.y + cell_size.y / 2  # Vertical position
	)
	print("Platform position:", platform.position)  # Debug output

	add_child(platform)

	# Add a visual representation
	var visual = ColorRect.new()
	visual.color = Color(0.3, 0.8, 0.7, 1)  # Teal color
	visual.size = Vector2(cell_size.x, cell_size.y / 5)
	visual.position = Vector2(-cell_size.x / 2, 0)
	platform.add_child(visual)
