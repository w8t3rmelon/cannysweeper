extends Node

var tileTemplate = preload("res://Scenes/Objects/Tile.tscn")

@export var board: Control
@export var zoomIndicator: Label

@export var gameOverScreen: Control
@export var winScreen: Control

@export var uncannyJumpscare: TextureRect

@export var tiles: Array

@export var difficulties: Array[Preset]

var firstClick = true
var timerCounting = false
var time = 0.0

var gameEnded = false

var markedMines = 0

var boardScale = Vector2.ONE
var boardPosition = Vector2.ZERO
var boardOffset = Vector2.ZERO
var zoom = 100.0

var panning = false

func _input(e: InputEvent):
	if e is InputEventMouseButton:
		if e.button_index == MOUSE_BUTTON_MIDDLE:
			panning = e.pressed
		if e.pressed:
			if e.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom += 10
				board.scale = boardScale * (zoom / 100.0)
			elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom -= 10
				if zoom < 10:
					zoom = 10
				board.scale = boardScale * (zoom / 100.0)
	elif e is InputEventMouseMotion and panning:
		boardOffset += e.relative
		board.position = boardPosition + boardOffset

func gameover():
	if gameEnded: return
	gameEnded = true
	timerCounting = false
	
	SND.snd_play(Enums.Sound.JUMPSCARE)
	uncannyJumpscare.show()
	var squeen = get_tree().create_tween()
	squeen.tween_property(uncannyJumpscare, "modulate", Color(1, 1, 1, 0), 1)
	squeen.tween_callback(func():
		uncannyJumpscare.modulate = Color(1, 1, 1, 1)
		uncannyJumpscare.hide())
	
	gameOverScreen.show()
	for row in tiles:
		for t in row:
			if t.hasMine:
				t.texture = t.mineTexture
			if not t.hasMine and t.type == Enums.TileType.FLAGGED:
				t.texture = t.flaggedNoMineTexture

func win():
	if gameEnded: return
	gameEnded = true
	timerCounting = false
	
	winScreen.show()
	for row in tiles:
		for t in row:
			if t.hasMine:
				t.texture = t.mineWinTexture

func flag_state_change_callback(state: Enums.TileType):
	if state == Enums.TileType.FLAGGED:
		markedMines += 1
	elif state == Enums.TileType.UNSURE:
		markedMines -= 1
	$HUD/Mines.text = "Mines: %d/%d" % [markedMines, GSettings.mines]

var checkQueue = []
var checkQueuePos = 0
func reveal_empty_space(tile: Tile):
	var curTile = tile
	while curTile != null:
		var adjacent = get_adjacent_tiles(curTile.tileCoordinates)
		for a in adjacent:
			if not a.hasMine and not alreadyRevealed.has(a.tileCoordinates):
				if a.adjacentMines == 0:
					alreadyRevealed.push_back(a.tileCoordinates)
					a.revealNoCallback()
					checkQueue.push_back(a)
				elif a.adjacentMines > 0:
					alreadyRevealed.push_back(a.tileCoordinates)
					a.revealNoCallback()
		
		if checkQueuePos >= len(checkQueue):
			curTile = null
		else:
			curTile = checkQueue[checkQueuePos]
			checkQueuePos += 1
	checkQueue.clear()
	checkQueuePos = 0
func reveal_empty_space2(tile: Tile):
	var curTile = tile
	while curTile != null:
		var adjacent = get_adjacent_tiles(curTile.tileCoordinates)
		for a in adjacent:
			if not a.hasMine and not alreadyRevealed.has(a.tileCoordinates):
				if a.adjacentMines == 0:
					alreadyRevealed.push_back(a.tileCoordinates)
					a.revealNoCallback()
				elif a.adjacentMines > 0:
					alreadyRevealed.push_back(a.tileCoordinates)
					a.revealNoCallback()
		
		if checkQueuePos >= len(checkQueue):
			curTile = null
		else:
			curTile = checkQueue[checkQueuePos]
			checkQueuePos += 1
	checkQueue.clear()
	checkQueuePos = 0

var alreadyRevealed = []
func reveal_callback2(tile: Tile):
	if firstClick:
		if tile.hasMine:
			print("first click has mine, relocating")
			# find first empty tile and relocate the mine there
			var break2 = false
			for row in tiles:
				if break2: break
				for t in row:
					if not t.hasMine:
						t.hasMine = true
						break2 = true
						break
			tile.hasMine = false
			mark_adjacent()
		
		firstClick = false
		
	if not timerCounting:
		timerCounting = true
	if tile.hasMine:
		gameover()
		return
		
	reveal_empty_space2(tile)
	
	if win_check():
		win()
func reveal_callback(tile: Tile):
	if firstClick:
		if tile.hasMine:
			print("first click has mine, relocating")
			# find first empty tile and relocate the mine there
			for row in tiles:
				for t in row:
					if not t.hasMine:
						t.hasMine = true
						break
			tile.hasMine = false
			mark_adjacent()
		
		firstClick = false
		
	if not timerCounting:
		timerCounting = true
	if tile.hasMine:
		gameover()
		return
		
	reveal_empty_space(tile)
	
	if win_check():
		win()

func get_tile(coord: Vector2i):
	if coord.y > -1 and coord.y <= len(tiles) - 1:
		if coord.x > -1 and coord.x <= len(tiles[coord.y]) - 1:
			return tiles[coord.y][coord.x]
	return null
	
