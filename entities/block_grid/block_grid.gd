
extends Node2D
class_name Block_Grid

@export var block_scene: PackedScene
var level_01 = preload("res://resources/levels/level_01.tres")

@export var block_padding: int = 4
@export_range(16,64,1) var block_size:int  = 32
@export var width: int = 4
@export var height: int = 4

var grid: Array[Array] = []
var last_hovered: Block = null
var tick_timer := 0.0
var tick_interval := 1.0

var cell_size: int:
	get: return block_size + block_padding

func _ready() -> void:
	init_from_level_data(level_01)

	# Center the block grid
	get_viewport().size_changed.connect(center_grid)
	center_grid()
	
func center_grid() -> void:
	# Use get_visible_rect() for the most accurate "real" screen space
	var screen_size = get_viewport_rect().size
	var grid_size = get_grid_size()
	
	# Calculate the top-left position to place the grid in the middle
	position = (screen_size * 0.5) - (grid_size * 0.5)
	
func _process(delta):
	tick_timer += delta
	if tick_timer < tick_interval:
		return
	tick_timer = 0.0

	var b = get_block_at_mouse()

	if b != last_hovered:
		last_hovered = b

	if last_hovered:
		last_hovered.damage(1)

func init_from_level_data(level:LevelData):
	assert(level.is_valid())
	width = level.width
	height = level.height
	clear_grid()

	for y in height:
		grid.append([])
		for x in width:
			var block = create_block(level, x, y)
			grid[y].append(block)



func create_block(level:LevelData, x: int, y: int) -> Block:
	var block:Block = block_scene.instantiate()
	block.init(x,y, level.get_cell(x,y), self)
	add_child(block)
	block.position = grid_to_world(x, y)
	var scale: float = float(block_size / 32);
	block.scale = Vector2(scale, scale)
	if block.max_health == 0:
		block.visible = false;
	return block


func clear_grid():
	for child in get_children():
		child.queue_free()
	grid.clear()
		
func get_grid_size() -> Vector2:
	return Vector2(width, height) * cell_size

func get_grid_origin() -> Vector2:
	return get_grid_size() * 0.5

func grid_to_world(x: int, y: int) -> Vector2:
	return Vector2(x, y) * cell_size
	
func world_to_grid(pos: Vector2) -> Vector2i:
	var local = pos - global_position
	return Vector2i(
		floor(local.x / cell_size),
		floor(local.y / cell_size)
	)
	
func get_block_at_mouse() -> Block:
	var cell = world_to_grid(get_global_mouse_position())

	if cell.x < 0 or cell.y < 0 or cell.x >= width or cell.y >= height:
		return null

	var block: Block = grid[cell.y][cell.x]

	if block == null:
		return null

	if not block.visible:
		return null

	return block
