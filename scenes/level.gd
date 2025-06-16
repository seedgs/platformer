extends Node2D

# 打包路径内的场景至 'bullet_scene'
const bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")

func _on_character_body_2d_shoot(pos: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	$Bullet.add_child(bullet)
	bullet.position = pos
