extends Area2D

@export var bullet_speed :int = 200

var direction := 1 # 设定方向， 因为这个变量会根据 'level.gd' 改变， 所以设任意数值都可

func _ready() -> void:
	
	# 子弹根据人物朝向翻转
	# 子弹一开始的时候是朝右的
	# 子弹随着人物朝向翻转（也就是子弹材质翻转）
	$Sprite2D.flip_h = direction < 0 

func _process(delta: float) -> void:

	position.x += bullet_speed * delta * direction
