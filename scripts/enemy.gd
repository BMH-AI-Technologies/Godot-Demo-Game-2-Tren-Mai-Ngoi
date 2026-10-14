extends CharacterBody2D
@export var speed := 36.0
@export var patrol_radius := 96.0
var origin := Vector2.ZERO
var direction := -1.0
var elapsed := 0.0

func _ready() -> void:
	origin = position
	$Danger.body_entered.connect(_on_body)

func _physics_process(delta: float) -> void:
	elapsed += delta
	$RayMep.position.x = direction * 12
	$RayTuong.target_position.x = direction * 14
	$RayMep.force_raycast_update()
	$RayTuong.force_raycast_update()
	if is_on_floor():
		# Only inspect terrain ahead. is_on_wall() describes the previous move,
		# so using it here can reverse a second time just after turning away.
		var wall_ahead: bool = $RayTuong.is_colliding() and $RayTuong.get_collision_normal().y > -cos(floor_max_angle)
		var at_limit: bool = (direction < 0 and position.x <= origin.x - patrol_radius) or (direction > 0 and position.x >= origin.x + patrol_radius)
		if not $RayMep.is_colliding() or wall_ahead or at_limit:
			direction *= -1
	velocity.x = direction * speed
	velocity.y = minf(620, velocity.y + 1500 * delta)
	move_and_slide()
	$Sprite2D.flip_h = direction < 0
	# Anchor the tutorial blob's bob to its feet.
	var height := 20.0 + sin(elapsed * 6)
	$Sprite2D.scale.y = height / 20.0
	$Sprite2D.position.y = -height / 2.0
	for body in $Danger.get_overlapping_bodies():
		_on_body(body)

func _on_body(body: Node2D) -> void:
	if body.is_in_group("nguoi_choi"):
		body.die()
