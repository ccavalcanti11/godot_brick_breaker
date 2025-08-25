extends CharacterBody2D

@export var speed = 400

@onready var collision_shape = $CollisionShape2D # Reference the paddle's collision shape

func get_width() -> float:
	if collision_shape and collision_shape.shape is RectangleShape2D:
		return collision_shape.shape.size.x # Width of the collision shape
	return 0 # Fallback in case the shape is not set

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis('move_left', 'move_right')
	velocity.x = direction * speed
	velocity.y = 0
	move_and_slide()
	
