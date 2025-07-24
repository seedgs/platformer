extends Area2D

@export var Speed :float = 0
@export var switch_interval :float = 0

var time_accumulator :float = 0

var move_direction :int = 1

func _process(delta: float) -> void:
	get_worm_situation(delta)
	

func _on_area_entered(area: Area2D) -> void:
	print("worm lose!")
	
	queue_free() # 子弹碰撞后 “worm”销毁
	# area.queue_free()  # 子弹碰撞后 “子弹”销毁


func get_worm_situation(delta):
	
	var animation = 'Idle'
	
	time_accumulator += delta

	if time_accumulator >= switch_interval:
		move_direction *= -1
		time_accumulator = 0
		$AnimatedSprite2D.flip_h = move_direction < 1
		
	position.x += delta * Speed * move_direction
	
