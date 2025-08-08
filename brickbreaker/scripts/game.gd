extends Node2D

@onready var paddle = $Paddle
@onready var ball_container = $BallContainer
@onready var level_container = $LevelContainer
@onready var ui = $UI

const BallScene = preload("res://scenes/Ball.tscn")
const PauseMenuScene = preload("res://scenes/PauseMenu.tscn")

var ball_on_paddle = true

func _ready() -> void:
	var level_path = "res://scenes/levels/Level%s.tscn" % GameManager.current_level
	var level_scene = load(level_path)
	var level = level_scene.instantiate()
	level_container.add_child(level)
	
	for brick in level.get_children():
		if brick is StaticBody2D:
			brick.destroyed.connect(_on_brick_destroyed)

	reset_ball()
	
	GameManager.lives_updated.connect(ui.update_lives)
	GameManager.score_updated.connect(ui.update_score)
	ui.update_lives(GameManager.current_lives)
	ui.update_score(GameManager.current_score)
	
func _process(delta: float) -> void:
	if ball_on_paddle:
		var ball = ball_container.get_child(0)
		if ball:
			ball.global_position = paddle.global_position + Vector2(0, -30)
	
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
func _on_brick_destroyed():
	GameManager.add_score(100)
	
	if level_container.get_child(0).get_child_count() == 0:
		GameManager.load_level(GameManager.current_level + 1)

func reset_ball():
	for child in ball_container.get_children():
		child.queue_free()
	
	# Create new ball
	var ball = BallScene.instantiate()
	ball_container.add_child(ball)
	ball.ball_lost.connect(_on_ball_lost)
	ball_on_paddle = true

func _on_ball_lost():
	GameManager.lose_life()
	if GameManager.current_lives > 0:
		reset_ball()
