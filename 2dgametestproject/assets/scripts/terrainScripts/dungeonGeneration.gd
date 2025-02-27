extends Node2D
@onready var tile_map_layer = $TileMapLayer
 
var floor_tile := Vector2i(1,1)
var wall_tile_bottom := Vector2i(1,5)
var wall_tile_top := Vector2i(1,7)
 

const WIDTH = 150
const HEIGHT = 30
const CELL_SIZE = 10
const MIN_ROOM_SIZE = 10
const MAX_ROOM_SIZE = 10
const MAX_ROOMS = 15
var firstRoom = true
 
var grid = []
var rooms = []
 

func _ready():
	randomize()
	initialize_grid()
	generate_dungeon()
	draw_dungeon()
 
func initialize_grid():
	for x in range(WIDTH):
		grid.append([])  
		for y in range(HEIGHT):
			grid[x].append(1) 
 
func generate_dungeon():
	for i in range(MAX_ROOMS):
		var room = generate_room()
		if place_room(room):
			if rooms.size() > 0:
				connect_rooms(rooms[-1], room)
			rooms.append(room)
 
# Generates a room with random width, height, and position within the grid
func generate_room():
	if firstRoom == true:
		if randi_range(0,1) == 0:
			var width =MIN_ROOM_SIZE
			var height = MIN_ROOM_SIZE
			var x = 1
			var y = randi() % (HEIGHT - height - 1) + 1
			return Rect2(x, y, width, height)
			firstRoom = false
	else:
		var width = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
		var height = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
		var x = WIDTH - width
		var y = randi() % (HEIGHT - height - 1) + 1
		return Rect2(x, y, width, height)
 
# Attempts to place the room on the grid, ensuring no overlap with existing rooms
func place_room(room):
	# Check if the room overlaps with any existing floors (cells set to 0)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if grid[x][y] == 0:  # If the cell is already a floor
				return false  # Room cannot be placed, return false
	
	# If no overlap is found, mark the room area as floors (set cells to 0)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			grid[x][y] = 0  # 0 represents a floor
	return true  # Room successfully placed, return true
 
# Connects two rooms with a corridor, allowing for a customizable corridor width
func connect_rooms(room1, room2, corridor_width=1):
	# Determine the starting point for the corridor (center of room1)
	var start = Vector2(
		int(room1.position.x + room1.size.x / 2),
		int(room1.position.y + room1.size.y / 2)
	)
	# Determine the ending point for the corridor (center of room2)
	var end = Vector2(
		int(room2.position.x + room2.size.x / 2),
		int(room2.position.y + room2.size.y / 2)
	)
	
	var current = start
	
	# First, move horizontally towards the end point
	while current.x != end.x:
		# Move one step left or right
		current.x += 1 if end.x > current.x else -1
		# Create a corridor with the specified width
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				# Ensure we don't go out of grid bounds
				if current.y + j >= 0 and current.y + j < HEIGHT and current.x + i >= 0 and current.x + i < WIDTH:
					grid[current.x + i][current.y + j] = 0  # Set cells to floor
 
	# Then, move vertically towards the end point
	while current.y != end.y:
		# Move one step up or down
		current.y += 1 if end.y > current.y else -1
		# Create a corridor with the specified width
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				# Ensure we don't go out of grid bounds
				if current.x + i >= 0 and current.x + i < WIDTH and current.y + j >= 0 and current.y + j < HEIGHT:
					grid[current.x + i][current.y + j] = 0  # Set cells to floor
 
# Draws the dungeon on the screen by creating visual representations of the grid
func draw_dungeon():
	# Loop through each cell in the grid
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_position = Vector2i(x, y)
			if grid[x][y] == 0:
				tile_map_layer.set_cell(tile_position,0,floor_tile)
			elif grid[x][y] == 1:
				if y < HEIGHT - 1 and grid[x][y + 1] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
				elif y > 0 and grid[x][y - 1] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_top)
				elif x > 0 and grid[x - 1][y] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
				elif x < WIDTH - 1 and grid[x+1][y] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
				else:
					tile_map_layer.set_cell(tile_position, 0, Vector2i(-1, -1))
			else:
				tile_map_layer.set_cell(tile_position, 0, Vector2i(-1, -1))
