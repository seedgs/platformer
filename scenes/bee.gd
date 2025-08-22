extends Area2D


@export var speed: float = 30 # 移动速度
@export var swing_range: float = 10 # 上下摆动的幅度 大小
@export var health :int = 5 # 血量
@export var switch_interval: float = 2  # 巡逻的折返时间
@export var turn_tween_time : float = 0.2  
@export var turn_pause_time : float = 0.2  # 掉头停顿时间
@export var min_move_after_turn : float = 2  # 掉头后至少移动时间
@export var turn_lock_distance : float = 1.0  # 掉头后必须移动的距离



var is_turning : bool = false
var turn_timer : float = 0.0
var last_turn_position_x : float = 0.0
var move_lock_timer : float = 0.0


# 设 蜜蜂右朝向为 1
var move_direction :int = 1  # 初始向右移动（1: 右，-1: 左）

# 蜜蜂 内部时间
var time_accumulator := 0.0


func _ready() -> void:
	
	get_animation()

	# 确保 RayCast2D 正确启用
	$one_detection_turn_direction/RayCast2D_Left.enabled = true
	$one_detection_turn_direction/RayCast2D_Right.enabled = true

	connect("body_entered", Callable(self, "_on_body_entered"))

# 检测蜜蜂的每一帧状态
func _process(delta: float) -> void: 
	get_bee_situation(delta)
	Death()
	

# 蜜蜂的动画逻辑
func get_animation():
	pass  # 可以添加动画控制逻辑


# 蜜蜂的通常状态
func get_bee_situation(delta: float):
	time_accumulator += delta

	# --- 掉头后移动锁定阶段 ---
	if move_lock_timer > 0:
		move_lock_timer -= delta
		position.x += delta * speed * move_direction
		return  # 在锁定期内不检测悬崖和定时折返

	is_turning = false

# --- 左右悬崖检测 ---
	if move_lock_timer <= 0:
		if move_direction == 1 and not $one_detection_turn_direction/RayCast2D_Right.is_colliding():
			if abs(position.x - last_turn_position_x) >= turn_lock_distance:
				move_direction = -1
				is_turning = true

	elif move_direction == -1 and not $one_detection_turn_direction/RayCast2D_Left.is_colliding():
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
	tween.tween_property($AnimatedSprite2D, "scale:x", move_direction, turn_tween_time)


# 蜜蜂的死亡状态
func Death():
	if health <= 0:
		queue_free()


# 碰到子弹
func _on_area_entered(area: Area2D) -> void: 
	area.queue_free()  # 子弹碰撞后销毁
	health -= 1
	var tween = create_tween()
	
	# tween.tween_property(self,"position",Vector2(100,200),1) # 在“position”位置，沿Vectir2(100,200)移动，持续1秒
	tween.tween_property($AnimatedSprite2D,"material:shader_parameter/amount",1.0,0.0)
	
	# set_delay(0.1)延迟0.1秒显示果
	tween.tween_property($AnimatedSprite2D,"material:shader_parameter/amount",0.0,0.0).set_delay(0.08)


# 碰到玩家
func _on_body_entered(body: Node) -> void:
	if body is playerscript:
		body.get_damaged(20)
		print("碰到玩家")
