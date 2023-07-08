extends Node2D

@export var Piece : PackedScene
@export var Tilemap : TileMap

var board_size = Vector2i(4, 4)
var board_matrix = []
var destroyed_matrix = []

var current_piece = null
var current_piece_moves = []

### PRIVATE FUNCTIONS ###

func _ready():
	var board_row = []
	var destroyed_row = []
	for i in board_size.x: 
		board_row.append(null)
		destroyed_row.append(false)
	for j in board_size.y:
		board_matrix.append(board_row.duplicate())
		destroyed_matrix.append(destroyed_row.duplicate())
	
	add_piece(Global.Type.KING, Global.Team.GREEN, Vector2i(3, 0))
	add_piece(Global.Type.PAWN, Global.Team.GREEN, Vector2i(2, 0))
	add_piece(Global.Type.KING, Global.Team.PINK, Vector2i(0, 3))
	add_piece(Global.Type.PAWN, Global.Team.PINK, Vector2i(1, 2))
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
	new_piece.type = type
	new_piece.team = team
	new_piece.set_tile(tile, Tilemap.map_to_local(tile))
	board_matrix[tile.x][tile.y] = new_piece
	add_child(new_piece)
	Global.add_piece(new_piece, team)
	
func remove_piece(tile):
	var piece = board_matrix[tile.x][tile.y]
	if piece == null: return
	
	board_matrix[tile.x][tile.y] = null
	remove_child(piece)
	piece.queue_free()
	
func destroy_tile(tile):
	remove_piece(tile)
	destroyed_matrix[tile.x][tile.y] = true
	Tilemap.set_cell(1, tile, 0, Vector2i(0, 14))
			
func move_current_piece(tile):
	if tile in current_piece_moves:
		current_piece_moves.erase(tile)
		for unused in current_piece_moves:
			destroy_tile(unused)
		
		remove_piece(tile)
		board_matrix[tile.x][tile.y] = current_piece
		current_piece.set_tile(tile, Tilemap.map_to_local(tile))
	
		Global.switch_teams()
		
func piece_select(piece):
	if !piece: return piece_deselect()
	if piece.team != Global.get_current_team(): return piece_deselect()
	
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

func filter_invalid_moves(piece, moves):
	var filter = moves.duplicate()
	
	for move in moves:
		if !(0 <= move.x && move.x < board_size.x) || !(0 <= move.y && move.y < board_size.y): filter.erase(move) # out of board
		elif board_matrix[move.x][move.y] != null && board_matrix[move.x][move.y].team == piece.team: filter.erase(move) # occupied by friendly piece
		elif destroyed_matrix[move.x][move.y]: filter.erase(move) #tile is destroyed
	
	return filter
	
func get_pawn_captures(piece):
	var captures
	match piece.team:
		Global.Team.GREEN:
			captures = [Vector2i(1, 1) + piece.tile, Vector2i(-1, 1) + piece.tile]
		Global.Team.PINK:
			captures = [Vector2i(1, -1) + piece.tile, Vector2i(-1, -1) + piece.tile]
	
	
	var filter = captures.duplicate()
	for move in captures:
		if board_matrix[move.x][move.y] == null || board_matrix[move.x][move.y].team == piece.team: filter.erase(move)
	
	return filter

func legal_moves(piece):
	var moves = []
	if piece.type == Global.Type.PAWN:
		moves.append_array(get_pawn_captures(piece))
	
	for move in piece.get_pattern():
		moves.append(move + piece.tile)
	
	print(moves)
		
	return filter_invalid_moves(piece, moves)
	
