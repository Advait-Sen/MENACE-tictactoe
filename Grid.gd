extends GridContainer


@export var buttons: ButtonGroup
@export var nought_texture : Texture2D
@export var cross_texture : Texture2D

var game: Game

var replay_button : TextureButton
var ai_button : TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	game = Game.new() #Initialising game with node
	
	for i in 9:
		buttons.get_buttons()[i].pressed.connect(_on_button_pressed.bind(i))
	
	replay_button = get_node(".").get_parent().get_child(1)
	# Might have to rework this if it interferes with MENACE
	replay_button.pressed.connect(get_tree().reload_current_scene)
	replay_button.set_texture_normal(nought_texture if game.turn else cross_texture)
	ai_button = get_node(".").get_parent().get_child(2)


func _on_button_pressed(index:int):
	var button:TextureButton = buttons.get_buttons()[index]
	
	button.set_texture_normal(nought_texture if game.turn else cross_texture)
	button.set_texture_hover(null)
	button.disabled = true
	
	game.make_move(index)
	
	
	replay_button.set_texture_normal(nought_texture if game.turn else cross_texture)
	
	if game.game_over: #TODO better endgame graphics
		for b in buttons.get_buttons():
			b.disabled = true

#AI stuff

#TODO remove alpha beta stuff, since it unnecessarily complicates things
# TODO redo whole minimax code, essentially
func minimax(node:Game, alpha:int, beta:int, maximiser:bool)->int:
	
	if node.game_over:
		#0 for tie, -1 for cross victory, 1 for nought victory
		return -1 if node.winner == 2 else 1
	
	var value
	
	if maximiser:
		value = -1500
		
		for child in node.generate_children():
			var eval = minimax(child, alpha, beta, false)
			value = max(value, eval)
			alpha = max(alpha, eval)
			if beta <= alpha:
				break

	else:
		value = 1500

		for child in node.generate_children():
			var eval = minimax(child, alpha, beta, true)
			value = min(value, eval)
			beta = min(beta, eval)
			if beta <= alpha:
				break
	
	return value

func _on_ai_button_pressed():
	if game.game_over:
		return
	
	#Don't wanna waste time calculating first move, it's gonna be on one of the corners
	if game.turn_count==0:
		_on_button_pressed([0, 2, 6, 8].pick_random())
		return

	var children = game.generate_children()
	var best_move = -1
	var best_eval = -1000 if game.turn else 1000
	var start_time:float = Time.get_ticks_usec()
	
	
	for child in children:
		var eval = minimax(child, -1000, 1000, !game.turn)
		if (game.turn and best_eval <= eval) or (!game.turn and best_eval >= eval):
			best_eval = eval
			best_move = child.move


	var end_time:float = Time.get_ticks_usec()
	
	print((end_time-start_time)/1000, " ms")
	print("Best move:", best_move)
	
	_on_button_pressed(best_move)

