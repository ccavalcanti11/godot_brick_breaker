extends StaticBody2D

signal destroyed

@export var health = 1

func hit():
	print("called hit will emit destroyed")
	destroyed.emit()
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("ball"):
		print("Ball collided with brick!")
		health -= 1
		if health <= 0:
			hit()
