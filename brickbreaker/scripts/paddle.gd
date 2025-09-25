extends CharacterBody2D

@export var speed = 400

# Skill tuning
@export var skill_forward_offset: float = 10.0 # distance above player
@export var skill_thickness: float = 6.0 # height of the hitzone shape
@export var skill_duration: float = 0.18 # seconds the hit will be active
@export var skill_cooldown: float = 0.65 # seconds before the hit can be triggered again

var _skill_time_left: float = 0.0
var _cool_down_left: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D # Reference the paddle's collision shape
@onready var skill_shape: CollisionShape2D = $SkillHitbox # Reference the skill hitbox collision shape

func get_width() -> float:
	if collision_shape and collision_shape.shape is RectangleShape2D:
		return collision_shape.shape.size.x # Width of the collision shape
	return 0 # Fallback in case the shape is not set

func _ready():
	setup_skill_hitbox()
	set_skill_active(false)

func setup_skill_hitbox() -> void:
	# Ensure the main shape is a rectangle (needed to compute top edge and width)
	var rect := collision_shape.shape as RectangleShape2D
	if rect == null:
		push_warning("Players CollisionShape2D should be RectangleShape2D for skill positioning.")
		return
	
	# Make/assign a rectangle for the skill barrier and size it to the player width
	var skill_rect := RectangleShape2D.new()
	skill_rect.size = Vector2(rect.size.x, skill_thickness)
	skill_shape.shape = skill_rect
	
	# Place the hitbox 10px above the top edge of the player
	update_skill_hitbox_transform()

func update_skill_hitbox_transform() -> void:
	var rect := collision_shape.shape as RectangleShape2D
	if rect == null:
		return
	
	# Paddle is centered at its own origin; top edge is at -size.y/2
	var top_edge := -rect.size.y * 0.5
	# Center of the skill rectangle sits half its thickness above the forward offset
	var y := top_edge - skill_forward_offset - (skill_thickness * 0.5)
	
	# Keep it centered in the X so it mirrors the player's width

func set_skill_active(active: bool) -> void:
	if skill_shape:
		skill_shape.disabled = not active

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis('move_left', 'move_right')
	velocity.x = direction * speed
	velocity.y = 0
	move_and_slide()
	
	# Timer updates for skill active window and cooldown
	if _cool_down_left > 0.0:
		_cool_down_left = max(0.0, _cool_down_left - delta)
	
	if _skill_time_left > 0.0:
		_skill_time_left  = max(0.0, _skill_time_left - delta)
		if _skill_time_left <= 0.0:
			set_skill_active(false)
	
	# Skill activation
	if Input.is_action_just_pressed("paddle_skill"):
		try_activate_skill()

func try_activate_skill() -> void:
	#Respect active window cooldown
	if _cool_down_left > 0.0 or _skill_time_left > 0.0:
		return
	
	# Ensure it sits at the right size/place just before 
	update_skill_hitbox_transform()
	
	set_skill_active(true)
	_skill_time_left = skill_duration
	_cool_down_left = skill_cooldown
