extends Area2D

@export var speed: float = 10
@export var swing_range: float = 10
@export var bee_move_speed: float = 30
@export var switch_interval: float = 0  # 方向切换时间（秒）

var move_direction := 1  # 初始向右移动（1: 右，-1: 左）
var time_accumulator := 0.0


func _ready() -> void:
	get_animation()

func _process(delta: float) -> void:
	get_bee_situation(delta)

func _on_area_entered(area: Area2D) -> void:
	print("hit bee")
	area.queue_free()  # 子弹碰撞后销毁

func get_animation():
	pass  # 可以添加动画控制逻辑

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


		

		
	
