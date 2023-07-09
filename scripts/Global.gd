extends Node

enum Type {PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING, HOLE}
enum Team {GREEN, PINK}

var current_board = null
var current_team = Team.PINK
var green_pieces = []
var pink_pieces = []
var UI = null

func _ready():
	UI = get_node("/root/Level/UI")

func add_piece(piece, team):
	match team:
		Team.GREEN:
			green_pieces.append(piece)
		Team.PINK:
			pink_pieces.append(piece)

func remove_piece(piece, team):
	match team:
		Team.GREEN:
			green_pieces.erase(piece)
		Team.PINK:
			pink_pieces.erase(piece)
	check_win()

func check_win():
	if len(green_pieces) == 1 && len(pink_pieces) == 1:
		print("win!")

func switch_teams():
	current_team = get_next_team(current_team)
	UI.bg_color_shift(current_team == Team.PINK)
	for piece in get_team_pieces(current_team):
		piece.animate("bounce")

func stop_animations(team):
	for piece in get_team_pieces(current_team):
		piece.stop_animate()

func start_game(board):
	current_team = Team.PINK
	current_board = board
	UI.bg_color_shift(false)
	for piece in get_team_pieces(current_team):
		piece.animate("bounce")
	

func get_current_team():
	return current_team
	
func get_next_team(team):
	match team:
		Team.GREEN:
			return Team.PINK
		Team.PINK:
			return Team.GREEN

func get_team_pieces(team):
	match team:
		Team.GREEN:
			return green_pieces
		Team.PINK:
			return pink_pieces

func get_all_legal_moves(team, matrix=current_board.board_matrix, destroyed=current_board.destroyed_matrix):
	var moves = []
	var pieces = get_team_pieces(team)
			
	for piece in pieces:
		if matrix[piece.tile.x][piece.tile.y] == piece:
			moves.append_array(current_board.get_legal_moves(piece, matrix, destroyed))
		
	#print("all enemy legal moves: ", moves)
	return moves
	
	
