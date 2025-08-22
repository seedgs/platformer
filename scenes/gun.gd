extends Area2D

@export var SwingRange :float = 0

@export var Speed :float = 0;

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
	get_gun_situation(delta)
	


func _on_body_entered(body):

	body.has_gun = true # 玩家获得枪

	# 创建一个独立的声音节点
	var sound = $Sounds/ObtainGunAudio.duplicate() # .duplicate() 复制一份声音
	get_tree().current_scene.add_child(sound)	# 添加到当前场景中，不再依赖 枪 的节点
	sound.play()

	# 等声音播完后自动清理声音节点
	sound.finished.connect(func(): sound.queue_free())

	# 马上销毁枪
	queue_free()

	
	
func get_gun_situation(delta: float):
	# 单位时间内 在垂直轴向下的移动
	position.y += sin(Time.get_ticks_msec() / Speed) * SwingRange * delta
	
	



	
