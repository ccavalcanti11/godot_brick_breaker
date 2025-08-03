extends CharacterBody2D

@export var speed = 400

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis('move_left', 'move_right')
	velocity.x = direction * speed
	move_and_slide()
	
