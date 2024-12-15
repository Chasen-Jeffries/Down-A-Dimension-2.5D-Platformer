extends Node2D

# Platform positions for the current level
var platform_cells = [
	Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 3), 
	Vector2i(4, 4), Vector2i(5, 5), Vector2i(3, 5), Vector2i(2, 6), 
	Vector2i(1, 7), Vector2i(0, 8), Vector2i(1, 9)
]

var grid_width = 5
var grid_height = 10
var cell_size = Vector2()

func _ready():
	_initialize_platforms()

func _initialize_platforms():
	# Calculate cell size based on viewport
	var viewport_size = get_viewport_rect().size
	cell_size.x = viewport_size.x / grid_width
	cell_size.y = viewport_size.y / grid_height

	# Height for the interactable platforms (1/5 of cell size)
	var platform_height = cell_size.y / 5

	# Create a StaticBody2D for each platform cell
	for cell in platform_cells:
		var platform = StaticBody2D.new()
		var collision_shape = CollisionShape2D.new()
		var rectangle_shape = RectangleShape2D.new()
		
		# Set the size of the platform (width = full cell, height = 1/5th of cell)
		rectangle_shape.size = Vector2(cell_size.x, platform_height)
		collision_shape.shape = rectangle_shape

		# Position the platform at the bottom 1/5th of the cell
		platform.position = Vector2(
			cell.x * cell_size.x + cell_size.x / 2,               # Center X
			(grid_height - cell.y - 1) * cell_size.y + cell_size.y - platform_height / 2  # Bottom 1/5 of the cell
		)
		
		# Add collision shape to platform
		platform.add_child(collision_shape)
		add_child(platform)

		# Optional: Add a visual representation (e.g., a color rectangle)
		var visual = ColorRect.new()
		visual.color = Color(0.5, 0.25, 0)  # Brown color
		visual.size = Vector2(cell_size.x, platform_height)
		visual.position = Vector2(-cell_size.x / 2, -platform_height / 2)  # Align center
		platform.add_child(visual)
