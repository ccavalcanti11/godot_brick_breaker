extends RigidBody2D

@export var speed = 400
var velocity = Vector2.ZERO

func launch(dir: Vector2):
	velocity = dir.normalized() * speed

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal = collision.get_normal()
		var collider = collision.get_collider()
		print("Ball collided with: ", collider.name)
		# Check if the ball collided with the paddle
		if collider.name == "Paddle":
			#1. Factor in paddle momentum
			var paddle_velocity = collider.velocity.x
			velocity.x += paddle_velocity * 0.5 # Paddle's velocity affects ball momentum (adjust factor)
			
			#2. Angular control (based on hit position)
			var paddle_width = collider.get_width() # Use the paddle's get_width() method
			var offset = (global_position.x - collider.global_position.x) / (paddle_width / 2)
			velocity.x += offset * speed # Affect trajectory based on hit location
		if collider.name == "PurpleBrick":
			collider.call("hit")
		
		# Calculate bounce effect
		velocity = velocity.bounce(normal).normalized() * speed
