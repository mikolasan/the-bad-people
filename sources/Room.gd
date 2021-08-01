tool
extends Polygon2D

# https://godotengine.org/qa/3963/is-it-possible-to-have-a-polygon2d-with-outline

export(Color) var outline = Color(0,0,0) setget set_outline_color
export(float) var width = 4.0 setget set_outline_width

var room_id
var player_name

func _draw():
	var poly = get_polygon()
	var o = width / 2.0
	draw_line(poly[0] + Vector2(o, o), poly[1] + Vector2(-o, o), outline , width)
	draw_line(poly[1] + Vector2(-o, o), poly[2] + Vector2(-o, -o), outline , width)
	draw_line(poly[2] + Vector2(-o, -o), poly[3] + Vector2(o, -o), outline , width)
	draw_line(poly[3] + Vector2(o, -o), poly[0] + Vector2(o, o), outline , width)

func set_outline_color(color):
	outline = color
	update()

func set_outline_width(new_width):
	width = new_width
	update()
