extends Control

export (NodePath) var game_path
onready var game = get_node(game_path)

const player_info = Global.player_info
var player_names = player_info.keys()
var current_player = 0

func _ready():
	display_current_player()

func display_current_player():
	var player_name = player_names[current_player]
	var info = player_info[player_name]
	$Name.text = player_name
	var stats = """
	Move: {move}
	Energy: {energy}
	Skills:
	Equipment:
	"""
	$Stats.text = stats.format({"move": info.move, "energy": info.energy})
	$Avatar.set_animation(player_name)

func on_back_pressed():
	game.show_menu()

func on_play_pressed():
	var selected_player = player_names[current_player]
	game.show_level(selected_player)

func on_next_player_pressed():
	current_player = (current_player + 1) % player_names.size()
	display_current_player()

func on_previous_player_pressed():
	current_player = current_player - 1
	if current_player < 0:
		current_player = player_names.size() - 1
	display_current_player()
