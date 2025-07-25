extends CharacterBody2D


# 注册为全域名，所有本都可以调用
class_name playerscript


# 跳跃参数
@export var jump_force_first_time: int = 0
@export var jump_force_second_time: int = 0


# 重力参数
@export var gravity_force: int = 10


# 横向移动速度
@export var speed_horizonal: int = 150

# 最终数值为 2
@export var max_jump_count := 2




# 二段跳
# 设置初始数值为 0
var jump_count := 0


# 方向输入
var direction_x: float = 0.0


# 设 在人物静止状态下的方向
var last_facing_direction := 0  # 1 表示右，-1 表示左


# 射击信号
signal shoot(pos: Vector2)


# 控制射击
var can_shoot :bool = true # 射击冷却控制
var is_shooting: bool = false
var shoot_hold_time: float = 0.0
var shoot_trigger_threshold: float = 0.3  # 长按超过 0.3 秒触发持续射击

# 默认情况下，玩家没有枪
var has_gun :bool = false




func _ready() -> void:
	pass


func _process(delta: float) -> void:
	get_input()
	apply_gravity()
	get_animation()
	
	

	# 水平移动
	velocity.x = direction_x * speed_horizonal 

	
	if is_on_floor(): # "is_on_floor()"检测是否地面碰撞，为布尔值
		
		jump_count = 0 # 落地重置跳跃次数

	move_and_slide()	
	
	# 长按射击逻辑
	if Input.is_action_pressed("shoot") and has_gun:
		
		# 枪口火焰效果
		if direction_x > 0:
			$Fire.get_child(1).show() # 移动时，枪口 “右” 侧火焰效果开启
		elif direction_x < 0:
			$Fire.get_child(0).show() # 移动时，枪口 “左” 侧火焰效果开启
		elif direction_x == 0 and $AnimatedSprite2D.flip_h == false: # 原地站立时，枪口 “右” 侧火焰效果开启
			$Fire.get_child(1).show()
		elif direction_x == 0 and $AnimatedSprite2D.flip_h == true: # 原地站立时，枪口 “左” 侧火焰效果开启
			$Fire.get_child(0).show()
		
		
		shoot_hold_time += delta # 因为在_process方法内，一旦触发（不管 长按或者点击）“shoot”按钮，就会触发“shoot_hold_time” 的增加
		
		if shoot_hold_time >= shoot_trigger_threshold and not is_shooting:
			start_shooting()
	else:
		shoot_hold_time = 0.0
		stop_shooting()

	
