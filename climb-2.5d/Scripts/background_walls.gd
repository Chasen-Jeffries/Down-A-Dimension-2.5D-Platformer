extends Node2D

var grid_width = 5
var grid_height = 10
var cell_size = Vector2()

func _ready():
	_calculate_cell_size()
	_create_edge_walls()

func _calculate_cell_size():
	# Calculate dynamic cell size based on viewport
	var viewport_size = get_viewport_rect().size
	cell_size.x = viewport_size.x / grid_width
	cell_size.y = viewport_size.y / grid_height

func _create_edge_walls():
	var wall_thickness = 10  # Thickness of the walls

	# Left Wall
	var left_wall = StaticBody2D.new()
	var left_collision = CollisionShape2D.new()
	var left_shape = RectangleShape2D.new()
	left_shape.size = Vector2(wall_thickness, grid_height * cell_size.y)  # Full height
	left_collision.shape = left_shape
	left_wall.position = Vector2(-wall_thickness / 2, grid_height * cell_size.y / 2)
	left_wall.add_child(left_collision)
	add_child(left_wall)

	# Right Wall
	var right_wall = StaticBody2D.new()
	var right_collision = CollisionShape2D.new()
	var right_shape = RectangleShape2D.new()
	right_shape.size = Vector2(wall_thickness, grid_height * cell_size.y)  # Full height
	right_collision.shape = right_shape
	right_wall.position = Vector2(grid_width * cell_size.x + wall_thickness / 2, grid_height * cell_size.y / 2)
	right_wall.add_child(right_collision)
	add_child(right_wall)
