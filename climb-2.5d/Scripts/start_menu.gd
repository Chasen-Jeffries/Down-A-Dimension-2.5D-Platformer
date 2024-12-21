extends CanvasLayer

func _on_Button_pressed():
	print("Start button pressed!")  # Debug message
	queue_free()  # Remove the start screen
