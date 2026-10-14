extends Node2D
@export var map_width := 2064.0
var score := 0
var total_coins := 0
var restarting := false
var checkpoint := Vector2(36,144)
var checkpoint_active := false
@onready var controls_hint: String = $HUD/Hint.text

func _ready() -> void:
	get_window().title = "Trên Mái Ngói — A/D: chạy · Space: nhảy · R: chơi lại"
	total_coins = $Coins.get_child_count()
	for coin in $Coins.get_children():
		coin.collected.connect(_on_coin)
	$NhanVat.died.connect(_on_player_died)
	checkpoint = $NhanVat.global_position
	$Checkpoint.activated.connect(_on_checkpoint)
	update_score()
	$NhanVat/Camera2D.reset_smoothing()
	$NhanVat/Camera2D.force_update_scroll()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("khoi_dong_lai") and not restarting:
		restart_level.call_deferred()

func _on_coin() -> void:
	score += 1
	update_score()

func update_score() -> void:
	$HUD/Score.text = "XU:  %d" % score
	if score == total_coins and total_coins > 0:
		$HUD/Hint.text = "Đã nhặt đủ xu! R để chơi lại."

func _on_checkpoint(spawn_position: Vector2) -> void:
	checkpoint = spawn_position
	checkpoint_active = true
	$HUD/Hint.text = "Đã lưu điểm hồi sinh! R: chơi lại từ đầu."

func _on_player_died() -> void:
	if restarting:
		return
	restarting = true
	$HUD/Hint.text = "Đang trở lại điểm hồi sinh…" if checkpoint_active else "Đang trở lại mái đầu…"
	await get_tree().create_timer(0.65).timeout
	respawn_player()

func respawn_player() -> void:
	Engine.time_scale = 1.0
	for enemy in $Enemies.get_children():
		enemy.position = enemy.origin
		enemy.velocity = Vector2.ZERO
		enemy.direction = -1.0
	$NhanVat.respawn(checkpoint)
	restarting = false
	$HUD/Hint.text = "Đã lưu điểm hồi sinh! R: chơi lại từ đầu." if checkpoint_active else controls_hint
	update_score()
	# Coins and score stay collected, as in chapter 16.

func restart_level() -> void:
	if restarting:
		return
	restarting = true
	reload_level()

func reload_level() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	var result := get_tree().reload_current_scene()
	if result != OK:
		push_error("Cannot restart level: %s" % result)
