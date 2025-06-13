extends CharacterBody2D

# 方向输入
var direction_x: float = 0.0

# 跳跃、重力、移动参数
@export var jump_force: int = -400
@export var gravity_force: int = 10
@export var speed_horizonal: int = 150

# 二段跳
# 设置初始数值为 0
var jump_count := 0

# 最终数值为 2
@export var max_jump_count := 2


# 射击冷却控制
var can_shoot := true

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	get_input()
	apply_gravity()

	# 水平移动
	velocity.x = direction_x * speed_horizonal

	
	# "is_on_floor()"检测是否地面碰撞，为布尔值
	if is_on_floor():
		# 落地重置跳跃次数
		jump_count = 0

	move_and_slide()

# 玩家输入
func get_input():
	
	"""
	# ".get_axis"需要两个参数
	# 当没有任何操作的时候，direction_x = 0
	# 当按下左方向键的时候，direction_x = -1
	# 当按下右方向键的是偶，direction_x = 1
	"""
	direction_x = Input.get_axis("Left", "Right")


	"""
	# 朝向移动方向翻转人物
	# ".flip_h" 如果为 “true”，则材质纹理水平翻转
	# ".flip_h" 默认为 “false”
	"""
	if direction_x != 0:
		
		"""
		# 当按下左方向键的时候，direction_x < 0
		# 由于 按下左方向键的数值为 “负”，  = 后的 “direction_x < 0” 也为 “负”
		# 负负得正 ， 此时 “$Sprite2D.flip_h” 为 “true”，纹理材质翻转
		
		# 当按下左方向键的时候，direction_x > 0
		# 由于 按下左方向键的数值为 “正”，  = 后的 “direction_x < 0” 也为 “负”
		# 正负得正（因为 "get_axis反馈的数值是 -1 到 1 之间，所以当按下右方向键时，总数都是 > 0"） ， 此时 “$Sprite2D.flip_h” 为 “false”，纹理材质维持原状
		"""
		$Sprite2D.flip_h = direction_x < 0

	"""
	# 跳跃（支持二段跳）
	# 当按下 "Jump" 按键后 "jump_count" 开始统计
	# 按下一次，统计为 1，因为 "max_jump_count" 数值为2，符合条件 "jump_count < max_jump_count"
	# 执行跳跃， 因为没有接触地面就再次按下跳跃，所以 "不执行" 每帧执行的 "jump_count = 0"
	
	# 当再次按下 "Jump" 按键后 "jump_count" 开始统计
	# 统计为 2，因为 "max_jump_count" 数值为2， 不 符合条件 "jump_count < max_jump_count"
	# 不执行跳跃， 执行每帧的 "jump_count = 0"， 恢复初始值
	"""
	if Input.is_action_just_pressed("Jump") and jump_count < max_jump_count:
		
		#施加跳跃的力
		velocity.y = jump_force
		jump_count += 1

	# 射击冷却判断
	if Input.is_action_just_pressed("shoot") and can_shoot:
		can_shoot = false
		print("shoot")

		# 启动冷却计时器
		$Timers/CooldownTimer.start()

# 重力逻辑
func apply_gravity():
	velocity.y += gravity_force

# 计时器回调（重新允许射击）
func _on_cooldown_timer_timeout() -> void:
	can_shoot = true
