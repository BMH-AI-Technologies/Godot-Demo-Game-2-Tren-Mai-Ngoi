@tool
extends Node2D

# Direct port of art.ts drawRain: deterministic seeds, wrap and wind.
@export_range(0, 500) var count := 120
@export var area := Vector2(1104, 200)
@export var wind := 0.35
@export var tint := Color(0.77647, 0.86275, 0.91765, 0.5)
var elapsed := 0.0

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		elapsed += delta
	queue_redraw()

func _draw() -> void:
	for i in range(count):
		var r1 := fmod(abs(sin(i * 12.9898) * 43758.5453), 1.0)
		var r2 := fmod(abs(sin(i * 78.233) * 12345.6789), 1.0)
		var speed := 420.0 + r2 * 260.0
		var drop := Vector2(fposmod(r1 * area.x + elapsed * speed * wind, area.x), fposmod(r2 * area.y + elapsed * speed, area.y))
		var length := 7.0 + r2 * 6.0
		draw_line(drop, drop + Vector2(-length * wind, length), tint, 1.0, true)