# 玩家输入
func get_input():
	
	# 方向按键逻辑
	"""
	# ".get_axis"需要两个参数
	# 当没有任何操作的时候，direction_x = 0
	# 当按下左方向键的时候，direction_x = -1
	# 当按下右方向键的是偶，direction_x = 1
	"""
	
	direction_x = Input.get_axis("Left", "Right")

	# 逻辑注释
	"""
	# 当没有任何操作的时候，不能让子弹朝一个方向移动
	# 应该以玩家上一次朝向的方向移动
	# 所以需要先设一个方向 "var last_facing_direction := 1"
	# 然后每次玩家移动 'direction_x' 就不为 0
	# 这个情况下更新变量 'last_facing_direction = direction_x '
	"""
	if direction_x != 0:
		last_facing_direction = direction_x # 'last_facing_direction' 被赋 'direction_x' 的值（direction_x的数值是根据按下的左右键来确定的）
		
		# 转向逻辑
		"""
		# ".flip_h" 如果为 “true”，则材质纹理水平翻转
		# ".flip_h" 默认为 “false”

		# 当按下左方向键的时候，direction_x < 0
		# 由于 按下左方向键的数值为 “负”，  = 后的 “direction_x < 0” 也为 “负”
		# 负负得正 ， 此时 “$Sprite2D.flip_h” 为 “true”，纹理材质翻转
		
		# 当按下左方向键的时候，direction_x > 0
		# 由于 按下左方向键的数值为 “正”，  = 后的 “direction_x < 0” 也为 “负”
		# 正负得正（因为 "get_axis反馈的数值是 -1 到 1 之间，所以当按下右方向键时，总数都是 > 0"） ， 此时 “$Sprite2D.flip_h” 为 “false”，纹理材质维持原状
		"""
		
		$AnimatedSprite2D.flip_h = direction_x < 0

			
	
	# 二段跳跃逻辑
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
		velocity.y = jump_force_first_time
		
		jump_count += 1
		
		
		if jump_count == 2: # 当检测为二段跳状态的时候，第二次跳跃的力衰减为第一次的一半
			velocity.y = jump_force_second_time
		


	# 射击点射
	if Input.is_action_just_pressed("shoot") and can_shoot and has_gun:
			
		can_shoot = false
		
		
		# 逻辑注释
		"""
		# 括号内的数值可以传递给 level.gd 脚本
		# 把 'last_facing_direction' 传递至 level.gd 中
		"""
		shoot.emit(global_position, last_facing_direction)
		
		# 启动冷却计时器
		$Timers/CooldownTimer.start() 
		$Timers/FireTimer.start()
		
		# 枪口火焰效果
		if direction_x > 0:
			$Fire.get_child(1).show() # 移动时，枪口 “右” 侧火焰效果开启
		elif direction_x < 0:
			$Fire.get_child(0).show() # 移动时，枪口 “左” 侧火焰效果开启
		elif direction_x == 0 and $AnimatedSprite2D.flip_h == false: # 原地站立时，枪口 “右” 侧火焰效果开启
			$Fire.get_child(1).show()
		elif direction_x == 0 and $AnimatedSprite2D.flip_h == true: # 原地站立时，枪口 “左” 侧火焰效果开启
			$Fire.get_child(0).show()
			

# 重力逻辑
func apply_gravity():
	velocity.y += gravity_force 


# 射击开始
func start_shooting():
	is_shooting = true
	can_shoot = false
	
	shoot.emit(global_position, last_facing_direction)
	
	$Timers/CooldownTimer.start()


# 射击停止
func stop_shooting():
	is_shooting = false
	can_shoot = true

	$Timers/CooldownTimer.stop()


# 冷却时间
func _on_cooldown_timer_timeout() -> void:
	if is_shooting:
		shoot.emit(global_position, last_facing_direction)
	else:
		can_shoot = true


# 动画逻辑
func get_animation():
	

	var animation = 'idle' # 默认状态的动画放为闲置状态
	
	
	
	if not is_on_floor(): # 当检测不与地面碰撞的时候，启动跳跃动画
		animation = 'jump'
		
		if !can_shoot: # 当在跳跃的状态下，按下射击，启动跳跃状态下的射击动画
			animation = 'jump_shoot'


	
	elif direction_x != 0 and can_shoot : # 当检测到横向数值不为0（就是按下方向键的时候） 且 没有按下射击时候，启动行走动画
		animation = 'walk'
		
	
	elif !can_shoot : # 当检测到按下射击的时候，启动射击动画
		animation = 'idle_shoot'

		
		if direction_x != 0: # 当按下射击 且 也按下移动的时候，启动射击移动动画
			animation = 'shoot_walk'
		

	# 当在长按的状态下， 原地长按射击
	if shoot_hold_time > shoot_trigger_threshold:
		animation = 'idle_shoot'
		
		# 当在长按的状态下， 移动长按射击
		if direction_x != 0:
			animation = 'shoot_walk'
		
		# 当在长按的状态下， 跳跃长按射击
		if not is_on_floor(): 
			animation = 'jump_shoot'


	$AnimatedSprite2D.animation = animation # 加载动画
	
	
# 射击火焰效果的消失时间
func _on_fire_timer_timeout() -> void:
	for child in $Fire.get_children(): # 遍历Fire下面的项
		child.hide() # 遍历后隐藏


func test():
	print("11111111111111111")
