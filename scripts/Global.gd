extends Node

enum Type {PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING, HOLE}
enum Team {GREEN, PINK}

var level_order = ["Pawns1", "Pawns2", "Knights1", "Knights2", "Rooks1", "Rooks2", "QueenBattle", "Finale"]
var current_level = 0
var last_level = -1

var already_there_honey = false

var current_board = null
var current_team = Team.PINK
var green_pieces = []
var pink_pieces = []
var UI = null

func _ready():
	Audio.play("jalapeno_jungle.mp3", "Music", true, true)

func _input(_event):
	if Input.is_action_just_pressed("restart"):
		Audio.play("reverse.wav")
		load_level(current_level)

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
	
func bounce_valid_pieces():
	if check_win():
		green_pieces[0].animate("bounce")
		pink_pieces[0].animate("bounce")
		return
	
	var at_least_one_move = false
	for piece in get_team_pieces(current_team):
		if len(current_board.filter_in_check_moves(piece, current_board.get_legal_moves(piece))) > 0:
			piece.animate("bounce")
			at_least_one_move = true
			
	if !at_least_one_move: end_game()

func check_win():
	return len(green_pieces) == 1 && len(pink_pieces) == 1

func switch_teams():
	current_team = get_next_team(current_team)
	if (current_board.in_check(current_team)):
		UI.display_message("!! king is in check !!")
	else:
		UI.clear_message()
		
	Audio.play("reverse.wav")
	UI.bg_color_shift(current_team == Team.GREEN)
	bounce_valid_pieces()
	
	if check_win():
		Audio.play("success.wav")
		current_level += 1
		UI.display_message("draw :)")
		UI.close_curtains()
		await UI.curtains_closed
		load_level(current_level)

func stop_animations(team):
	for piece in get_team_pieces(current_team):
		piece.stop_animate()

func start_game(board):
	current_team = Team.PINK
	current_board = board
	UI = get_node("/root/Level/UI")
	if current_level == last_level: UI.tutorial.text = ""
	UI.open_curtains(current_level == last_level)
	last_level = current_level
	if current_board.in_check(current_team):
		UI.display_message("!! king is in check !!")
	UI.bg_color_shift(false)
	bounce_valid_pieces()

func end_game():
	Audio.play("failure.wav")
	UI.display_message("no valid moves. press r to restart.")

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
		if matrix[piece.tile.y][piece.tile.x] == piece:
			moves.append_array(current_board.get_legal_moves(piece, matrix, destroyed))
		
	#print("all enemy legal moves: ", moves)
	return moves

func load_level(level_index):
	current_board = null
	current_team = Team.PINK
	green_pieces = []
	pink_pieces = []
	UI = null
	Audio.clear()
	get_tree().change_scene_to_file("res://scenes/levels/{0}.tscn".format([level_order[level_index]]))
	if !already_there_honey && level_order[level_index] == "QueenBattle":
		already_there_honey = true
		Audio.clear_persistent()
		Audio.play("funky_fortress.mp3", "Music", true, true)
	
	
