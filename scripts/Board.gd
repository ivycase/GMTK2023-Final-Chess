extends Node2D

@export var Piece : PackedScene
@export var Tilemap : TileMap

var board_size = Vector2i(4, 4)
var board_matrix = []

var current_piece = null
var current_piece_moves = []

### PRIVATE FUNCTIONS ###

func _ready():
	var row = []
	for i in board_size.x: 
		row.append(null)
	for j in board_size.y:
		board_matrix.append(row.duplicate())
	
	add_piece(Global.Type.KING, Global.Team.GREEN, Vector2i(3, 0))
	print("current board: ", board_matrix)
		
func _input(_event):
	if Input.is_action_just_released("click"):
		var mouse_pos = get_local_mouse_position()
		var coords = Tilemap.local_to_map(mouse_pos)
		print("clicked tile: ", coords)
		
		if !(0 <= coords.x && coords.x < board_size.x) || !(0 <= coords.y && coords.y < board_size.y): # not inside board
			current_piece = null
			set_highlight(false)
			piece_deselect()
			return
			
		if current_piece:
			set_highlight(false)
			move_current_piece(coords)
			piece_deselect()
		else:
			piece_select(board_matrix[coords.x][coords.y])
			set_highlight(true)
			print("current_piece: ", current_piece)
			print("current_piece moves: ", current_piece_moves)
			
### PUBLIC FUNCTIONS ###
			
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
		current_piece_moves.erase(coords)
		for unused in current_piece_moves:
			destroy_tile(unused)
		
		board_matrix[current_piece.tile.x][current_piece.tile.y] = null
		board_matrix[coords.x][coords.y] = current_piece
		current_piece.set_tile(coords, Tilemap.map_to_local(coords))
		
func piece_select(piece):
	if !piece: return piece_deselect()
	
	current_piece = piece
	current_piece_moves = legal_moves(piece)
	
func piece_deselect():
	current_piece_moves = []
	current_piece = null
	
func set_highlight(do_highlight):
	for tile in current_piece_moves:
		if do_highlight: Tilemap.set_cell(1, tile, 0, Vector2i(10, 10))
		else: Tilemap.erase_cell(1, tile)
	
### GET LEGAL MOVES ###

func filter_invalid_moves(moves):
	var filter = moves.duplicate()
	
	for move in moves:
		if !(0 <= move.x && move.x < board_size.x) || !(0 <= move.y && move.y < board_size.y): filter.erase(move) # out of board
		elif board_matrix[move.x][move.y] != null && board_matrix[move.x][move.y]: filter.erase(move)  # occupied by friendly piece
	
	return filter

func legal_moves(piece):
	var moves = []
	
	for move in piece.get_pattern():
		moves.append(move + piece.tile)
		
	return filter_invalid_moves(moves)
	
