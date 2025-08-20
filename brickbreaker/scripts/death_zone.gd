extends Area2D

signal ball_lost

func _on_body_entered(body: Node2D) -> void:
	print("body entered death zone: " + body.name)
	if body.is_in_group("ball"):
		print(" body is ball!")
		ball_lost.emit()
		body.queue_free()
	
