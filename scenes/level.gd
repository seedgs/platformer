extends Node2D


const bullet_scene: PackedScene = preload("res://scenes/bullet.tscn") # 打包路径内的场景至 'bullet_scene'

@export var bullet_initial_shoot_position: int = 15



# 逻辑注解
"""
# 虽然方法内没有 'last_facing_direction' 参数
# 但是 'direction_x' 是通过 'player.gd' 的 'last_facing_direction' 传递来的
# 所以 level.gd 是能够接收到 'last_facing_direction' 的
# 只要信号发送方 'player.gd' 把 'last_facing_direction' 传递 ： shoot.emit(global_position, last_facing_direction) 即可
"""
func _on_character_body_2d_shoot(pos, direction_x) -> void:
	
	var bullet = bullet_scene.instantiate()
	
	if direction_x != 0:
		if direction_x < 0:
			bullet.direction = direction_x
		else: 
			bullet.direction = direction_x
			
	
	$Bullet.add_child(bullet)  # 把 'bullet' 场景下的子节点 添加进来
	
	# 逻辑注解
	"""
	# bullet场景内的位置 为 'pos'
	# 'pos' 的 参数是 'player.gd' 里面的信号发送方 'shoot.emit(global_position, last_facing_direction)' 中的 'global_position' 参数
	"""
	
	bullet.position = pos + Vector2(bullet_initial_shoot_position * direction_x, 0) # 子弹初始射击位置距离人物的距离
