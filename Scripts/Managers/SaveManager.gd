extends Node

func saveState(tiles):
	if len(tiles) == 0: return
	var savedata = SaveData.new()
	for row in tiles:
		var tilerow = TileRow.new()
		var compactTiles: Array[TileCompact] = []
		for tile: Tile in row:
			var compactTile = TileCompact.new()
			compactTile.hasMine = tile.hasMine
			compactTile.type = tile.type
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
	
