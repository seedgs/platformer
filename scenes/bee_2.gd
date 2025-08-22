extends Area2D 

@export var health: int = 3 # 血量
@export var speed: float = 30 # 移动速度
@export var marker1: Marker2D # A点
@export var marker2: Marker2D # B点
@export var turn_tween_time: float = 0.2 # 平滑掉头时间
@export var between_distance: float = 80.0 # 玩家与蜜蜂的距离（这个距离会触发跟踪效果）
@export var stop_distance: float = 5.0 # 当与目标小于此距离时停止，避免抖动

var current_speed: float = speed # 当前速度
@onready var target = marker2 # 初始目标点
@onready var player = get_tree().get_first_node_in_group("player") # 玩家节点

# 蜜蜂右朝向为 1，左朝向为 -1
var move_direction: int = 1
var forward: bool = true # 是否向前（marker1 -> marker2）

# 是否正在转向中
var turning: bool = false

func _ready() -> void:
	position = marker1.position # 蜜蜂起始位置放在 marker1

	connect("body_entered", Callable(self, "_on_body_entered")) # 手动连接 _on_body_entered 信号

func _process(delta: float) -> void:
	Death()

	# 方向向量（目标点 - 自身）
	var dir_vec = target.position - position

	# 避免归一化零向量：如果蜜蜂与目标太近，就不要再移动
	if dir_vec.length() > stop_distance:

		# target.position 为 结束的坐标
		# position 为 开始的坐标
		# .normalized() 方法返回一个单位向量，也就是距离
		position += dir_vec.normalized() * current_speed * delta

	get_target()
	update_facing()

# 蜜蜂死亡
func Death():
	if health <= 0:
		queue_free()

# 更新目标点逻辑
func get_target():
	# 巡逻切换
	if (forward and position.distance_to(marker2.position) < 10) or \
	   (not forward and position.distance_to(marker1.position) < 10):
		forward = not forward
		move_direction *= -1
		smooth_turn()

		#$AnimatedSprite2D.flip_h = not forward # 无平滑转向

	# 追击逻辑
	# 导致蜜蜂追踪人物后，与人物重叠在一起，然后蜜蜂疯狂打转就是因为需要一个偏移量，这时候 stop_distance 这个偏移量起到关键作用
	if position.distance_to(player.position) < between_distance: 
		target = player
		current_speed = speed * 2
	else:
		target = marker2 if forward else marker1
		current_speed = speed

# 平滑转向
func smooth_turn():

	turning = true
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "scale:x", move_direction, turn_tween_time)
	tween.connect("finished", Callable(self, "_on_turn_finished"))

func _on_turn_finished():
	turning = false

# 更新朝向
func update_facing():
	if target == player:
		
		if position.distance_to(player.position) < stop_distance: # 如果太近就不再调整朝向，避免疯狂翻转
			return


		# sign() 函数返回一个数值的符号，正数返回 1，负数返回 -1，零返回 0
		# 通过 sign() 判断玩家在蜜蜂的左边还是右边
		# 设 玩家在蜜蜂右边，此时蜜蜂朝向为左，因为我们设 蜜蜂右 move_direction 为-1，所以蜜蜂要为左，就是 1
		# 怎样 数值才能使是 1 且 玩家是在蜜蜂的右边？ 只有玩家x坐标 减去 蜜蜂x坐标， 此时的数值才是 1
		var dir = sign(player.position.x - position.x)
		if dir == 0: # 玩家正上/下方，保持原朝向
			dir = move_direction
		if dir != move_direction and not turning:
			move_direction = dir
			smooth_turn()

# 碰到子弹
func _on_area_entered(area: Area2D) -> void:
	area.queue_free()
	health -= 1
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.0)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.0).set_delay(0.08)

# 碰到玩家扣血
func _on_body_entered(body: Node) -> void:
	if body is playerscript:
		body.get_damaged(20)
