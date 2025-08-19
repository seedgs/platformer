extends Area2D

# --- 蠕虫属性 ---
@export var speed: float = 30
@export var switch_interval : float = 2.0 # 巡逻的折返时间
@export var health : int = 3
@export var turn_pause_time : float = 0.2      # 掉头停顿时间
@export var turn_lock_distance : float = 1.0  # 掉头后必须移动的距离
@export var turn_tween_time : float = 0.2      # 平滑翻转时间

# 这里会影响悬崖检测效果，当左右悬崖距离过小，这个时间需要相应缩小
@export var min_move_after_turn : float = 2  # 掉头后至少移动时间

var move_direction : int = 1 # 移动方向
var time_accumulator : float = 0
var turn_timer : float = 0.0
var move_lock_timer : float = 0.0
var last_turn_position_x : float = 0.0
var is_turning : bool = false

func _ready():
	last_turn_position_x = position.x
	# 确保 RayCast2D 正确启用
	$one_detection_turn_direction/RayCast2D_Left.enabled = true
	$one_detection_turn_direction/RayCast2D_Right.enabled = true


func _process(delta: float) -> void:
	get_worm_situation(delta)
	Death()


func get_worm_situation(delta: float):
	time_accumulator += delta



	# --- 掉头后移动锁定阶段 ---
	if move_lock_timer > 0:
		move_lock_timer -= delta
		position.x += delta * speed * move_direction
		return  # 在锁定期内不检测悬崖和定时折返

	is_turning = false

	# --- 左右悬崖检测 ---
	if move_direction == 1 and $one_detection_turn_direction/RayCast2D_Right.is_colliding() == false:
		if abs(position.x - last_turn_position_x) >= turn_lock_distance:
			move_direction = -1
			is_turning = true
	elif move_direction == -1 and $one_detection_turn_direction/RayCast2D_Left.is_colliding() == false:
		if abs(position.x - last_turn_position_x) >= turn_lock_distance:
			move_direction = 1
			is_turning = true

	# --- 定时折返 ---
	if not is_turning and time_accumulator >= switch_interval:
		move_direction *= -1
		is_turning = true

	# --- 掉头处理 ---
	if is_turning:
		turn_timer = turn_pause_time
		time_accumulator = 0
		last_turn_position_x = position.x
		move_lock_timer = min_move_after_turn
		smooth_turn()  # 平滑翻转

	# --- 移动 ---
	position.x += delta * speed * move_direction


# 平滑掉头动画
func smooth_turn():
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "scale:x", sign(move_direction), turn_tween_time)


# 蠕虫死亡
func Death():
	if health <= 0:
		queue_free()


# 碰到子弹
func _on_area_entered(area: Area2D) -> void:
	health -= 1
	area.queue_free()
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D,"material:shader_parameter/amount",1.0,0.0)
	tween.tween_property($AnimatedSprite2D,"material:shader_parameter/amount",0.0,0.0).set_delay(0.08)


# 碰到玩家
func _on_body_entered(body: Node) -> void:
	if body is playerscript:
		body.get_damaged(20)


#func _on_left_body_exited(body: Node2D) -> void:
	#move_direction = 1


#func _on_right_body_exited(body: Node2D) -> void:
	#move_direction = -1
