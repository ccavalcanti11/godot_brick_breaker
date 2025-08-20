extends RigidBody2D

@export var speed = 400
var velocity = Vector2.ZERO

func launch(dir: Vector2):
	velocity = dir * speed

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision: 
		velocity = velocity.bounce(collision.get_normal())
