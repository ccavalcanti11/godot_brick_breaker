extends RigidBody2D

@export var speed = 400
@export var min_vertical_speed = 100 # min vertical velocity to avoid being too horizontal
@export var speed_increment = 30 # How much to increase the speed per tick
@export var max_speed = 800 # Maximum speed the ball can reach
@export var speed_increase_interval = 5.0 # Time in seconds between speed increases

var velocity = Vector2.ZERO
var _time_since_last_increase = 0.0 # Tracks time since the last speed increase

func launch(dir: Vector2):
	velocity = dir.normalized() * speed

func _physics_process(delta: float) -> void:
	increase_speed(delta)
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
			
		# Checking collision against brick
		if collider.name == "PurpleBrick" || collider.name == "Brick" || collider.has_signal("destroyed"):
			collider.call("hit")
		
		# Calculate bounce effect
		velocity = velocity.bounce(normal).normalized() * speed
		
		# Ensuring the ball doesn't get stuck bouncing horizontally
		if abs(velocity.y) <= min_vertical_speed: # Check if y is too small
			velocity.y = sign(velocity.y) * min_vertical_speed # Fix it to the threshold while keeping the direction
	
func increase_speed(delta: float) -> void:
	_time_since_last_increase += delta
	if _time_since_last_increase >= speed_increase_interval:
		_time_since_last_increase = 0.0
		if speed < max_speed:
			speed += speed_increment
			print("Increased ball speed to: ",  speed)
