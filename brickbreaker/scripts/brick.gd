extends StaticBody2D

signal destroyed

@export var health = 1

func hit():
	health -= 1
	if health <= 0:
		print("Brick - health below 0 will emit destroyed")
		destroyed.emit()
		queue_free()
