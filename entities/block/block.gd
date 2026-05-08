@tool
extends Node2D
class_name Block

@export var shake_strength := 6.0
@export var shake_count := 4
@export var shake_time := 0.02

@onready var bar := $BlockCenter/HealthBar
@onready var tier_label := $BlockCenter/TierLabel
@onready var mat : ShaderMaterial  = bar.material

var base_pos := Vector2.ZERO
var grid_x:int
var grid_y:int

var health: float
var max_health: float

var tier: int

@export var test_damage := false:
	set(value):
		test_damage = value

		if Engine.is_editor_hint():
			if value:
				set_health_percent(randf())
				shake()
				flash()
			else:
				set_health_percent(1.0)


func _ready() -> void:
	mat = bar.material.duplicate()
	bar.material = mat
	tier_label.text = "%d" % tier
	pass

func init(x: int, y: int, max_hp: float, grid: Block_Grid) -> void:
	grid_x = x
	grid_y = y

	health = max_hp
	max_health = max_hp
	tier = 1 + floor(log(max_health));

	position = grid.grid_to_world(x, y)
	base_pos = position


func set_health_percent(v: float):
	mat.set_shader_parameter("visible_percent", v)
	
func damage(amount: float):
	if not mat: return
	health -= amount
	if health <= 0.0:
		health = 0
		
	var percent_hp = health / max_health
	set_health_percent(percent_hp)

	# shake
	shake()
	flash()

	if health <= 0:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.15)
		await tween.finished
		self.visible = false
		await get_tree().create_timer(0.15).timeout
		self.visible = false


func shake():
	if Engine.is_editor_hint():
		base_pos = position

	var tween = create_tween()

	for i in shake_count:
		tween.tween_property(
			self,
			"position",
			base_pos + Vector2(
				randf_range(-shake_strength, shake_strength),
				randf_range(-shake_strength, shake_strength)
			),
			shake_time
		)

	tween.tween_property(
		self,
		"position",
		base_pos,
		shake_time
	)
	
func flash():
	modulate = Color(1, 1, 1)

	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 1, 1), 0.0)
	t.tween_property(self, "modulate", Color(1.2,1.2,1.2), 0.05)
	t.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.05)
