extends Node2D

# Two matrices for two planes
var plane_x_matrix = []  # Plane X's grid data
var plane_z_matrix = []  # Plane Z's grid data

var current_plane = "x"  # Active plane: "x" or "z"
var cell_size = Vector2(64, 64)  # Size of a single grid cell

func _ready():
	_load_level_data("res://level_1.json")
	_initialize_plane("x")  # Start on Plane X

func _load_level_data(json_path):
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.parse_string(content)
		if json:
			plane_x_matrix = json["level_1"][0]
			plane_z_matrix = json["level_1"][1]
			print("Planes loaded successfully.")
		else:
			push_error("Invalid JSON structure.")
		file.close()
	else:
		push_error("Failed to load level data.")

func _initialize_plane(plane):
	clear_platforms()
	current_plane = plane
	if plane == "x":
		_draw_plane(plane_x_matrix)
	else:
		_draw_plane(plane_z_matrix)

func _draw_plane(matrix):
	for y in range(matrix.size()):
		for x in range(matrix[y].size()):
			var value = matrix[y][x]
			if value > 0:  # 1 or 2 (platforms or turn triggers)
				_create_platform(x, y, value)

func clear_platforms():
	for child in get_children():
		child.queue_free()

func _create_platform(x, y, value):
	var platform = StaticBody2D.new()
	var shape = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	rectangle.size = Vector2(cell_size.x, cell_size.y / 4)  # Thin platform
	shape.shape = rectangle
	platform.add_child(shape)

	platform.position = Vector2(x * cell_size.x + cell_size.x / 2, y * cell_size.y + cell_size.y / 2)
	add_child(platform)

	# Visual representation
	var visual = ColorRect.new()
	visual.color = Color(1, 0.8, 0, 1) if value == 2 else Color(0.3, 0.8, 0.7, 1)  # Yellow for "turn triggers"
	visual.size = rectangle.size
	visual.position = Vector2(-rectangle.size.x / 2, -rectangle.size.y / 2)
	platform.add_child(visual)
