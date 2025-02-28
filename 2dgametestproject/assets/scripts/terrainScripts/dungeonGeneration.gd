extends Node2D

@onready var tile_map_layer = $TileMapLayer

var floor_tile := Vector2i(1, 1)
var wall_tile_bottom := Vector2i(1, 5)
var wall_tile_top := Vector2i(1, 7)
var player_scene = preload("res://assets/scenes/playerStuff/player.tscn")

const WIDTH = 150
const HEIGHT = 30
const CELL_SIZE = 10
const MIN_ROOM_SIZE = 10
const MAX_ROOM_SIZE = 10
const MAX_ROOMS = 15

var grid = []
var rooms = []

func _ready():
	randomize()
	initialize_grid()
	generate_dungeon()
	draw_dungeon()
	spawn_player_in_first_room()

func initialize_grid():
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(1)  # 1 = wall, 0 = floor

func generate_dungeon():
	# Manually create the first room in the top-left corner
	var first_room = Rect2(1, 1, MIN_ROOM_SIZE, MIN_ROOM_SIZE)
	place_room(first_room)
	rooms.append(first_room)

	# Generate the rest of the rooms
	for i in range(MAX_ROOMS - 1):
		var room = generate_room()
		if place_room(room):
			connect_rooms(rooms[-1], room)
			rooms.append(room)

	# Place the boss room as far as possible from the first room
	place_boss_room()

func generate_room():
	var width = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	var height = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	var x = randi() % (WIDTH - width - 1) + 1
	var y = randi() % (HEIGHT - height - 1) + 1
	return Rect2(x, y, width, height)

func place_room(room: Rect2):
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if grid[x][y] == 0:
				return false  # Room overlaps
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			grid[x][y] = 0  # Place floor
	return true

func connect_rooms(room1: Rect2, room2: Rect2, corridor_width=1):
	var start = Vector2i(
		int(room1.position.x + room1.size.x / 2),
		int(room1.position.y + room1.size.y / 2)
	)
	var end = Vector2i(
		int(room2.position.x + room2.size.x / 2),
		int(room2.position.y + room2.size.y / 2)
	)

	var current = start

	while current.x != end.x:
		current.x += 1 if end.x > current.x else -1
		carve_corridor(current, corridor_width)

	while current.y != end.y:
		current.y += 1 if end.y > current.y else -1
		carve_corridor(current, corridor_width)

func carve_corridor(pos: Vector2i, width=1):
	for i in range(-width / 2, width / 2 + 1):
		for j in range(-width / 2, width / 2 + 1):
			var nx = pos.x + i
			var ny = pos.y + j
			if nx >= 0 and nx < WIDTH and ny >= 0 and ny < HEIGHT:
				grid[nx][ny] = 0  # Carve floor

func place_boss_room():
	var first_room = rooms[0]
	var farthest_distance = 0
	var best_position = Vector2i()

	for x in range(1, WIDTH - MAX_ROOM_SIZE - 1):
		for y in range(1, HEIGHT - MAX_ROOM_SIZE - 1):
			var distance = Vector2(x, y).distance_to(first_room.position)
			if distance > farthest_distance:
				farthest_distance = distance
				best_position = Vector2i(x, y)

	var boss_room = Rect2(best_position.x, best_position.y, MAX_ROOM_SIZE, MAX_ROOM_SIZE)

	if place_room(boss_room):
		connect_rooms(rooms[-1], boss_room)
		rooms.append(boss_room)

func draw_dungeon():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_position = Vector2i(x, y)
			if grid[x][y] == 0:
				tile_map_layer.set_cell(tile_position, 0, floor_tile)
			elif grid[x][y] == 1:
				place_wall(tile_position, x, y)
			else:
				tile_map_layer.set_cell(tile_position, 0, Vector2i(-1, -1))
  # Change to your actual player scene path

func spawn_player_in_first_room():
	if rooms.size() == 0:
		push_error("No rooms generated, can't spawn player!")
		return
	
		var first_room = rooms[0]
		var player = player_scene.instantiate()
	
	# Position player in the center of the first room
		var room_center = first_room.position + first_room.size / 2
		player.global_position = room_center * CELL_SIZE  # Scale to match TileMap grid

		add_child(player)  # Add player to the scene
		get_viewport().get_camera_2d().global_position = player.global_position


func place_wall(tile_position: Vector2i, x: int, y: int):
	if y < HEIGHT - 1 and grid[x][y + 1] == 0:
		tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
	elif y > 0 and grid[x][y - 1] == 0:
		tile_map_layer.set_cell(tile_position, 0, wall_tile_top)
	elif x > 0 and grid[x - 1][y] == 0:
		tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
	elif x < WIDTH - 1 and grid[x + 1][y] == 0:
		tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
	else:
		tile_map_layer.set_cell(tile_position, 0, Vector2i(-1, -1))
