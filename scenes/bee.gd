extends Area2D


func _on_area_entered(area: Area2D) -> void:
	print("hit bee")
	area.queue_free() # 子弹触碰到后，就会消失
