extends Node2D

@onready var paddle = $Paddle
@onready var ball_container = $BallContainer
@onready var level_container = $LevelContainer
@onready var ui = $UI

const BallScene = preload("res://scenes/Ball.tscn")
const PauseMenuScene = preload("res://scenes/PauseMenu.tscn")

var ball_on_paddle = true

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
	
	# Add the level to the LevelContainer
	level_container.add_child(level)
	
	# Find the DeathZone in the level and connect its signal
	print("finding death zone...")
	var death_zone = level.get_node_or_null("LevelBoundaries/DeathZone")
	print("death_zone = ", death_zone)
	if death_zone:
		death_zone.ball_lost.connect(_on_ball_lost)
		print("Connected DeathZone signal")
	
	# Connect all bricks' destroyed signals
	connect_bricks(level)
	
func _process(delta: float) -> void:
	if ball_on_paddle:
		var ball = ball_container.get_child(0)
		if ball:
			ball.position = paddle.position + Vector2(0, -40)
	# Launch the ball:
		if Input.is_action_just_pressed("launch_ball"):
			ball_on_paddle = false
			ball.launch(Vector2.UP)
	
	# Handle Pausing
	if Input.is_action_just_pressed("pause"):
		if not get_tree().paused:
			get_tree().paused = true
			var pause_menu = PauseMenuScene.instantiate()
			add_child(pause_menu)

func connect_bricks(level: Node):
	# Recursively find and connect brick signals
	for brick in level.get_children():
		if brick is StaticBody2D and brick.has_signal("destroyed"):
			brick.destroyed.connect(_on_brick_destroyed)
		elif brick.get_child_count() > 0:
			connect_bricks(brick)

func _on_brick_destroyed():
	GameManager.add_score(100)
	print("Score: ", GameManager.current_score)
	ui.update_score(GameManager.current_score)
	
	# Check if all bricks are destroyed in the current level
	var level = level_container.get_child(0)
	if level:
		var remaining_bricks = count_remaining_bricks(level)
		print("remaaning bricks: ", remaining_bricks)
		if remaining_bricks == 0:
			print("All bricks destroyed! Loading next level.")
			#GameManager.load_level(GameManager.current_level+1)
			#load_level(GameManager.current_level)
	

func count_remaining_bricks(node: Node) -> int:
	var remaining_bricks = 0
	
	for child in node.get_children():
		if child is StaticBody2D and has_signal("destroyed"):
			remaining_bricks += 1
		elif child.get_child_count() > 0:
			remaining_bricks += count_remaining_bricks(child)
	return remaining_bricks
	

func reset_ball():
	for child in ball_container.get_children():
		child.queue_free()
	
	# Create new ball
	var ball = BallScene.instantiate()
	ball_container.add_child(ball)
	ball_on_paddle = true

func _on_ball_lost():
	print("ball lost signal received")
	GameManager.lose_life()
	if GameManager.current_lives > 0:
		reset_ball()
