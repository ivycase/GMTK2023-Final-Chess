extends Node

enum Type {PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING}
enum Team {GREEN, PINK}

var current_team = Team.PINK
var green_pieces = []
var pink_pieces = []

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
	if len(green_pieces == 1) && len(pink_pieces == 1):
		print("win!")

func switch_teams():
	match current_team:
		Team.GREEN:
			current_team = Team.PINK
		Team.PINK:
			current_team = Team.GREEN

func get_current_team():
	return current_team