func win_check():
	var won = true
	for row in tiles:
		for t in row:
			if t.type == Enums.TileType.BLOCKED and not t.hasMine:
				won = false
				break
	return won

func get_adjacent_tiles(coord: Vector2i):
	var tl = get_tile(coord + Vector2i(-1, -1))
	var tc = get_tile(coord + Vector2i(0, -1))
	var tr = get_tile(coord + Vector2i(1, -1))
	
	var cl = get_tile(coord + Vector2i(-1, 0))
	var cr = get_tile(coord + Vector2i(1, 0))
	
	var bl = get_tile(coord + Vector2i(-1, 1))
	var bc = get_tile(coord + Vector2i(0, 1))
	var br = get_tile(coord + Vector2i(1, 1))
	
	var adj = []
	
	if tl: adj.push_back(tl)
	if tc: adj.push_back(tc)
	if tr: adj.push_back(tr)
	if cl: adj.push_back(cl)
	if cr: adj.push_back(cr)
	if bl: adj.push_back(bl)
	if bc: adj.push_back(bc)
	if br: adj.push_back(br)
	
	return adj
	
func mark_adjacent():
	for row in tiles:
		for t in row:
			var adjacent = get_adjacent_tiles(t.tileCoordinates)
			var ac = 0
			for a in adjacent:
				if a.hasMine: ac += 1
			t.adjacentMines = ac
	
func mark_tiles():
	var currentMines = 0
	print("placing mines")
	var boardSize = GSettings.width * GSettings.height
	if GSettings.mines >= boardSize:
		OS.alert("I can't put %d mines on the board! Limiting to %d mines." % [GSettings.mines, boardSize - 1])
		GSettings.mines = boardSize - 1
	while currentMines < GSettings.mines:
		var t = tiles[randi_range(0, GSettings.height - 1)][randi_range(0, GSettings.width - 1)]
		if not t.hasMine:
			t.hasMine = true
			currentMines += 1
	print("mines done")
	
	mark_adjacent()
	
	print("all done")
		
func make_row(i):
	var row = []
	for x in range(0, GSettings.width):
		var tile: Tile = tileTemplate.instantiate()
		tile.tileCoordinates = Vector2i(x, i)
		tile.position = (Vector2i(x, i) * 32)
		tile.revealed.connect(func(): reveal_callback(tile))
		tile.revealed2.connect(func(): reveal_callback2(tile))
		tile.flagStateChanged.connect(flag_state_change_callback)
		board.add_child.call_deferred(tile)
		row.push_back(tile)
	tiles.push_back(row)

func new_game():
	print("clearing everything")
	$GameView/Welcome.hide()
	zoom = 100
	boardOffset = Vector2.ZERO
	markedMines = 0
	time = 0.0
	timerCounting = false
	firstClick = true
	gameEnded = false
	
	for row in tiles:
		for t in row:
			t.queue_free()
	tiles.clear()
	alreadyRevealed.clear()
	
	winScreen.hide()
	gameOverScreen.hide()
	
	print("making rows")
	for y in range(0, GSettings.height):
		make_row.call_deferred(y)
	
	print("positioning board")
	board.position = (board.size / 2) - ((Vector2(GSettings.width, GSettings.height) * 32) / 2)
	board.pivot_offset = ((Vector2(GSettings.width, GSettings.height) * 32) / 2)
	
	# code was stolen from kmines (minefielditem.cpp:252) for this
	var xAxisDominant = (GSettings.width + 1) / board.size.x > (GSettings.height + 1) / board.size.y
	var size = 0
	if xAxisDominant:
		size = board.size.x / (GSettings.width + 1)
	else:
		size = board.size.y / (GSettings.height + 1)
	boardScale = Vector2.ONE * (size / 32)
	
	board.scale = boardScale
	
	$HUD/Mines.text = "Mines: %d/%d" % [markedMines, GSettings.mines]
	
	await get_tree().process_frame
	
	print("marking tiles")
	mark_tiles.call_deferred()
	
func _ready():
	for p in difficulties:
		$ConfigurationWindow/Container/Difficulty/Box.add_item(p.name)
	$ConfigurationWindow/Container/Difficulty/Box.add_item("Custom", 999)

func _process(delta):
	if timerCounting:
		time += delta
	var minutes = time / 60
	var seconds = fmod(time, 60)
	$HUD/Time.text = "Time: %02d:%02d" % [minutes, seconds]
	$GameView/ZoomIndicator.text = "%d%%" % zoom
	$GameView/ZoomIndicator.visible = zoom != 100

var selectedPreset = 0

func _on_configuration_window_confirmed() -> void:
	if selectedPreset == 6: # custom
		GSettings.width = $ConfigurationWindow/Container/Width/Box.value
		GSettings.height = $ConfigurationWindow/Container/Height/Box.value
		GSettings.mines = $ConfigurationWindow/Container/Mines/Box.value
	else:
		var preset = difficulties[selectedPreset]
		GSettings.width = preset.width
		GSettings.height = preset.height
		GSettings.mines = preset.mines
		
	GSettings.reduceVFX = $ConfigurationWindow/Container/LimitVFX.button_pressed


func _on_difficulty_selected(index):
	selectedPreset = index
	if index == 6:
		$ConfigurationWindow/Container/Width.show()
		$ConfigurationWindow/Container/Height.show()
		$ConfigurationWindow/Container/Mines.show()
	else:
		$ConfigurationWindow/Container/Width.hide()
		$ConfigurationWindow/Container/Height.hide()
		$ConfigurationWindow/Container/Mines.hide()
