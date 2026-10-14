extends Area2D
signal collected
var taken := false
var elapsed := 0.0
func _ready() -> void:
	body_entered.connect(_on_body)
func _process(delta: float) -> void:
	elapsed += delta
	$Sprite2D.scale.x = 0.25 + absf(sin(elapsed * 4 + position.x)) * 0.75
func _on_body(body: Node2D) -> void:
	if taken or not body.is_in_group("nguoi_choi") or body.dead:
		return
	taken = true
	$Sprite2D.hide()
	set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)
	collected.emit()
	$Pickup.play()
	await $Pickup.finished
	queue_free()
