extends Node2D

@export var Piece : PackedScene
@export var Tilemap : TileMap
@export var Prototype : Node2D
@export var Board_Size : Vector2i

var board_matrix = []
var destroyed_matrix = []

var current_piece = null
var current_piece_moves = []

### PRIVATE FUNCTIONS ###

func _ready():
	Global.current_board = self
	
	var board_row = []
	var destroyed_row = []
	for i in Board_Size.x: 
		board_row.append(null)
		destroyed_row.append(false)
	for j in Board_Size.y:
		board_matrix.append(board_row.duplicate())
		destroyed_matrix.append(destroyed_row.duplicate())
	
	print(board_matrix)
		
	for piece in Prototype.get_children():
		var tile = Tilemap.local_to_map(piece.position)
		Prototype.remove_child(piece)
		
		if piece.type == Global.Type.HOLE:
			destroyed_matrix[tile.x][tile.y] = true
			continue
		
		add_child(piece)
		Global.add_piece(piece, piece.team)
		
		piece.set_tile(tile, piece.position)
		board_matrix[tile.x][tile.y] = piece
	
	Global.start_game(self)
		
		
	#print("current board: ", board_matrix)
		
func _input(_event):
	if Input.is_action_just_released("click"):
		var mouse_pos = get_local_mouse_position()
		var coords = Tilemap.local_to_map(mouse_pos)
		#print("clicked tile: ", coords)
		
		if !is_in_board(coords): # not inside board
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
			#print("current_piece: ", current_piece)
			#print("current_piece moves: ", current_piece_moves)
			
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
	
	#print(piece, " removed")
	
	board_matrix[tile.x][tile.y] = null
	remove_child(piece)
	Global.remove_piece(piece, piece.team)
	piece.queue_free()
	
func destroy_tile(tile):
	remove_piece(tile)
	destroyed_matrix[tile.x][tile.y] = true
	
	### Tilemap ###
	
	var above_tile = tile + Vector2i(0, -1)
	if !is_in_board(above_tile) || destroyed_matrix[above_tile.x][above_tile.y]: # if above tile is out of board or destroyed (half-piece)
		Tilemap.erase_cell(0, tile)
	else:
		var type_x = 2 % (above_tile.x + 1)
		Tilemap.set_cell(0, tile, 0, Vector2i(type_x, 5)) # create half-piece
	
	var below_tile = tile + Vector2i(0, 1)
	if !is_in_board(below_tile) || destroyed_matrix[below_tile.x][below_tile.y]: # if below tile is out of board or destroyed (half-piece)
		Tilemap.erase_cell(0, below_tile)
	
func is_in_board(coords):
	return (0 <= coords.x && coords.x < Board_Size.x) && (0 <= coords.y && coords.y < Board_Size.y)
			
func move_current_piece(move):
	if move in current_piece_moves:
		current_piece_moves.erase(move)
		for unused in current_piece_moves:
			destroy_tile(unused)
		
		remove_piece(move)
		board_matrix[current_piece.tile.x][current_piece.tile.y] = null
		board_matrix[move.x][move.y] = current_piece
		current_piece.set_tile(move, Tilemap.map_to_local(move))
		current_piece.stop_animate()
	
		Global.switch_teams()
		Tilemap.swap_colors()
		print(Global.current_team, " turn!")
		
func piece_select(piece):
	if !piece: return piece_deselect()
	if piece.team != Global.get_current_team(): return piece_deselect()
	
	var moves = filter_in_check_moves(piece, get_legal_moves(piece))
	if len(moves) == 0: return piece_deselect()
	
	current_piece = piece
	current_piece_moves = moves
	Global.stop_animations(piece.team)
	piece.animate("hover", 0.8)
	
func piece_deselect():
	if current_piece:
		Global.stop_animations(current_piece.team)
		Global.bounce_valid_pieces()
	current_piece_moves = []
	current_piece = null
	
func set_highlight(do_highlight):
	for tile in current_piece_moves:
		if do_highlight: Tilemap.set_cell(1, tile, 0, Vector2i(5, 3))
		else: Tilemap.erase_cell(1, tile)
	
### GET LEGAL MOVES ###

func in_check(team, matrix=board_matrix, destroyed=destroyed_matrix):
	for move in Global.get_all_legal_moves(Global.get_next_team(team), matrix, destroyed):
		#print("checked move: ", move)
		var piece = matrix[move.x][move.y]
		if piece != null && piece.type == Global.Type.KING && piece.team == team: return true
	return false

func filter_in_check_moves(piece, moves):
	var filter = moves.duplicate()
	
	for move in moves:
		var test_destroyed = destroyed_matrix.duplicate(true)
		#for other_move in moves:
		#	if other_move != move: 
		#		test_destroyed[other_move.x][other_move.y] = true
		
		var test_matrix = board_matrix.duplicate(true)
		test_matrix[piece.tile.x][piece.tile.y] = null
		test_matrix[move.x][move.y] = piece
		
		if in_check(piece.team, test_matrix, test_destroyed):
			#print("filtered: ", move)
			filter.erase(move)
		
	#print("second filter: ", moves)
	return filter

func filter_invalid_moves(piece, moves, matrix=board_matrix, destroyed=destroyed_matrix):
	var filter = moves.duplicate()
	
	for move in moves:
		if !is_in_board(move): filter.erase(move) # out of board
		elif matrix[move.x][move.y] != null && matrix[move.x][move.y].team == piece.team: filter.erase(move) # occupied by friendly piece
		elif destroyed[move.x][move.y]: filter.erase(move) #tile is destroyed
	
	return filter
	
func get_sliding_moves(piece, matrix=board_matrix, destroyed=destroyed_matrix):
	var moves = []
	for direction in piece.get_pattern():
			var i = 1
			while(true):
				var move = (direction * i) + piece.tile
				if !is_in_board(move): break # out of board
				elif matrix[move.x][move.y] != null && matrix[move.x][move.y].team == piece.team: break # occupied by friendly piece
				elif destroyed[move.x][move.y]: break #tile is destroyed
				elif matrix[move.x][move.y] != null && matrix[move.x][move.y].team != piece.team: # occupied by enemy piece
					moves.append(move)
					break
				
				moves.append(move)
				i += 1
				
	return moves
	
func get_pawn_valid_moves(piece, matrix=board_matrix, destroyed=destroyed_matrix):
	var captures = []
	for capture in piece.get_pawn_captures():
			captures.append(capture + piece.tile)
	
	
	var filter = captures.duplicate()
	for move in captures:
		if !is_in_board(move): filter.erase(move) # out of board
		elif matrix[move.x][move.y] == null || matrix[move.x][move.y].team == piece.team: filter.erase(move) # no enemy to capture
	
	var moves = []
	for move in piece.get_pattern():
		moves.append(move + piece.tile)
		
	filter.append_array(moves)
	for move in moves:
		if !is_in_board(move): filter.erase(move) # out of board
		elif matrix[move.x][move.y] != null: filter.erase(move) # occupied by piece
		elif destroyed[move.x][move.y]: filter.erase(move) #tile is destroyed
	
	return filter

func get_legal_moves(piece, matrix=board_matrix, destroyed=destroyed_matrix):
	var moves = []
	if piece.type == Global.Type.PAWN:
		return get_pawn_valid_moves(piece, matrix)
	
	if piece.sliding:
		moves = get_sliding_moves(piece, matrix, destroyed)
	else:
		for move in piece.get_pattern():
			moves.append(move + piece.tile)
		
	return filter_invalid_moves(piece, moves, matrix, destroyed)
	
