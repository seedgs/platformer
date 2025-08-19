extends Area2D

@export var health: int = 5 # 血量
@export var speed: float = 30 # 移动速度
@export var marker1: Marker2D
@export var marker2: Marker2D
@onready var target = marker2
@export var turn_tween_time : float = 0.2 

# 设 蜜蜂右朝向为 1
var move_direction :int = 1  # 初始向右移动（1: 右，-1: 左）

var forward := true # 是否向前移动

func _ready() -> void:
	position = marker1.position # 初始位置设置为 marker1 的位置

func _process(delta: float) -> void:
	Death()

	# target.position 为 结束的坐标
	# position 为 开始的坐标
	# .normalized() 方法返回一个单位向量，也就是距离
	position += (target.position - position).normalized() * speed * delta # 让目标从标记点A移动到标记点B

	get_target() # 获取目标地点

# 蜜蜂的死亡状态
func Death():
	if health <= 0:
		queue_free()

# 目标会在A点和B点之间来回移动
func get_target():

	if forward and position.distance_to(marker2.position) < 10 or \
		not forward and position.distance_to(marker1.position) < 10:  # \ 为换行符，如果不换行，就把下面代码续写在 or 后面
			forward = not forward # 切换移动方向

			move_direction *= -1 # 切换移动方向
			smooth_turn()  # 平滑翻转
	if forward: 
		target = marker2 
	else:
		target = marker1

# 平滑掉头动画
func smooth_turn():
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "scale:x", move_direction, turn_tween_time)
