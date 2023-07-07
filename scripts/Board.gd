extends Node2D

@export var Piece : PackedScene
@export var Tilemap : TileMap

var board_size = Vector2i(4, 4)
var board_matrix = []

var current_piece = null
var current_piece_moves = []

func _ready():
	var row = []
	for i in board_size.x: 
		row += [null]
	for j in board_size.y:
		board_matrix += [row]
	
	add_piece(Global.Type.KING, Global.Team.GREEN, Vector2i(3, 0))
		
func _input(_event):
	if Input.is_action_just_pressed("click"):
		var mouse_pos = get_local_mouse_position()
		var coords = Tilemap.local_to_map(mouse_pos)
		print(coords)
		
		if !(0 <= coords.x && coords.x < board_size.x) || !(0 <= coords.y && coords.y < board_size.y): # not inside board
			return
			
		if current_piece:
			move_current_piece(coords)
		else:
			current_piece = board_matrix[coords.x][coords.y]
			
func add_piece(type, team, tile):
	var new_piece = Piece.instantiate()
	add_child(new_piece)
	new_piece.type = type
	new_piece.team = team
	new_piece.set_tile(tile, Tilemap.map_to_local(tile))
	board_matrix[tile.x][tile.y] = new_piece
	
func destroy_tile(coords):
	board_matrix[coords.x][coords.y] = null
			
func move_current_piece(coords):
	if coords in current_piece_moves:
		current_piece_moves.remove(coords)
		for unused in current_piece_moves:
			destroy_tile(unused)
		current_piece_moves = []
		
		board_matrix[current_piece.tile.x][current_piece.tile.y] = null
		board_matrix[coords.x][coords.y] = current_piece
		current_piece.set_tile(coords, Tilemap.map_to_local(coords))
	
