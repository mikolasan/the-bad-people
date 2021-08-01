extends Node2D

# Post-Modern Mondrian
# https://scratch.mit.edu/projects/115945709/editor/

var rng = RandomNumberGenerator.new()
var rooms: Array = [] # array of Room (Polygon2D)
var players = []
var player_room = -1
var room_script = preload("res://sources/Room.gd")
const v_offset = 30
const h_offset = 30
const player_info = Global.player_info
var player_names = player_info.keys()
var current_player = 0
var player_name
onready var state_machine = get_node("GameStateMachine")

# https://godotengine.org/qa/75793/how-do-i-generate-a-polygon2d-from-within-a-script
func make_room(x, y, width, height, color):
	var area = Area2D.new()
	area.position = Vector2(x, y)
	var room_id = rooms.size()
	area.connect("input_event", self, "on_room_input_event", [room_id])
	
	var poly = Polygon2D.new()
	poly.set_script(room_script)
	var x1 = 0
	var y1 = 0
	poly.set_polygon(PoolVector2Array([
		Vector2(x1, y1),
		Vector2(x1 + width, y1),
		Vector2(x1 + width, y1 + height),
		Vector2(x1, y1 + height)
	]))
	poly.color = color
	rooms.append(poly)
	area.add_child(poly)

	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.extents = Vector2(width / 2.0, height / 2.0)
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = rectangle_shape
	collision_shape.position = Vector2(width / 2.0, height / 2.0)
	area.add_child(collision_shape)

	$Rooms.add_child(area)

func mondrian(x, y, width, height, iter):
	if iter == 1:
		var r = rng.randf_range(0.0, 1.0)
		var g = rng.randf_range(0.0, 1.0)
		var b = rng.randf_range(0.0, 1.0)
		make_room(x, y, width, height, Color(r, g, b))
	else:
		var k = rng.randi_range(1, 4) / 5.0
		if width > height:
			mondrian(x, y, k * width, height, iter - 1)
			mondrian(x + k * width, y, (1 - k) * width, height, iter - 1)
		else:
			mondrian(x, y, width, k * height, iter - 1)
			mondrian(x, y + k * height, width, (1 - k) * height, iter - 1)

func random_room_id():
	return rng.randi_range(0, rooms.size() - 1)

func place_player(player, room_id):
	var random_room = rooms[room_id]
	var x = random_room.get_parent().position.x
	var y = random_room.get_parent().position.y
	var w = random_room.polygon[2].x
	var h = random_room.polygon[2].y
	player.set_position(Vector2(x + rng.randi_range(h_offset, w - h_offset), y + rng.randi_range(v_offset, h - v_offset)))
	player.room_id = room_id
	random_room.player_name = player.info.name

func get_player_room():
	return rooms[player_room]

const FLOAT_EPSILON = 0.001

static func equal_floats(a, b, epsilon = FLOAT_EPSILON):
	return abs(a - b) <= epsilon

func find_next_turn_rooms(room_id, distance):
	var next_turn = []
	var adjacent_rooms = find_adjacent_rooms(room_id)
	next_turn = adjacent_rooms.duplicate()
	for room in adjacent_rooms:
		var id = rooms.find(room)
		var next_adjacent_rooms = find_adjacent_rooms(id)
		for next_room in next_adjacent_rooms:
			if next_turn.find(next_room) == -1:
				next_turn.append(next_room)
	return next_turn

func find_adjacent_rooms(room_id):
	var adjacent_rooms = []
	var master_room = rooms[room_id]
	var master_left = master_room.get_parent().position.x
	var master_top = master_room.get_parent().position.y
	var master_right = master_left + master_room.polygon[2].x
	var master_bottom = master_top + master_room.polygon[2].y
	for room in rooms:
		if room == master_room:
			continue
		var left = room.get_parent().position.x
		var top = room.get_parent().position.y
		var right = left + room.polygon[2].x
		var bottom = top + room.polygon[2].y
		
		var same_vertical = equal_floats(left, master_right) || equal_floats(right, master_left)
		var same_horizontal = equal_floats(top, master_bottom) || equal_floats(bottom, master_top)
		if same_vertical && same_horizontal:
			continue
		var far_left = master_left > left && master_left > right
		var far_right = master_right < left && master_right < right
		var far_above = master_top > bottom && master_top > top
		var far_below = master_bottom < top && master_bottom < bottom
		if (same_vertical && !far_above && !far_below
			|| same_horizontal && !far_left && !far_right):
			adjacent_rooms.append(room)
	return adjacent_rooms

var highlight_rooms = []

func create_level():
	mondrian(0, 0, 1920, 1080, 6)

func _find(arr: Array, f: FuncRef):
	for v in arr:
		if f.call_func(v):
			return true
	return false
	
func _lambda_player_in_room(a):
	return a.player_name != null

