extends Area2D

@export var bullet_speed :int = 200

var direction := 1 # 设定方向， 因为这个变量会根据 'level.gd' 改变， 所以设任意数值都可


func _process(delta: float) -> void:

	position.x += bullet_speed * delta * direction
