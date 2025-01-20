extends PopupMenu

func _index_pressed(i: int):
	match i:
		0: $/root/Main.new_game()
		1: $/root/Main/ConfigurationWindow.show()
		2: get_tree().quit()