func find_empty_room():
	var room_ids = []
	for i in range(rooms.size()):
		var player_name = rooms[i].player_name
		if player_name == null:
			room_ids.append(i)
	
	var r = rng.randi_range(0, room_ids.size() - 1)
	return room_ids[r]
#	var room_id = -1
#	while room_id == -1:
#		room_id = random_room_id()
#		var player_in_room = _find(rooms, funcref(self, "_lambda_player_in_room"))
#		if player_in_room:
#			room_id = -1
#	return room_id

func _ready():
	rng.randomize()
	create_level()

var highlight_time = 0
var max_highlight_time = 4.0

func disable_highlight():
	highlight_rooms = []
	for room in rooms:
		room.set_outline_color(Color(0.0, 0.0, 0.0))

func update_highlight_rooms(room_id):
	highlight_rooms = find_next_turn_rooms(room_id, 2)
	for room in rooms:
		room.set_outline_color(Color(0.0, 0.0, 0.0))
	for room in highlight_rooms:
		room.set_outline_color(Color(1.0, 1.0, 1.0))

func on_player_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			print("Clicked")

var card_position = Vector2()
var card_name

func on_room_input_event(viewport, event, shape_idx, room_id):
	var room = rooms[room_id]
	if event is InputEventMouseMotion and room.player_name != null:
		card_position = event.position
		card_name = room.player_name
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			# printt("Room clicked", room_id)
			if state_machine.get_param("player_turn_over"):
				return
			
			var master_room = rooms[player_room]
			if highlight_rooms.find(room) != -1:
				place_player($Player, room_id)
				disable_highlight()
				state_machine.set_param("player_turn_over", true)


func start(selected_player: String):
	player_name = selected_player
	var info = player_info[selected_player]
	$Player.info = info
	
	var foe_names = player_names.duplicate()
	foe_names.erase(player_name)
	var n_foes = foe_names.size()
	for i in range(n_foes):
		var foe = $Player.duplicate()
		foe.player_name = foe_names[i]
		foe.modulate = player_info[foe_names[i]].color
		foe.info = player_info[foe_names[i]]
		foe.info.name = foe_names[i]
		$Foes.add_child(foe)
		var room_id = find_empty_room()
		place_player(foe, room_id)
	
	$Player.player_name = selected_player
	$Player.info.name = selected_player
	$Player.modulate = info.color
	var room_id = find_empty_room()
	place_player($Player, room_id)
	update_highlight_rooms(room_id)
	$Status.text = "It's your turn now"

var ai_player

func start_ai_turn():
	ai_player = 0
	next_ai_turn()

func next_ai_turn():
	if ai_player >= $Foes.get_child_count():
		state_machine.set_param("ai_turn_over", true)
		update_highlight_rooms($Player.room_id)
		return
		
	var player = $Foes.get_child(ai_player)
	var room_id = player.room_id
	var move = player.info.move
	var next_rooms = find_next_turn_rooms(room_id, move)
	var room_ids = []
	for next_room in next_rooms:
		for i in range(rooms.size()):
			if rooms[i] == next_room:
				room_ids.append(i)
				break
	var r = rng.randi_range(0, room_ids.size() - 1)
	var next_room_id = room_ids[r]
	place_player(player, next_room_id)
	ai_player = ai_player + 1
	$Status.text = player.info.name + " takes his turn"
	$Timer.start()
	

func display_current_player():
	display_player(player_name)

func display_player(name):
	var info = player_info[name]
	$PlayerCard/Name.text = name
	var stats = """
	Move: {move}
	Energy: {energy}
	Skills:
	Equipment:
	"""
	$PlayerCard/Stats.text = stats.format({"move": info.move, "energy": info.energy})
	$PlayerCard/Avatar.set_animation(name)


func on_player_mouse_entered():
	var card_size = $PlayerCard/ColorRect.rect_size
	var p = card_position + Vector2(-(card_size.x/2.0), v_offset)
	var window_size = OS.window_size
	if p.x + card_size.x > window_size.x:
		p.x = window_size.x - card_size.x - h_offset
	elif p.x < 0:
		p.x = h_offset
	if p.y + card_size.y > window_size.y:
		p.y = card_position.y - card_size.y - v_offset
	$PlayerCard.position = p
	var players = [$Player]
	players.append_array($Foes.get_children())
	for player in players:
		if Geometry.is_point_in_circle(card_position, player.get_position(), 50):
			display_player(player.player_name)
			$PlayerCard.show()
			break


func on_player_mouse_exited():
	$PlayerCard.hide()


func on_state_machine_transited(from, to):
	match to:
		"Player":
			$Status.text = "It's your turn now"
			state_machine.set_param("player_turn_over", false)
		"AI":
			state_machine.set_param("ai_turn_over", false)
			start_ai_turn()


func on_timer_timeout():
	next_ai_turn()
