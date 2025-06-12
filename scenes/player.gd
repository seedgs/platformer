extends CharacterBody2D

var direction_x: float = 0.0

# 跳跃参数
@export var jump_force : int = -400
@export var gravity_force : int = 10
@export var speed_horizonal : int = 150

# 二段跳相关
var jump_count := 0
@export var max_jump_count := 2

#设置射击状态为打开
var can_shoot := true

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	
	#启动点击方法
	get_input()
	
	#启动重力方法
	apply_gravity()
	
	#启动转向方法
	turn_face()
	
	# 水平移动
	velocity.x = direction_x * speed_horizonal
	
	# 落地时重置跳跃次数
	if is_on_floor():
		jump_count = 0

	move_and_slide()


#点击方法
func get_input():
	direction_x = Input.get_axis("Left", "Right")

	if Input.is_action_just_pressed("Jump") and jump_count < max_jump_count:
		velocity.y = jump_force
		jump_count += 1
		
	#1、添加射击限制时间节点
	#2、给Palyer挂载'timeout()'信号
	#3、方法内重新开启射击状态
	#4、启动计数器方法
	if Input.is_action_just_pressed("shoot") and can_shoot:
		can_shoot = false
		print('shoot')
		
		#启动timeout()方法
		$Timers/CooldownTimer.stat()

# 根据方向翻转人物
func turn_face():
	if direction_x != 0:
		scale.x = sign(direction_x) * abs(scale.x)

#重力方法
func apply_gravity():
	velocity.y += gravity_force
	

#计数器方法
func _on_cooldown_timer_timeout() -> void:
	#计数器结束后，经过wait时间后，射击回复true状态
	can_shoot = true
