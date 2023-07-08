extends Node

enum Type {PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING}
enum Team {GREEN, PURPLE}

var current_team = Team.GREEN

func switch_teams():
	if current_team == Team.GREEN:
		current_team = Team.PURPLE
	else:
		current_team = Team.GREEN

func get_current_team():
	return current_team
