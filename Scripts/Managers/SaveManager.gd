extends Node

func saveState(tiles):
	var savedata = SaveData.new()
	for row in tiles:
		var tilerow = TileRow.new()
		var compactTiles: Array[TileCompact] = []
		for tile: Tile in row:
			var compactTile = TileCompact.new()
			if tile.hasMine:
				compactTile.state |= Enums.TileCompactState.HAS_MINE
			if tile.type == Enums.TileType.BLOCKED:
				compactTile.state |= Enums.TileCompactState.BLOCKED
			elif tile.type == Enums.TileType.FLAGGED:
				compactTile.state |= Enums.TileCompactState.FLAGGED
			elif tile.type == Enums.TileType.UNSURE:
				compactTile.state |= Enums.TileCompactState.UNSURE
			compactTiles.append(compactTile)
		tilerow.tiles = compactTiles
		savedata.rows.append(tilerow)
	savedata.timer = $/root/Main.time
	savedata.width = GSettings.width
	savedata.height = GSettings.height
	savedata.mines = GSettings.mines
	ResourceSaver.save(savedata, "user://Save.res")

func loadState():
	var savedata = ResourceLoader.load("user://Save.res")
	
