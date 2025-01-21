class_name Enums

enum TileType {
	BLOCKED,
	CLEARED,
	FLAGGED,
	UNSURE
}

enum TileCompactState {
	BLOCKED  = 0b00000001,
	FLAGGED  = 0b00000010,
	UNSURE   = 0b00000100,
	HAS_MINE = 0b00001000
}

enum Sound {
	JUMPSCARE,
	BREAK,
	WIN
}

enum Music {
	DEFAULT
}
