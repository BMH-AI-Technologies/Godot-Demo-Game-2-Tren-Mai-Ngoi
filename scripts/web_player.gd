extends CharacterBody2D
signal died

# Di chuyển: pixel/giây; gia tốc và trọng lực: pixel/giây².
const RUN_SPEED := 165.0
const GRAVITY := 1500.0
const MAX_FALL_SPEED := 620.0

# Nhảy: coyote và buffer tính bằng giây. Bấm nhanh hay giữ đều nhảy cao như nhau.
const JUMP_SPEED := 420.0
const COYOTE_TIME := 0.10
const JUMP_BUFFER := 0.12
const FALL_MULTIPLIER := 1.45
const APEX_THRESHOLD := 60.0
const APEX_GRAVITY_SCALE := 0.55


@onready var initial_collision_mask: int = collision_mask
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var jump_dust: CPUParticles2D = $BuiNhay
@onready var landing_dust: CPUParticles2D = $BuiTiepDat
@onready var trail: Line2D = get_parent().get_node("VetChuyenDong")

var coyote_left := 0.0
var buffer_left := 0.0
var squash_amount := 0.0
var dead := false
# Giữ các bộ đếm để tương thích với kiểm tra của bản hoàn chỉnh.
var jumps := 0
var landings := 0
var falls := 0


func _physics_process(delta: float) -> void:
	if dead:
		velocity.y = minf(MAX_FALL_SPEED, velocity.y + GRAVITY * delta)
		position += velocity * delta
		return
	var grounded := is_on_floor()
	var direction := Input.get_axis("trai", "phai")
	velocity.x = direction * RUN_SPEED

	# Coyote time: vẫn cho nhảy trong một khoảng ngắn sau khi rời mép mái.
	if grounded:
		coyote_left = COYOTE_TIME
	else:
		coyote_left = maxf(0.0, coyote_left - delta)

	# Buffer: nhớ cú bấm sớm để nhảy ngay khi vừa tiếp đất.
	buffer_left = maxf(0.0, buffer_left - delta)
	if Input.is_action_just_pressed("nhay"):
		buffer_left = JUMP_BUFFER

	var launched := false
	if buffer_left > 0.0 and (grounded or coyote_left > 0.0):
		velocity.y = -JUMP_SPEED
		coyote_left = 0.0
		buffer_left = 0.0
		launched = true
		squash_amount = 0.22
		jumps += 1
		jump_dust.restart()
		$JumpSound.play()

	if not grounded or launched:
		var gravity := GRAVITY
		if velocity.y > 0.0:
			gravity *= FALL_MULTIPLIER
		if absf(velocity.y) < APEX_THRESHOLD:
			gravity *= APEX_GRAVITY_SCALE
		velocity.y = minf(velocity.y + gravity * delta, MAX_FALL_SPEED)

	move_and_slide()
	position.x = clampf(position.x, 8, get_parent().map_width - 8)
	if not grounded and is_on_floor():
		landings += 1
		squash_amount = -0.26
		landing_dust.restart()
	_update_visuals(direction, delta)

	if position.y > 270:
		die()


func _update_visuals(direction: float, delta: float) -> void:
	if direction != 0:
		sprite.flip_h = direction < 0
	if not is_on_floor():
		sprite.play("nhay" if velocity.y < 0.0 else "roi")
	elif absf(velocity.x) > 12.0:
		sprite.play("chay")
	else:
		sprite.play("dung")

	# Chỉ co giãn hình ảnh quanh bàn chân; không thay đổi collider.
	squash_amount *= pow(0.86, delta * 60.0)
	var stretch := 1.0 + squash_amount
	sprite.scale = Vector2(1.0 / stretch, stretch)
	sprite.position.y = -12.0 * stretch
	trail.add_point(global_position + Vector2(0, -11))
	if trail.get_point_count() > 90:
		trail.remove_point(0)


func die() -> void:
	if dead:
		return
	dead = true
	falls += 1
	velocity = Vector2(0, -100)
	collision_mask = 0
	jump_dust.emitting = false
	landing_dust.emitting = false
	sprite.play("trung_don")
	$DeathSound.play()
	died.emit()

func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	dead = false
	collision_mask = initial_collision_mask
	coyote_left = 0
	buffer_left = 0
	squash_amount = 0
	sprite.scale = Vector2.ONE
	sprite.position.y = -12
	sprite.play("dung")
	trail.clear_points()
	jump_dust.emitting = false
	landing_dust.emitting = false
	$DeathSound.stop()
	camera.reset_smoothing()
	camera.force_update_scroll()
