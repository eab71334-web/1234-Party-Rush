extends Control
var dots = []
var t = 0.0

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in 22:
		dots.append([randf(), randf(), randf_range(25.0, 95.0), randf_range(0.02, 0.07), randf()])

func _process(d: float) -> void:
	t += d
	for p in dots:
		p[1] -= p[3] * d
		if p[1] < -0.15:
			p[1] = 1.15
			p[0] = randf()
	queue_redraw()

func _draw() -> void:
	var top = Color("2d1b69")
	var bot = Color("0f0a2a")
	draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), size, Vector2(0, size.y)]), PackedColorArray([top, top, bot, bot]))
	for p in dots:
		var c = Color.from_hsv(fmod(p[4] + t * 0.02, 1.0), 0.5, 1.0, 0.12)
		draw_circle(Vector2(p[0] * size.x + sin(t + p[4] * 6.0) * 20.0, p[1] * size.y), p[2], c)
