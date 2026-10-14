extends Area2D
signal activated(spawn_position: Vector2)
var active := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if active or not body.is_in_group("nguoi_choi") or body.dead:
		return
	active = true
	$Flag.color = Color("#4fd39a")
	$Glow.show()
	var tween := create_tween()
	tween.tween_property($Flag, "scale", Vector2(1.3,1.3), 0.15)
	tween.tween_property($Flag, "scale", Vector2.ONE, 0.2)
	activated.emit($Spawn.global_position)
