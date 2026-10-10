extends "res://race.gd"
var lane = 1
var obs = []
var spawn_t = 0.0
var acc = 0.0

func setup() -> void:
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.draw.connect(paint)
	area.gui_input.connect(inp)

func hint_text() -> String:
	return Games.L("اضغط يمين أو يسار لتغيير المسار", "Tap left/right to switch lanes")

func inp(e: InputEvent) -> void:
	if running and e is InputEventMouseButton and e.pressed:
		if e.position.x < area.size.x / 2.0:
			lane = maxi(0, lane - 1)
		else:
			lane = mini(2, lane + 1)
		Sound.tone(500, 0.04, 2)

func tick(d: float) -> void:
	acc += d
	while acc >= 0.1:
		acc -= 0.1
		add(1)
	spawn_t -= d
	if spawn_t <= 0.0:
		spawn_t = maxf(0.35, 0.8 - (DURATION - time_left) * 0.012)
		obs.append([rng.randi() % 3, -60.0])
	var py = area.size.y - 140.0
	var keep = []
	for o in obs:
		o[1] += (420.0 + (DURATION - time_left) * 9.0) * d
		if o[0] == lane and absf(o[1] - py) < 60.0:
			Sound.lose()
			end_round()
			return
		if o[1] < area.size.y + 80.0:
			keep.append(o)
	obs = keep
	area.queue_redraw()

func lane_x(i: int) -> float:
	return area.size.x * (i + 0.5) / 3.0

func paint() -> void:
	for i in 3:
		area.draw_rect(Rect2(area.size.x * i / 3.0 + 6, 0, area.size.x / 3.0 - 12, area.size.y), Color(1, 1, 1, 0.07))
	for o in obs:
		area.draw_style_box(Games.flat(Color("ff4757"), 18), Rect2(lane_x(o[0]) - 60, o[1] - 40, 120, 80))
	var py = area.size.y - 140.0
	Games.glyph(area, 12, Vector2(lane_x(lane), py), 46.0, Color("2ed573"))
