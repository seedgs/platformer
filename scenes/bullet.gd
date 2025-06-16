extends Area2D

@export var bullet_speed: int = 0  # 子弹速度（单位像素/秒）

var shoot_direction := 0  # -1 左，1 右

func _ready():
	# 发射时记录方向（一次性）
	shoot_direction = Input.get_axis("Left", "Right")
	if shoot_direction == 0:
		shoot_direction = 1  # 默认右方向（可选）

func _process(delta: float) -> void:
	position.x += shoot_direction * bullet_speed * delta

	


		
	
