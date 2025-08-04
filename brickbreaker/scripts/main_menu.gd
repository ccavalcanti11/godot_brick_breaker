extends Control

func _on_start_button_pressed() -> void:
	GameManager.reset_game()
	GameManager.load_level(1)


func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
