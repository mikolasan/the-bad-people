extends Control

func _ready():
	show_menu()

func show_menu():
	$Menu.show()
	$SelectPlayer.hide()
	$Level.hide()

func show_select_player():
	$Menu.hide()
	$SelectPlayer.show()
	$Level.hide()

func show_level():
	$Menu.hide()
	$SelectPlayer.hide()
	$Level.show()
