extends Control

# Grid settings
var grid_width = 5            # Number of columns
var grid_height = 10          # Number of rows
var line_thickness = 2        # Thickness of grid lines
var cell_size = Vector2()     # Will be calculated dynamically

func _ready():
	_initialize_grid()
	_add_edge_walls()

func _initialize_grid():
	queue_redraw()

func _draw():
	# Colors
	var line_color = Color(1, 1, 1)  # White grid lines
	var blank_color = Color(0, 0, 0, 0)  # Transparent background
	
	# Calculate cell size dynamically
	var viewport_size = get_viewport_rect().size
	cell_size.x = viewport_size.x / grid_width
	cell_size.y = viewport_size.y / grid_height
	
	# Draw grid cells (transparent)
	for y in range(grid_height):
		for x in range(grid_width):
			var top_left = Vector2(x * cell_size.x, (grid_height - y - 1) * cell_size.y)  # Flip Y-axis
			draw_rect(Rect2(top_left, cell_size), blank_color, true)
	
	# Draw grid lines
	for x in range(grid_width + 1):
		var x_pos = x * cell_size.x
		draw_line(Vector2(x_pos, 0), Vector2(x_pos, grid_height * cell_size.y), line_color, line_thickness)
	for y in range(grid_height + 1):
		var y_pos = y * cell_size.y
		draw_line(Vector2(0, y_pos), Vector2(grid_width * cell_size.x, y_pos), line_color, line_thickness)

func _add_edge_walls():
	# Left Wall
	var left_wall = StaticBody2D.new()
	var left_collision = CollisionShape2D.new()
	var left_shape = RectangleShape2D.new()
	left_shape.size = Vector2(10, grid_height * cell_size.y)  # Thin wall, full map height
	left_collision.shape = left_shape
	left_wall.position = Vector2(-5, grid_height * cell_size.y / 2)  # Slightly off the left edge
	left_wall.add_child(left_collision)
	add_child(left_wall)

	# Right Wall
	var right_wall = StaticBody2D.new()
	var right_collision = CollisionShape2D.new()
	var right_shape = RectangleShape2D.new()
	right_shape.size = Vector2(10, grid_height * cell_size.y)  # Thin wall, full map height
	right_collision.shape = right_shape
	right_wall.position = Vector2(grid_width * cell_size.x + 5, grid_height * cell_size.y / 2)  # Slightly off the right edge
	right_wall.add_child(right_collision)
	add_child(right_wall)
