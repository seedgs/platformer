extends Area2D

@export var SwingRange :float = 0

@export var Speed :float = 0;

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
	get_gun_situation(delta)
	


func _on_body_entered(body):

	body.has_gun = true

	# player触碰后枪消失
	queue_free()
	
	
func get_gun_situation(delta: float):
	# 单位时间内 在垂直轴向下的移动
	position.y += sin(Time.get_ticks_msec() / Speed) * SwingRange * delta
	
	



	
