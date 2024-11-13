## Class which stores all information about a TicTacToe game.
## It manages making moves, verifying a winner, as well as generating child games for minimax search
class_name Game

## Triples of cells which need to be filled in for this to be counted as a victory
const triples = [
	[0, 1, 2],
	[3, 4 ,5],
	[6, 7, 8],
	[0, 3, 6],
	[1, 4, 7],
	[2, 5, 8],
	[0, 4, 8],
	[2, 4, 6],
]


var state:Array[int] = [
	0, 0, 0,
	0, 0, 0,
	0, 0, 0
]

var turn = false # Always start with crosses (false), for simplicity. Might change to be random value on initialisation later
var turn_count:int = 0 # Turn number
var game_over = false
var winner = 0 # 0 means no winner yet, or a tie if the game is over. 1 for noughts, 2 for crosses
var move = -1 # The move used to reach this child

func _init(_state=[], _turn = false, _move = -1):
	if !_state.is_empty():
		self.state = _state.duplicate(true)
		self.turn = _turn
		self.move = _move
		
		if _move != -1: # Reached here using this move, so make sure it's been made
			make_move(_move)

func make_move(index:int):
	# If that move has already been made, or game is over, ignore
	if state[index] or game_over:
		return
	
	var p = 1 if turn else 2 # Player who made a move this turn
	
	state[index] = p
	turn = !turn
	turn_count += 1

	for t in triples:
		var w = state[t[0]] #Check for possible winner
		
		if w != p: #Cell is not a nought during nought turn, or a cross turing cross turn
			continue
		
		if w==state[t[1]] and w==state[t[2]]: # Found a winner, return
			game_over = true
			winner = w
			return
	
	#Check for tie
	if not game_over and state.min() > 0:
		# There are no empty cells (0s) left, so min is 1 or 2
		game_over = true

	pass

# Helper functions for AI

func valid_moves(): # Indices at which the cell is empty
	return range(9).filter(func(x): return state[x]==0)

func generate_children():
	var children = []
	
	for _move in valid_moves():
		var child = Game.new(state, turn, _move)
		children.append(child)
	
	return children

