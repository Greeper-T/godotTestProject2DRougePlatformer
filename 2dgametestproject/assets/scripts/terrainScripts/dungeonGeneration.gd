extends Node2D

@onready var tile_map_layer = $TileMapLayer

var floor_tile := Vector2i(1, 1)
var wall_tile_bottom := Vector2i(1, 5)
var wall_tile_top := Vector2i(1, 7)
var player_scene = preload("res://assets/scenes/playerStuff/debug_player.tscn")
var one_way_tile = preload("res://assets/scenes/areaFunctions/one_way_platform.tscn")

const WIDTH = 800
const HEIGHT = 120
const CELL_SIZE = 16
const MIN_ROOMS = 5

const MIN_ROOM_WIDTH = 10
const MAX_ROOM_WIDTH = 15
const MIN_ROOM_HEIGHT = 7
const MAX_ROOM_HEIGHT = 12

const MAX_ROOMS = 7
const MAX_DISTANCE = 10
const MIN_ROOM_SPACING = 5

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
			grid[x].append(1) # Wall

func generate_dungeon():
	var first_room = Rect2(1, 1, MIN_ROOM_WIDTH, MIN_ROOM_HEIGHT)
	place_room(first_room)
	rooms.append(first_room)

	while rooms.size() < MIN_ROOMS or rooms.size() < MAX_ROOMS:
		var room = generate_room_near(rooms[-1])
		if place_room(room):
			
			connect_rooms_horizontally(rooms[-1], room)
			rooms.append(room)
			place_one_way_platforms(room)

	place_boss_room()

func generate_room_near(base_room: Rect2) -> Rect2:
	var width = MIN_ROOM_WIDTH + randi() % (MAX_ROOM_WIDTH - MIN_ROOM_WIDTH + 1)
	var height = MIN_ROOM_HEIGHT + randi() % (MAX_ROOM_HEIGHT - MIN_ROOM_HEIGHT + 1)

	var left = clamp(base_room.position.x - width - (randi() % (MAX_DISTANCE + 1)), 1, WIDTH - width - 1)
	var right = clamp(base_room.end.x + (randi() % (MAX_DISTANCE + 1)), 1, WIDTH - width - 1)

	const MAX_VERTICAL_OFFSET = 10
	var vertical_offset = (randi() % (MAX_VERTICAL_OFFSET * 2 + 1)) - MAX_VERTICAL_OFFSET
	var y = clamp(base_room.position.y + vertical_offset, 1, HEIGHT - height - 1)

	if abs(left - base_room.end.x) < MIN_ROOM_SPACING and abs(right - base_room.position.x) < MIN_ROOM_SPACING:
		return generate_room_near(base_room)

	var place_left = randi() % 2 == 0
	if place_left:
		return Rect2(left, y, width, height)
	else:
		return Rect2(right, y, width, height)

func place_room(room: Rect2) -> bool:
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if grid[x][y] == 0:
				return false
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			grid[x][y] = 0
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
	var farthest_room = rooms[0]
	var farthest_distance = 0

	for room in rooms:
		var distance = room.position.distance_to(rooms[0].position)
		if distance > farthest_distance:
			farthest_distance = distance
			farthest_room = room

	var boss_room = Rect2(farthest_room.end.x + MIN_ROOM_SPACING, farthest_room.position.y, MAX_ROOM_WIDTH, MAX_ROOM_HEIGHT)

	if place_room(boss_room):
		connect_rooms_horizontally(farthest_room, boss_room)
		rooms.append(boss_room)

func draw_dungeon():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_position = Vector2(x, y)
			if grid[x][y] == 1:
				# Force walls only if not adjacent to a floor
				if (x > 0 and grid[x - 1][y] == 0) or (x < WIDTH - 1 and grid[x + 1][y] == 0):
					tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
				else:
					place_wall(tile_position, x, y)  # Regular wall logic
			elif grid[x][y] == 0:
				tile_map_layer.set_cell(tile_position, 0, floor_tile)
			else:
				tile_map_layer.set_cell(tile_position, 0, Vector2(-1, -1))


func place_wall(tile_position: Vector2, x: int, y: int):
	if y < HEIGHT - 1 and grid[x][y + 1] == 0:
		tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
	elif y > 0 and grid[x][y - 1] == 0:
		tile_map_layer.set_cell(tile_position, 0, wall_tile_top)

func spawn_player_in_first_room():
	if rooms.is_empty():
		push_error("No rooms generated, can't spawn player!")
		return

	var first_room = rooms[0]
	var player = player_scene.instantiate()
	var room_center = first_room.position + first_room.size / 2
	player.global_position = room_center * CELL_SIZE
	add_child(player)

func place_one_way_platforms(room: Rect2):
	if room == rooms[0]:  
		return  # Skip the first room (player spawn room)

	# Find the center of the room in grid coordinates
	var room_center_x = room.position.x + (room.size.x / 2.0)
	var room_center_y = room.position.y + (room.size.y / 2.0)

	# Convert grid coordinates to world coordinates
	# Factor in TileMapLayer's global position
	var platform_pos = (Vector2(room_center_x, room_center_y) * CELL_SIZE) + tile_map_layer.global_position

	# Instantiate and place the platform at the calculated position
	var platform = one_way_tile.instantiate()
	platform.global_position = platform_pos
	add_child(platform)

	# Debugging Output
	print("========================")
	print("Room position (grid): ", room.position, " size: ", room.size)
	print("Calculated center (grid): ", room_center_x, ",", room_center_y)
	print("TileMap global position: ", tile_map_layer.global_position)
	print("Final platform position (world): ", platform_pos)
	print("========================")
