extends RigidBody2D

@export var speed = 400
@export var min_vertical_speed = 100 # min vertical velocity to avoid being too horizontal
@export var speed_increment = 30 # How much to increase the speed per tick
@export var max_speed = 800 # Maximum speed the ball can reach
@export var speed_increase_interval = 5.0 # Time in seconds between speed increases

var _time_since_last_increase = 0.0 # Tracks time since the last speed increase

func _ready():
	# Set proper RigidBody2D properties
	contact_monitor = true
	max_contacts_reported = 4
	continuous_cd = CCD_MODE_CAST_RAY  # Continuous collision detection prevents tunneling
	lock_rotation = true  # Prevent ball from rotating
	gravity_scale = 0.0  # No gravity for brick breaker
	
	# Create physics material for perfect bouncing
	var physics_mat = PhysicsMaterial.new()
	physics_mat.bounce = 1.0  # Perfect bounce
	physics_mat.friction = 0.0  # No friction
	physics_material_override = physics_mat
	
	body_entered.connect(_on_body_entered)

func launch(dir: Vector2):
	linear_velocity = dir.normalized() * speed

func _physics_process(delta: float) -> void:
	increase_speed(delta)
	
	# Maintain constant speed by normalizing the velocity
	if linear_velocity.length() > 0:
		linear_velocity = linear_velocity.normalized() * speed
	
	# Ensure minimum vertical speed to prevent horizontal bouncing
	if abs(linear_velocity.y) < min_vertical_speed and linear_velocity.length() > 0:
		linear_velocity.y = sign(linear_velocity.y) * min_vertical_speed
		linear_velocity = linear_velocity.normalized() * speed

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D or body is StaticBody2D or body is RigidBody2D:
		print("Ball collided with: ", body.name)
		
		# Check if the ball collided with the paddle
		if body.name == "Paddle":
			#1. Factor in paddle momentum
			var paddle_velocity = body.velocity.x
			linear_velocity.x += paddle_velocity * 0.5 # Paddle's velocity affects ball momentum
			
			#2. Angular control (based on hit position)
			var paddle_width = body.get_width() # Use the paddle's get_width() method
			var offset = (global_position.x - body.global_position.x) / (paddle_width / 2)
			offset = clamp(offset, -1.0, 1.0)  # Clamp to prevent extreme angles
			linear_velocity.x += offset * speed * 0.25 # Affect trajectory based on hit location
			
			# Ensure ball bounces away from paddle (prevent sticking)
			if linear_velocity.y > 0:  # Ball is moving down but should bounce up
				linear_velocity.y = -abs(linear_velocity.y)
		
		# Checking collision against brick
		if body.name == "PurpleBrick" || body.name == "Brick" || body.has_signal("destroyed"):
			body.call("hit")
		
		# Normalize velocity to maintain consistent speed
		linear_velocity = linear_velocity.normalized() * speed
		
		# Ensuring the ball doesn't get stuck bouncing horizontally
		if abs(linear_velocity.y) < min_vertical_speed:
			linear_velocity.y = sign(linear_velocity.y) * min_vertical_speed
			linear_velocity = linear_velocity.normalized() * speed
	
func increase_speed(delta: float) -> void:
	_time_since_last_increase += delta
	if _time_since_last_increase >= speed_increase_interval:
		_time_since_last_increase = 0.0
		if speed < max_speed:
			speed += speed_increment
			print("Increased ball speed to: ",  speed)
