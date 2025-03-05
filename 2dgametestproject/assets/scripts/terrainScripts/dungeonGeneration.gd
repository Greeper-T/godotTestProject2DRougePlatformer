extends Node2D

@onready var tile_map_layer = $TileMapLayer

var floor_tile := Vector2i(1, 1)
var wall_tile_bottom := Vector2i(1, 5)
var wall_tile_top := Vector2i(1, 7)
var player_scene = preload("res://assets/scenes/playerStuff/player.tscn")

const WIDTH = 300
const HEIGHT = 70
const CELL_SIZE = 7

# Separate min and max values for room width and height
const MIN_ROOM_WIDTH = 15
const MAX_ROOM_WIDTH = 25
const MIN_ROOM_HEIGHT = 10
const MAX_ROOM_HEIGHT = 20

const MAX_ROOMS = 7
const MAX_DISTANCE = 20

# Minimum distance between rooms (in grid units)
const MIN_ROOM_SPACING = 10  # Increase this to make rooms farther apart

var grid = []
var rooms = []

func _ready():
	randomize()
	initialize_grid()
	generate_dungeon()
	draw_dungeon()
	spawn_player_in_first_room()

func initialize_grid():
	grid.clear()
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(1)  # 1 = wall, 0 = floor

func generate_dungeon():
	var first_room = Rect2(1, 1, MIN_ROOM_WIDTH, MIN_ROOM_HEIGHT)
	place_room(first_room)
	rooms.append(first_room)

	for i in range(MAX_ROOMS - 1):
		var room = generate_room_near(rooms[-1])
		if place_room(room):
			connect_rooms_horizontally(rooms[-1], room)
			rooms.append(room)

	place_boss_room()

func generate_room_near(base_room: Rect2) -> Rect2:
	# Generate room dimensions with independent width and height ranges
	var width = MIN_ROOM_WIDTH + randi() % (MAX_ROOM_WIDTH - MIN_ROOM_WIDTH + 1)
	var height = MIN_ROOM_HEIGHT + randi() % (MAX_ROOM_HEIGHT - MIN_ROOM_HEIGHT + 1)

	# Horizontal offset (left or right)
	var left = clamp(base_room.position.x - width - (randi() % (MAX_DISTANCE + 1)), 1, WIDTH - width - 1)
	var right = clamp(base_room.end.x + (randi() % (MAX_DISTANCE + 1)), 1, WIDTH - width - 1)

	# Vertical offset (stagger vertically)
	const MAX_VERTICAL_OFFSET = 10
	var vertical_offset = (randi() % (MAX_VERTICAL_OFFSET * 2 + 1)) - MAX_VERTICAL_OFFSET
	var y = clamp(base_room.position.y + vertical_offset, 1, HEIGHT - height - 1)

	# Ensure that rooms are far enough apart (MIN_ROOM_SPACING)
	if abs(left - base_room.end.x) < MIN_ROOM_SPACING and abs(right - base_room.position.x) < MIN_ROOM_SPACING:
		# If the new room is too close to the existing room, try again
		return generate_room_near(base_room)

	var place_left = randi() % 2 == 0  # Randomly choose left or right
	if place_left:
		return Rect2(left, y, width, height)
	else:
		return Rect2(right, y, width, height)

func place_room(room: Rect2) -> bool:
	# Ensure the room doesn't overlap existing rooms
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if grid[x][y] == 0:
				return false
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			grid[x][y] = 0  # Place floor
	return true

func connect_rooms_horizontally(room1: Rect2, room2: Rect2):
	var left_room = room1 if room1.position.x < room2.position.x else room2
	var right_room = room2 if left_room == room1 else room1

	var y = clamp(int(left_room.position.y + left_room.size.y / 2), 1, HEIGHT - 2)
	var start_x = left_room.end.x
	var end_x = right_room.position.x

	for x in range(start_x, end_x + 1):
		carve_corridor(Vector2i(x, y), 3, true)

	var target_y = clamp(int(right_room.position.y + right_room.size.y / 2), 1, HEIGHT - 2)
	while y != target_y:
		y += 1 if target_y > y else -1
		carve_corridor(Vector2i(end_x, y), 3, false)

func carve_corridor(pos: Vector2i, width=3, horizontal=true):
	var half_width = width / 2
	for offset in range(-half_width, half_width + 1):
		if horizontal:
			var ny = pos.y + offset
			if pos.x >= 0 and pos.x < WIDTH and ny >= 0 and ny < HEIGHT:
				grid[pos.x][ny] = 0
		else:
			var nx = pos.x + offset
			if nx >= 0 and nx < WIDTH and pos.y >= 0 and pos.y < HEIGHT:
				grid[nx][pos.y] = 0

func place_boss_room():
	var farthest_distance = 0
	var best_position = Vector2i()

	# Try to place the boss room a limited number of times
	var attempts = 10  # Limit the number of attempts to place the boss room
	for attempt in range(attempts):
		# Find a position far enough away from the starting room and other rooms
		for x in range(1, WIDTH - MAX_ROOM_WIDTH - 1):
			for y in range(1, HEIGHT - MAX_ROOM_HEIGHT - 1):
				var valid_position = true
				for room in rooms:
					# Check if the boss room's proposed position overlaps with any other room
					if room.position.distance_to(Vector2(x, y)) < MIN_ROOM_SPACING:
						valid_position = false
						break
				
				if valid_position:
					var distance = (Vector2(x, y) - rooms[0].position).length()
					if distance > farthest_distance:
						farthest_distance = distance
						best_position = Vector2i(x, y)

		# Place the boss room if a valid position is found
		if best_position != Vector2i():
			var boss_room = Rect2(best_position.x, best_position.y, MAX_ROOM_WIDTH, MAX_ROOM_HEIGHT)

			# Ensure the boss room is placed without overlapping
			if place_room(boss_room):
				connect_rooms_horizontally(rooms[-1], boss_room)
				rooms.append(boss_room)
				print("Boss room placed successfully.")
				return  # Successfully placed the boss room, exit the function

		# If no valid placement is found, retry
		print("Failed to place boss room, retrying...")

	# After 'attempts' retries, if the boss room is still not placed, print a failure message
	print("Failed to place the boss room after several attempts.")

func draw_dungeon():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_position = Vector2(x, y)  # Change Vector2i to Vector2
			if grid[x][y] == 0:
				tile_map_layer.set_cell(tile_position, 0, floor_tile)  # Set tile index for floors
			elif grid[x][y] == 1:
				place_wall(tile_position, x, y)
			else:
				tile_map_layer.set_cell(tile_position, 0, Vector2(-1, -1))  # Invalid tile if no match

func spawn_player_in_first_room():
	if rooms.is_empty():
		push_error("No rooms generated, can't spawn player!")
		return

	var first_room = rooms[0]
	var player = player_scene.instantiate()
	var room_center = first_room.position + first_room.size / 2
	player.global_position = room_center * CELL_SIZE
	add_child(player)

func place_wall(tile_position: Vector2, x: int, y: int):
	if y < HEIGHT - 1 and grid[x][y + 1] == 0:
		tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
	elif y > 0 and grid[x][y - 1] == 0:
		tile_map_layer.set_cell(tile_position, 0, wall_tile_top)
	elif x > 0 and grid[x - 1][y] == 0:
		tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
	elif x < WIDTH - 1 and grid[x + 1][y] == 0:
		tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
	else:
		tile_map_layer.set_cell(tile_position, 0, Vector2(-1, -1))
