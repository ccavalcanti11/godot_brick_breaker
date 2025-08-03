extends RigidBody2D

signal ball_lost

@export var speed = 400
var velocity = Vector2.ZERO

func launch(dir: Vector2):
	velocity = dir * speed

#func _ready() -> void:
	#launch(Vector2.UP)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision: 
		velocity = velocity.bounce(collision.get_normal())
	
	if global_position.y > get_viewport_rect().size.y + 20:
		ball_lost.emit()
		queue_free()
