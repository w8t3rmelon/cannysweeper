@icon("res://Art/Canny.png")

extends TextureRect
class_name Tile

@onready var fake = $FakeCanny

var destroyAnimation = false

var velocity = Vector2(-240, -20)
var gravity = 480

signal revealed
signal revealed2
signal flagStateChanged(state: Enums.TileType)

@export var tileCoordinates: Vector2i
@export var type: Enums.TileType = Enums.TileType.BLOCKED
@export var hasMine: bool = false
@export var adjacentMines: int

@export_group("Textures")
@export var blockedTexture: Texture
@export var clickedTexture: Texture
@export var emptyTexture: Texture
@export var flaggedTexture: Texture
@export var unsureTexture: Texture
@export var mineTexture: Texture
@export var mineWinTexture: Texture
@export var flaggedNoMineTexture: Texture

@export var adjacencyTextures: Array[Texture]

		
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			(_mouse_down if event.pressed else _mouse_up).call()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if type == Enums.TileType.BLOCKED:
				type = Enums.TileType.FLAGGED
			elif type == Enums.TileType.FLAGGED:
				type = Enums.TileType.UNSURE
			elif type == Enums.TileType.UNSURE:
				type = Enums.TileType.BLOCKED
			flagStateChanged.emit(type)
			update_texture()
	
func _mouse_down():
	if type == Enums.TileType.BLOCKED or type == Enums.TileType.UNSURE:
		texture = clickedTexture
	
func _mouse_up():
	if type == Enums.TileType.BLOCKED:
		texture = blockedTexture
		reveal()
	if type == Enums.TileType.CLEARED and adjacentMines > 0:
		texture = blockedTexture
		reveal2()
	
func update_texture():
	if type == Enums.TileType.BLOCKED:
		texture = blockedTexture
	elif type == Enums.TileType.FLAGGED:
		texture = flaggedTexture
	elif type == Enums.TileType.UNSURE:
		texture = unsureTexture
	elif type == Enums.TileType.CLEARED:
		if hasMine:
			texture = mineTexture
		else:
			if adjacentMines > 0:
				texture = adjacencyTextures[adjacentMines - 1]
			else:
				texture = emptyTexture
		
func revealNoCallback():
	if type != Enums.TileType.FLAGGED:
		type = Enums.TileType.CLEARED
		if fake != null: fake.show()
		destroyAnimation = true
	update_texture()
	
func reveal2():
	if type != Enums.TileType.FLAGGED:
		type = Enums.TileType.CLEARED
		destroyAnimation = true
		if fake != null: fake.show()
		revealed2.emit()
	update_texture()

func reveal():
	if type != Enums.TileType.FLAGGED:
		type = Enums.TileType.CLEARED
		destroyAnimation = true
		if fake != null: fake.show()
		revealed.emit()
	update_texture()

func _ready():
	update_texture()

func _process(delta):
	if destroyAnimation and fake != null:
		if fake.modulate.a <= 0 or GSettings.reduceVFX:
			fake.queue_free()
			destroyAnimation = false
		velocity.y += gravity * delta
		fake.position += (velocity) * delta + Vector2(randf_range(-2, 2), randf_range(-2, 2))
		fake.rotation_degrees -= delta * 50
		fake.modulate.a -= delta
