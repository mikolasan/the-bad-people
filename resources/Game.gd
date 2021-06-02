extends Control

func _ready():
	show_menu()

func show_menu():
	$Menu.show()
	$SelectPlayer.hide()

func show_select_player():
	$Menu.hide()
	$SelectPlayer.show()
