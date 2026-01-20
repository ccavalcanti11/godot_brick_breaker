extends Node2D

@onready var paddle = $Paddle
@onready var ball_container = $BallContainer
@onready var level_container = $LevelContainer
@onready var ui = $UI

const BallScene = preload("res://scenes/Ball.tscn")
const PauseMenuScene = preload("res://scenes/PauseMenu.tscn")

var ball_on_paddle: bool = true
var bricks_node: Node = null

func _ready() -> void:
	load_level(GameManager.current_level)

	reset_ball()
	
	GameManager.lives_updated.connect(ui.update_lives)
	GameManager.score_updated.connect(ui.update_score)
	ui.update_lives(GameManager.current_lives)
	ui.update_score(GameManager.current_score)

func load_level(level_number: int) -> void:
	# Remove previous level
	for child in level_container.get_children():
		child.queue_free()
	
	# Load the new level
	var level_path = "res://scenes/levels/Level%s.tscn" % level_number
	var level_scene = load(level_path)
	var level = level_scene.instantiate()
	
	# Finding the bricks node:
	bricks_node = level.get_node_or_null("Bricks")
	if bricks_node:
		print("the bricks node: ", bricks_node)
		connect_bricks(bricks_node)
	else:
		print("Bricks node not found!")
		
	# Add the level to the LevelContainer
	level_container.add_child(level)
	
	# Find the DeathZone in the level and connect its signal
	print("finding death zone...")
	var death_zone = level.get_node_or_null("LevelBoundaries/DeathZone")
	print("death_zone = ", death_zone)
	if death_zone:
		death_zone.ball_lost.connect(_on_ball_lost)
		print("Connected DeathZone signal")
	
	
func _physics_process(delta: float) -> void:
	# Update ball position in physics_process to sync with paddle movement
	if ball_on_paddle:
		var ball = ball_container.get_child(0)
		if ball:
			# Position ball relative to paddle's global position
			ball.global_position = Vector2(paddle.global_position.x, paddle.global_position.y - 60)
			ball.linear_velocity = Vector2.ZERO # Clear any residual velocity
			
			# Check for launch input
			if Input.is_action_just_pressed("launch_ball"):
				ball_on_paddle = false
				ball.freeze = false
				ball.launch(Vector2.UP)

func _process(delta: float) -> void:
	# Handle Pausing
	if Input.is_action_just_pressed("pause"):
		if not get_tree().paused:
			get_tree().paused = true
			var pause_menu = PauseMenuScene.instantiate()
			add_child(pause_menu)

func connect_bricks(bricks: Node):
	# Recursively find and connect brick signals
	for brick in bricks.get_children():
		if brick is StaticBody2D and brick.has_signal("destroyed"):
			print("Connecting brick signal for: ", brick.name)
			brick.destroyed.connect(_on_brick_destroyed)

func _on_brick_destroyed():
	GameManager.add_score(100)
	print("Score: ", GameManager.current_score)
	ui.update_score(GameManager.current_score)
	
	# Count how many bricks are left
	var remaining_bricks = count_remaining_bricks()
	print("_on_brick_destroyed - Remaining bricks: ", remaining_bricks)
	
	# Load the next level if no bricks present
	if remaining_bricks <= 0:
		print("All bricks destroyed, loading next level!")
		#GameManager.load_level(GameManager.current_level + 1)
		#load_level(GameManager.current_level)
	
	
func count_remaining_bricks() -> int:
	var remaining_bricks = 0
	print("bricks_node is: ", bricks_node)
	if bricks_node:
		print("count_remaining_bricks - bricks_node != null")
		for brick in bricks_node.get_children():
			if brick is StaticBody2D and brick.has_signal("destroyed"):
				remaining_bricks += 1
	print("count_remaining_bricks - remaining bricks: ", remaining_bricks)
	return remaining_bricks - 1
	

func reset_ball():
	# Remove old ball immediately (not deferred)
	for child in ball_container.get_children():
		child.free() # Use free() instead of queue_free() for immediate removal
	
	# Create new ball
	var ball = BallScene.instantiate()
	ball_container.add_child(ball)
	ball_on_paddle = true
	
	# Wait for the ball to be fully in the scene tree
	await get_tree().process_frame
	
	# Now set ball position and freeze it
	if ball and is_instance_valid(ball):
		ball.freeze = true
		ball.global_position = Vector2(paddle.global_position.x, paddle.global_position.y - 60)
		ball.linear_velocity = Vector2.ZERO

func _on_ball_lost():
	print("ball lost signal received")
	GameManager.lose_life()
	if GameManager.current_lives > 0:
		reset_ball()
