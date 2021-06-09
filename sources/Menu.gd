extends Control

export (NodePath) var game_path
onready var game = get_node(game_path)

func on_start_pressed():
	game.show_select_player()

func on_exit_pressed():
	get_tree().quit()
