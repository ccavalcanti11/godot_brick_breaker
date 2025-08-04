extends Control

func _ready():
	
	for button in $GridContainer.get_children():
		var level_text = button.text.split(" ")[1]
		button.pressed.connect(_on_level_button_pressed.bind(int(level_text)))

func _on_level_button_pressed(level_number):
	GameManager.reset_game()
	GameManager.load_level(level_number)



func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
