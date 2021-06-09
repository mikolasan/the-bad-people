tool
extends Polygon2D

# https://godotengine.org/qa/3963/is-it-possible-to-have-a-polygon2d-with-outline

export(Color) var outline = Color(0,0,0) setget set_color
export(float) var width = 2.0 setget set_width

func _draw():
	var poly = get_polygon()
	for i in range(1 , poly.size()):
		draw_line(poly[i-1] , poly[i], outline , width)
	draw_line(poly[poly.size() - 1] , poly[0], outline , width)

func set_color(color):
	outline = color
	update()

func set_width(new_width):
	width = new_width
	update()
