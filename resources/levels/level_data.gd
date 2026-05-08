extends Resource

class_name LevelData

@export_range(4, 16, 1) var width: int = 4
@export_range(4, 16, 1) var height: int = 4

@export var cells: Array[float] = []


func is_valid() -> bool:
	return width > 0 and height > 0 and cells.size() == width * height

func get_cell(x: int, y: int) -> float:
	return cells[y * width + x]
