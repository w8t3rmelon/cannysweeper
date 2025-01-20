extends PopupMenu

func _index_pressed(i: int):
	match i:
		0: $/root/Main/AboutWindow.show()
