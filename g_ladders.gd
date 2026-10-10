extends "res://base.gd"
const LAD = {2: 23, 8: 34, 20: 77, 32: 68, 41: 79, 74: 92, 82: 98}
const SNK = {27: 5, 40: 3, 43: 18, 54: 31, 66: 45, 76: 58, 89: 53, 99: 41}
var pos = []
var busy = false
var die_val = 0
var rb: Button

func build() -> void:
	for i in players:
		pos.append(1)
	canvas(paint, noop)
	rb = Games.btn(Games.L("ارمِ النرد", "Roll"), col(my_seat if online else 0), 120, 50)
	rb.set_anchors_preset(PRESET_BOTTOM_WIDE)
	rb.offset_top = -140
	rb.offset_bottom = -10
	rb.offset_left = 40
	rb.offset_right = -40
	rb.button_down.connect(press)
	body.add_child(rb)
	show_turn()

func is_busy() -> bool:
	return busy

func press() -> void:
	if over or busy or not my_turn():
		return
	act({"t": "r"})

func cell_center(n: int) -> Vector2:
	var s = minf(body.size.x - 20.0, body.size.y - 180.0)
	var ox = (body.size.x - s) / 2.0
	var oy = 10.0
	var cs = s / 10.0
	var row = (n - 1) / 10
	var c = (n - 1) % 10
	if row % 2 == 1:
		c = 9 - c
	return Vector2(ox + (c + 0.5) * cs, oy + (9 - row + 0.5) * cs)

func on_action(seat: int, _d: Dictionary) -> void:
	if over or seat != turn or busy:
		return
	do_roll()

func do_roll() -> void:
	busy = true
	var s = turn
	var v = rng.randi_range(1, 6)
	die_val = v
	Sound.tone(300 + v * 60, 0.15, 3)
	body.queue_redraw()
	if pos[s] + v <= 100:
		for k in v:
			pos[s] += 1
			Sound.tone(500 + k * 40, 0.05, 2)
			body.queue_redraw()
			if not await wait(0.2):
				return
		if LAD.has(pos[s]):
			Sound.tone(1000, 0.2, 2)
			pos[s] = LAD[pos[s]]
		elif SNK.has(pos[s]):
			Sound.lose()
			pos[s] = SNK[pos[s]]
		body.queue_redraw()
	busy = false
	if pos[s] >= 100:
		finish("فاز " + Games.PN[s], col(s))
	elif v == 6:
		say(Games.L("طلع 6! ارمِ مرة ثانية", "A six! Roll again"), col(s))
	else:
		next_turn()
	pump()

func paint() -> void:
	var f = ThemeDB.fallback_font
	var s = minf(body.size.x - 20.0, body.size.y - 180.0)
	var ox = (body.size.x - s) / 2.0
	var cs = s / 10.0
	for n in range(1, 101):
		var c = cell_center(n)
		var light = (n % 2 == 0)
		body.draw_rect(Rect2(c - Vector2(cs, cs) / 2.0, Vector2(cs, cs)), Color("e8f5e9") if light else Color("a5d6a7"))
		body.draw_string(f, c + Vector2(-cs / 2.0 + 3, -cs / 2.0 + 14), str(n), HORIZONTAL_ALIGNMENT_LEFT, cs, int(cs * 0.26), Color(0, 0, 0, 0.45))
	for a in LAD.keys():
		var p0 = cell_center(a)
		var p1 = cell_center(LAD[a])
		var nrm = (p1 - p0).orthogonal().normalized() * cs * 0.12
		body.draw_line(p0 + nrm, p1 + nrm, Color("8d6e63"), 5.0)
		body.draw_line(p0 - nrm, p1 - nrm, Color("8d6e63"), 5.0)
		for k in range(1, 6):
			var q = p0.lerp(p1, k / 6.0)
			body.draw_line(q + nrm, q - nrm, Color("a1887f"), 4.0)
	for a in SNK.keys():
		var p0 = cell_center(a)
		var p1 = cell_center(SNK[a])
		var pts = PackedVector2Array()
		var nrm = (p1 - p0).orthogonal().normalized()
		for k in 13:
			var t = k / 12.0
			pts.append(p0.lerp(p1, t) + nrm * sin(t * 9.0) * cs * 0.25)
		body.draw_polyline(pts, Color("e53935"), 8.0)
		body.draw_circle(p0, cs * 0.17, Color("b71c1c"))
	for i in players:
		var c = cell_center(pos[i]) + Vector2((i % 2) * 14 - 7, (i / 2) * 14 - 7)
		body.draw_circle(c, cs * 0.26, col(i))
		body.draw_arc(c, cs * 0.26, 0, TAU, 20, Color.WHITE, 3.0)
	if die_val > 0:
		body.draw_string(f, Vector2(0, s + 70.0), Games.L("النرد: ", "Die: ") + str(die_val), HORIZONTAL_ALIGNMENT_CENTER, body.size.x, 44, Color.WHITE)
