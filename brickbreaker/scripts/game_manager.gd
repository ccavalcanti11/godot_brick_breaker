extends Node

var current_score = 0
var current_lives = 3
var current_level = 1

signal score_updated(new_score)
signal lives_updated(new_lives)

func reset_game():
	current_score = 0
	current_lives = 3
	current_level = 1
	score_updated.emit(current_score)
	lives_updated.emit(current_lives)

func lose_life():
	current_lives -= 1
	lives_updated.emit(current_lives)
	
	if current_lives <= 0:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func add_score(amount: int):
	current_score += amount
	score_updated.emit(current_score)

func load_level(level_num):
	current_level = level_num
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
	
