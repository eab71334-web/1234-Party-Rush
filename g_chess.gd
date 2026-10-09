extends "res://base.gd"
# شطرنج 2 / 3 / 4 لاعبين — الفوز بأسر ملك الخصم، آخر لاعب يبقى يفوز
const DIRV = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const BACK = ["R", "N", "B", "Q", "K", "B", "N", "R"]
const ROOK = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const DIAG = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
const KN = [Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1), Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1)]
var S = 8
var board = {}
var order = []
var alive = []
var cur = 0
var sel = null
var moves = []
var cell = 40.0
var ox = 0.0
var oy = 0.0

func build() -> void:
	S = 8 if players == 2 else 14
	if players == 2:
		order = [0, 2]
	elif players == 3:
		order = [0, 1, 2]
	else:
		order = [0, 1, 2, 3]
	alive = order.duplicate()
	cur = order[0]
	var off = (S - 8) / 2
	for o in order:
		for i in 8:
			var a = Vector2i(0, 0)
			var p = Vector2i(0, 0)
			match o:
				0:
					a = Vector2i(off + i, S - 1)
					p = Vector2i(off + i, S - 2)
				1:
					a = Vector2i(0, off + i)
					p = Vector2i(1, off + i)
				2:
					a = Vector2i(off + i, 0)
					p = Vector2i(off + i, 1)
				3:
					a = Vector2i(S - 1, off + i)
					p = Vector2i(S - 2, off + i)
			board[a] = [o, BACK[i], false]
			board[p] = [o, "P", false]
	canvas(paint, inp)
	announce()

func oc(o: int) -> Color:
	return Games.PC[order.find(o)]

func pname(o: int) -> String:
	return Games.PN[order.find(o)]

func announce() -> void:
	say("♟ دور " + pname(cur), oc(cur))

func ok(v: Vector2i) -> bool:
	if v.x < 0 or v.y < 0 or v.x >= S or v.y >= S:
		return false
	if S == 14 and (v.x < 3 or v.x > 10) and (v.y < 3 or v.y > 10):
		return false
	return true

func add(out: Array, t: Vector2i, o: int) -> void:
	if ok(t) and (not board.has(t) or board[t][0] != o):
		out.append(t)

func gen(pos: Vector2i) -> Array:
	var pc = board[pos]
	var o = pc[0]
	var out = []
	match pc[1]:
		"P":
			var f = DIRV[o]
			var s = Vector2i(-f.y, f.x)
			var one = pos + f
			if ok(one) and not board.has(one):
				out.append(one)
				var two = one + f
				if not pc[2] and ok(two) and not board.has(two):
					out.append(two)
			for side in [s, -s]:
				var t = pos + f + side
				if ok(t) and board.has(t) and board[t][0] != o:
					out.append(t)
		"N":
			for d in KN:
				add(out, pos + d, o)
		"K":
			for d in ROOK + DIAG:
				add(out, pos + d, o)
		_:
			var dirs = []
			if pc[1] != "B":
				dirs += ROOK
			if pc[1] != "R":
				dirs += DIAG
			for d in dirs:
				var t = pos + d
				while ok(t):
					if board.has(t):
						if board[t][0] != o:
							out.append(t)
						break
					out.append(t)
					t += d
	return out

func inp(e: InputEvent) -> void:
	if over:
		return
	if e is InputEventMouseButton and e.pressed:
		var v = Vector2i(floori((e.position.x - ox) / cell), floori((e.position.y - oy) / cell))
		if not ok(v):
			return
		if sel != null and moves.has(v):
			do_move(sel, v)
		elif board.has(v) and board[v][0] == cur:
			sel = v
			moves = gen(v)
			Sound.tone(700, 0.05, 2)
		else:
			sel = null
			moves = []
		body.queue_redraw()

func do_move(a: Vector2i, b: Vector2i) -> void:
	var pc = board[a]
	var cap = board.get(b)
	board.erase(a)
	pc[2] = true
	if pc[1] == "P" and not ok(b + DIRV[pc[0]]):
		pc[1] = "Q"
	board[b] = pc
	sel = null
	moves = []
	if cap != null:
		Sound.tone(220, 0.2, 1)
		if cap[1] == "K":
			eliminate(cap[0])
	else:
		Sound.tone(520, 0.08, 2)
	if alive.size() == 1:
		finish("🏆 فاز " + pname(alive[0]), oc(alive[0]))
	else:
		var i = order.find(cur)
		while true:
			i = (i + 1) % order.size()
			if alive.has(order[i]):
				break
		cur = order[i]
		announce()

func eliminate(o: int) -> void:
	alive.erase(o)
	for k in board.keys():
		if board[k][0] == o:
			board.erase(k)
	Sound.lose()

func paint() -> void:
	var f = ThemeDB.fallback_font
	cell = minf(body.size.x / S, body.size.y / S)
	ox = (body.size.x - cell * S) / 2.0
	oy = (body.size.y - cell * S) / 2.0
	for y in S:
		for x in S:
			var v = Vector2i(x, y)
			if not ok(v):
				continue
			var c = Color("e8d8b4") if (x + y) % 2 == 0 else Color("a67c52")
			var r = Rect2(ox + x * cell, oy + y * cell, cell, cell)
			body.draw_rect(r, c)
			if sel != null and sel == v:
				body.draw_rect(r, Color(1, 1, 0, 0.5))
	for k in board.keys():
		var pc = board[k]
		var ctr = Vector2(ox + (k.x + 0.5) * cell, oy + (k.y + 0.5) * cell)
		body.draw_circle(ctr, cell * 0.4, oc(pc[0]))
		var ring = Color.GOLD if pc[1] == "K" else Color(0, 0, 0, 0.55)
		body.draw_arc(ctr, cell * 0.4, 0, TAU, 28, ring, 3.0)
		var fs = int(cell * 0.45)
		body.draw_string(f, Vector2(ctr.x - cell / 2.0, ctr.y + fs * 0.35), pc[1], HORIZONTAL_ALIGNMENT_CENTER, cell, fs, Color.WHITE)
	for m in moves:
		var ctr2 = Vector2(ox + (m.x + 0.5) * cell, oy + (m.y + 0.5) * cell)
		if board.has(m):
			body.draw_arc(ctr2, cell * 0.45, 0, TAU, 28, Color("ff3b3b"), 5.0)
		else:
			body.draw_circle(ctr2, cell * 0.15, Color(0.1, 0.8, 0.3, 0.8))
