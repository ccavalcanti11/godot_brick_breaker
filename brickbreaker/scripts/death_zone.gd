extends Area2D

signal ball_lost

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		emit_signal("ball_lost")
		body.queue_free()
	
