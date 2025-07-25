extends Area2D

# 蜜蜂 移动幅度的 速度
@export var speed: float = 10

# 蜜蜂 上下摆动幅度 大小
@export var swing_range: float = 10
# 蜜蜂 移动速度
@export var bee_move_speed: float = 30
# 蜜蜂血量
@export var Health :int = 0
# 蜜蜂 巡逻的折返时间
@export var switch_interval: float = 0  # 方向切换时间（秒）



# 设 蜜蜂右朝向为 1
var move_direction := 1  # 初始向右移动（1: 右，-1: 左）
# 蜜蜂 内部时间
var time_accumulator := 0.0


func _ready() -> void:
	get_animation()

# 检测蜜蜂的每一帧状态
func _process(delta: float) -> void:
	get_bee_situation(delta)
	Death()
	
	


# 蜜蜂与子弹碰撞的状态
func _on_area_entered(area: Area2D) -> void:
	area.queue_free()  # 子弹碰撞后销毁
	Health -= 1
	var tween = create_tween()
	
	# tween.tween_property(self,"position",Vector2(100,200),1) # 在“position”位置，沿Vectir2(100,200)移动，持续1秒
	tween.tween_property($AnimatedSprite2D,"material:shader_parameter/amount",1.0,0.0)
	
	# set_delay(0.1)延迟0.1秒显示果
	tween.tween_property($AnimatedSprite2D,"material:shader_parameter/amount",0.0,0.0).set_delay(0.08)
	
	


# 蜜蜂的动画逻辑
func get_animation():
	pass  # 可以添加动画控制逻辑


# 蜜蜂的通常状态
func get_bee_situation(delta: float) -> void:
	# 上下浮动
	position.y += sin(Time.get_ticks_msec() / speed) * swing_range * delta
	
	# 左右移动逻辑
	time_accumulator += delta
	if time_accumulator >= switch_interval:
		move_direction *= -1  # 切换方向
		time_accumulator = 0.0
		
		# 注意！  .flip_h为 bool值，如果需要翻转材质， 也需要在 1 与 -1 间切换
		$AnimatedSprite2D.flip_h = move_direction < 0 # 转换材质方向
	
	position.x += move_direction * bee_move_speed * delta


# 蜜蜂的死亡状态
func Death():
	if Health <= 0:
		queue_free()
		

		
