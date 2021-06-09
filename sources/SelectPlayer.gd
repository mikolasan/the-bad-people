extends Control

export (NodePath) var game_path
onready var game = get_node(game_path)

func on_back_pressed():
	game.show_menu()


func on_play_pressed():
	game.show_level()
