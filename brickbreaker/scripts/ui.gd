extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var lives_label = $LivesLabel

# Updates the score displayed in ScoreLabel
func update_score(score: int) -> void:
	score_label.text = "Score: %s" % score

# Updates the lives displayed in LivesLabel
func update_lives(lives: int) -> void:
	lives_label.text = "Lives: %s" % lives
