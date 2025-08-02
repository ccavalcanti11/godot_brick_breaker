extends CharacterBody2D

@export var speed = 400

func _physics_process(delta: float) -> void:
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		print("move left!")
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		print("move right!")
	velocity = velocity.normalized() * speed
	move_and_slide()
	
