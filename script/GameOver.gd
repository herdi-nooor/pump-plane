extends CanvasLayer

signal Restart


func _on_restart_button_pressed():
	Restart.emit()
