extends ColorRect


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	queue_free()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = true
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
