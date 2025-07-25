extends Area2D

# 蠕虫敌人移动速度
@export var Speed :float = 0
# 蠕虫折返
@export var switch_interval :float = 0
# 蠕虫的血量
@export var health :int = 0

@export var b_script_instance: Node



# 内部累计时间
var time_accumulator :float = 0
# 设 蠕虫的右朝向为1
var move_direction :int = 1



# 检测蠕虫的每一帧状态
func _process(delta: float) -> void:
	get_worm_situation(delta)
	Death()
	
	
# 蠕虫与子弹撞后的状态
func _on_area_entered(area: Area2D) -> void:
	health -= 1
	area.queue_free()  # 子弹碰撞后 “子弹”销毁

	var tween = create_tween()
	
	# 在“position”位置，沿Vectir2(100,200)移动，持续1秒
	# tween.tween_property(self,"position",Vector2(100,200),1) 
	tween.tween_property($AnimatedSprite2D,"material:shader_parameter/amount",1.0,0.0)
	
	# set_delay(0.1)延迟0.1秒显示果
	tween.tween_property($AnimatedSprite2D,"material:shader_parameter/amount",0.0,0.0).set_delay(0.08)
	
	
	

	
		
# 蠕虫 死亡状态
func Death():
	if health <= 0:
		queue_free()  # 子弹碰撞后 “子弹”销毁


# 蠕虫 通常状态
func get_worm_situation(delta):
	
	var animation = 'Idle'
	
	time_accumulator += delta

	if time_accumulator >= switch_interval:
		move_direction *= -1
		time_accumulator = 0
		$AnimatedSprite2D.flip_h = move_direction < 1
		
	position.x += delta * Speed * move_direction
	


func _on_body_entered(body: Node2D) -> void:
	
	# 调用已经设置全域名的脚本。先new()后再调用
	var player = playerscript.new()
	player.test()
	
