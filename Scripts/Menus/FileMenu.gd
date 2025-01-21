extends PopupMenu

func _index_pressed(i: int):
	match i:
		0: $/root/Main.new_game()
		1: $/root/Main/ConfigurationWindow.show()
		2: $/root/Main.pause()
		3: 
			if randi_range(1, 4) == 2:
				$/root/Main.uncannyJumpscare.show()
				SND.snd_play(Enums.Sound.JUMPSCARE)
				await get_tree().create_timer(0.2).timeout
			
			get_tree().quit()
