extends Node

var is_player_dead: bool = false
var player_score: int = 0


func reset_game_state():
	is_player_dead = false
	player_score = 0
