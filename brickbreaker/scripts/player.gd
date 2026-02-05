extends CharacterBody2D

# Signals
signal weapon_hit(hit_strength: float) # Emitted when weapon successfully hits the ball

# Movement settings
@export var max_speed: float = 400.0
@export var acceleration: float = 2000.0  # How fast robot speeds up
@export var deceleration: float = 1800.0  # How fast robot slows down
@export var friction: float = 800.0  # Slowdown when no input

# Visual feel settings
@export var tilt_amount: float = 15.0  # Degrees robot tilts when moving
@export var tilt_speed: float = 8.0  # How fast robot tilts
@export var float_amplitude: float = 3.0  # Height of floating motion
@export var float_frequency: float = 2.0  # Speed of floating motion

# Weapon hit tuning
@export var weapon_forward_offset: float = 20.0 # distance above player
@export var weapon_width: float = 20.0 # width of the weapon swing
@export var weapon_thickness: float = 8.0 # thickness of the hitzone
@export var hit_duration: float = 0.2 # seconds the hit will be active
@export var hit_cooldown: float = 0.5 # seconds before the hit can be triggered again
@export var weapon_hit_boost: float = 1.5 # Multiplier for ball velocity when hit by weapon

# Impact feel settings
@export var hitstop_duration: float = 0.08 # Brief freeze on impact
@export var impact_scale_amount: float = 1.15 # How much to scale up on impact
@export var impact_scale_duration: float = 0.12 # Duration of scale effect
@export var shake_intensity: float = 3.0 # Camera shake intensity on hit

var _hit_time_left: float = 0.0
var _cooldown_left: float = 0.0
var _current_tilt: float = 0.0  # Current tilt angle
var _float_time: float = 0.0  # Time accumulator for floating
var _weapon_active: bool = false  # Track if weapon is currently active
var _impact_scale_time: float = 0.0 # Timer for impact scale animation

@onready var collision_shape: CollisionShape2D = $CollisionShape2D # Reference the player's collision shape
@onready var weapon_area: Area2D = $WeaponArea # Reference the weapon hitbox area
@onready var weapon_hitbox: CollisionShape2D = $WeaponArea/CollisionShape2D # Reference the weapon hitbox collision shape
@onready var visual_root: Node2D = self  # Will store visual elements for rotation

func get_width() -> float:
	if collision_shape and collision_shape.shape is CapsuleShape2D:
		var cap := collision_shape.shape as CapsuleShape2D
		return cap.radius * 2.0
	return 0.0 # Fallback in case the shape is not set

func _ready():
	setup_weapon_hitbox()
	set_weapon_active(false)
	# Connect weapon hit signal
	if weapon_area:
		print_debug("Connecting weapon hit signal")
		weapon_area.body_entered.connect(_on_weapon_hit)

func setup_weapon_hitbox() -> void:
	# Ensure the main shape is a capsule (needed to compute top edge and width)
	var player_cap := collision_shape.shape as CapsuleShape2D
	if player_cap == null:
		push_warning("Players CollisionShape2D should be CapsuleShape2D for weapon positioning.")
		return
	
	# Create a rectangular weapon hitbox - better for bat-like weapon feel
	var rect := RectangleShape2D.new()
	rect.size = Vector2(weapon_width, weapon_thickness)
	
	weapon_hitbox.shape = rect
	
	# Position it above the player
	update_weapon_hitbox_transform()

func update_weapon_hitbox_transform() -> void:
	var player_cap := collision_shape.shape as CapsuleShape2D
	if player_cap == null:
		return
	
	# Total height of the vertical capsule (Y span)
	var total_height := player_cap.height + (2.0 * player_cap.radius)
	
	# Player is centered at its origin; top edge is at -total_height / 2
	var top_edge := -total_height * 0.5
	
	# Position the weapon area above the player
	var y := top_edge - weapon_forward_offset
	
	# Keep centered in x
	if weapon_area:
		weapon_area.position = Vector2(0.0, y)
	

func set_weapon_active(active: bool) -> void:
	_weapon_active = active
	print_debug("Setting weapon active: " + str(active))
	if weapon_area:
		weapon_area.monitoring = active
		weapon_area.monitorable = active
		print_debug("Weapon area monitoring: " + str(weapon_area.monitoring))

