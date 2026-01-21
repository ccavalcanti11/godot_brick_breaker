extends CharacterBody2D

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

# Skill tuning
@export var skill_forward_offset: float = 25.0 # distance above player
@export var skill_thickness: float = 6.0 # height of the hitzone shape
@export var skill_duration: float = 0.18 # seconds the hit will be active
@export var skill_cooldown: float = 0.65 # seconds before the hit can be triggered again

var _skill_time_left: float = 0.0
var _cool_down_left: float = 0.0
var _current_tilt: float = 0.0  # Current tilt angle
var _float_time: float = 0.0  # Time accumulator for floating

@onready var collision_shape: CollisionShape2D = $CollisionShape2D # Reference the paddle's collision shape
@onready var skill_shape: CollisionShape2D = $SkillHitbox # Reference the skill hitbox collision shape
@onready var visual_root: Node2D = self  # Will store visual elements for rotation

func get_width() -> float:
	if collision_shape and collision_shape.shape is CapsuleShape2D:
		var cap := collision_shape.shape as CapsuleShape2D
		return cap.radius * 2.0
	return 0.0 # Fallback in case the shape is not set

func _ready():
	setup_skill_hitbox()
	set_skill_active(false)

func setup_skill_hitbox() -> void:
	# Ensure the main shape is a capsule (needed to compute top edge and width)
	var player_cap := collision_shape.shape as CapsuleShape2D
	if player_cap == null:
		push_warning("Players CollisionShape2D should be CapsuleShape2D for skill positioning.")
		return
	
	# Create the skill capsule
	var cap := CapsuleShape2D.new()
	# Thickness controls the capsule's vertical thickness when horizontal:
	# thickness = 2 * radius => radius = thickness / 2
	cap.radius = max(skill_thickness * 0.5, 0.0)
	
	# Make the skill capsule span the player's width:
	# When rotated 90., the horizontal length of the capsule is (height + 2 * radius)
	# We want that to match player's width ( = 2 * player_cap.radius)
	var player_width := get_width() # 2 * player_cap.radius
	cap.height = max((16.0 * cap.radius), 0.0) # if <= 0, it becomes a circle
	
	skill_shape.shape = cap
	
	# Rotate 90. so the capsule becomes horizontal (thin bar above the player)
	skill_shape.rotation_degrees = 90.0
	
	# Position it above the top edge
	update_skill_hitbox_transform()

func update_skill_hitbox_transform() -> void:
	var player_cap := collision_shape.shape as CapsuleShape2D
	if player_cap == null:
		return
	
	# Total height of the vertical capsule (Y span)
	var total_height := player_cap.height + (2.0 * player_cap.radius)
	
	# Player is centered at its origin; top edge is at -total_height / 2
	var top_edge := -total_height * 0.5
	
	# The skill capsule's vertical thickness (in world y) is it diameter (2*radius)
	var half_thickness := skill_thickness * 0.5
	
	# Center the skill capsule so its bottom edge is offset above the player's top edge
	var y := top_edge - skill_forward_offset - half_thickness
	
	# Keep centered in x
	skill_shape.position = Vector2(0.0, y)
	

func set_skill_active(active: bool) -> void:
	if skill_shape:
		skill_shape.disabled = not active

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
	
	# Timer updates for skill active window and cooldown
	if _cool_down_left > 0.0:
		_cool_down_left = max(0.0, _cool_down_left - delta)
	
	if _skill_time_left > 0.0:
		_skill_time_left  = max(0.0, _skill_time_left - delta)
		if _skill_time_left <= 0.0:
			set_skill_active(false)
	
	# Skill activation
	if Input.is_action_just_pressed("player_skill"):
		try_activate_skill()

func update_robot_visuals(delta: float, direction: float) -> void:
	# Floating motion - subtle sine wave
	_float_time += delta * float_frequency
	var float_offset = sin(_float_time) * float_amplitude
	
	# Calculate target tilt based on velocity (not just input direction)
	var velocity_factor = clamp(velocity.x / max_speed, -1.0, 1.0)
	var target_tilt = velocity_factor * tilt_amount
	
	# Smooth tilt towards target
	_current_tilt = lerp(_current_tilt, target_tilt, tilt_speed * delta)
	
	# Apply rotation and floating to visual elements
	# Note: We rotate the entire node, but collision stays upright
	rotation_degrees = _current_tilt
	
	# Apply floating offset (you can add a visual node to offset separately if needed)
	# For now, this creates a subtle hover effect on the entire paddle

func try_activate_skill() -> void:
	#Respect active window cooldown
	if _cool_down_left > 0.0 or _skill_time_left > 0.0:
		return
	
	# Ensure position is correct just before activation
	update_skill_hitbox_transform()
	$AnimatedSprite2D.play("attack")
	
	set_skill_active(true)
	_skill_time_left = skill_duration
	_cool_down_left = skill_cooldown
