extends PopupMenu

func _index_pressed(i: int):
	match i:
		0: $/root/Main.new_game()
		1: $/root/Main.load_from_save()
		2: $/root/Main/ConfigurationWindow.show()
		3: $/root/Main.pause()
		4: $/root/Main.quit()