func _physics_process(delta: float) -> void:
	# Get input direction
	var direction = Input.get_axis('move_left', 'move_right')
	
	# Smooth acceleration/deceleration
	if direction != 0:
		# Accelerate towards max speed
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		# Decelerate when no input
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
	
	# Apply slight friction for more natural feel
	if abs(velocity.x) > 0 and direction == 0:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	
	velocity.y = 0
	move_and_slide()
	
	# Update visual effects
	update_robot_visuals(delta, direction)
	
	# Timer updates for weapon hit active window and cooldown
	if _cooldown_left > 0.0:
		_cooldown_left = max(0.0, _cooldown_left - delta)
	
	if _hit_time_left > 0.0:
		_hit_time_left  = max(0.0, _hit_time_left - delta)
		if _hit_time_left <= 0.0:
			set_weapon_active(false)
	
	# Weapon hit activation
	if Input.is_action_just_pressed("player_hit"):
		try_activate_hit()

func update_robot_visuals(delta: float, _direction: float) -> void:
	# Floating motion - subtle sine wave
	_float_time += delta * float_frequency
	var _float_offset = sin(_float_time) * float_amplitude
	
	# Calculate target tilt based on velocity (not just input direction)
	var velocity_factor = clamp(velocity.x / max_speed, -1.0, 1.0)
	var target_tilt = velocity_factor * tilt_amount
	
	# Smooth tilt towards target
	_current_tilt = lerp(_current_tilt, target_tilt, tilt_speed * delta)
	
	# Apply rotation and floating to visual elements
	# Note: We rotate the entire node, but collision stays upright
	rotation_degrees = _current_tilt
	
	# Handle impact scale animation
	if _impact_scale_time > 0.0:
		_impact_scale_time -= delta
		# Scale punch effect using elastic ease-out
		var scale_progress = 1.0 - (_impact_scale_time / impact_scale_duration)
		var scale_value = lerp(impact_scale_amount, 1.0, ease(scale_progress, -2.0))
		scale = Vector2(scale_value, scale_value)
	else:
		# Return to normal scale smoothly
		scale = scale.lerp(Vector2.ONE, 10.0 * delta)

func try_activate_hit() -> void:
	#Respect active window cooldown
	if _cooldown_left > 0.0 or _hit_time_left > 0.0:
		return
	
	# Ensure position is correct just before activation
	update_weapon_hitbox_transform()
	$AnimatedSprite2D.play("attack")
	
	set_weapon_active(true)
	_hit_time_left = hit_duration
	_cooldown_left = hit_cooldown

func _on_weapon_hit(body: Node2D) -> void:
	print_debug("Weapon hit detected with body: " + str(body))
	if not _weapon_active:
		return
		
	# Check if it's the ball
	if body is RigidBody2D and body.name == "Ball":
		print_debug("Weapon hit detected on ball!")
		var ball := body as RigidBody2D
		
		# Calculate hit direction based on where ball was hit
		var hit_offset = (ball.global_position.x - global_position.x) / (get_width() / 2)
		hit_offset = clamp(hit_offset, -1.0, 1.0)
		
		# Apply strong upward force with horizontal component based on hit position
		var hit_direction = Vector2(hit_offset * 0.7, -1.0).normalized()
		
		# Get current ball speed and boost it
		var current_speed = ball.linear_velocity.length()
		var boosted_speed = current_speed * weapon_hit_boost
		
		# Apply player momentum to the ball
		hit_direction.x += velocity.x / max_speed * 0.4
		
		# Set the new velocity with boost
		ball.linear_velocity = hit_direction.normalized() * boosted_speed
		
		print("Weapon hit! Boosted ball to speed: ", boosted_speed)
		
		# IMPACT EFFECTS
		# 1. Trigger hit-stop (freeze frame)
		apply_hitstop()
		
		# 2. Trigger impact scale animation on player
		_impact_scale_time = impact_scale_duration
		
		# 3. Emit signal for camera shake
		weapon_hit.emit(shake_intensity)
		
		# 4. Tell ball to show impact effect
		if ball.has_method("on_weapon_impact"):
			ball.on_weapon_impact()

func apply_hitstop():
	"""Creates a brief freeze-frame effect for impact feel"""
	get_tree().paused = true
	await get_tree().create_timer(hitstop_duration, true, false, true).timeout
	get_tree().paused = false
