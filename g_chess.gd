extends "res://base.gd"
# شطرنج: لاعبين = قوانين كاملة (كش، كش مات، تبييت، أخذ بالمرور، ترقية)
# 3-4 لاعبين = لوحة صليب 14x14، أسر الملك يُخرج اللاعب
const DIRV = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const ROOK = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const DIAG = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
const KN = [Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1), Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1)]
const CN_AR = ["الأبيض", "البرتقالي", "الأسود", "الأزرق"]
const CN_EN = ["White", "Orange", "Black", "Blue"]
var TC = [Color("ffffff"), Color("ffb347"), Color("d0d0dc"), Color("6bb6ff")]
var SC = [Color("f4f4f6"), Color("ff9f1a"), Color("34343c"), Color("3b9cff")]
var BACKS = [["R", "N", "B", "Q", "K", "B", "N", "R"], ["R", "N", "B", "K", "Q", "B", "N", "R"], ["R", "N", "B", "K", "Q", "B", "N", "R"], ["R", "N", "B", "Q", "K", "B", "N", "R"]]
var S = 8
var full = true
var board = {}
var order = []
var alive = []
var cur = 0
var sel = null
var legal_moves = []
var ep = null
var lastmv = []
var checked = null
var promo = null
var promo_rects = []
var anim = null
var cell = 40.0
var ox = 0.0
var oy = 0.0

func build() -> void:
	full = players == 2
	S = 8 if full else 14
	if full:
		order = [0, 2]
	elif players == 3:
		order = [0, 1, 2]
	else:
		order = [0, 1, 2, 3]
	alive = order.duplicate()
	cur = order[0]
	var off = (S - 8) / 2
	for o in order:
		var back = BACKS[0] if full else BACKS[o]
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
			board[a] = [o, back[i], false]
			board[p] = [o, "P", false]
	canvas(paint, inp)
	announce()

func cname(o: int) -> String:
	return Games.L(CN_AR[o], CN_EN[o])

func other(o: int) -> int:
	return order[1 - order.find(o)]

func announce() -> void:
	say(Games.L("دور ", "Turn: ") + cname(cur), TC[cur])

func ok(v: Vector2i) -> bool:
	if v.x < 0 or v.y < 0 or v.x >= S or v.y >= S:
		return false
	if S == 14 and (v.x < 3 or v.x > 10) and (v.y < 3 or v.y > 10):
		return false
	return true

func add(out: Array, t: Vector2i, o: int, bd: Dictionary) -> void:
	if ok(t) and (not bd.has(t) or bd[t][0] != o):
		out.append(t)

func gen(pos: Vector2i, bd: Dictionary, att: bool = false) -> Array:
	var pc = bd[pos]
	var o = pc[0]
	var out = []
	match pc[1]:
		"P":
			var f = DIRV[o]
			var s = Vector2i(-f.y, f.x)
			if not att:
				var one = pos + f
				if ok(one) and not bd.has(one):
					out.append(one)
					var two = one + f
					if not pc[2] and ok(two) and not bd.has(two):
						out.append(two)
			for side in [s, -s]:
				var t = pos + f + side
				if not ok(t):
					continue
				if att:
					out.append(t)
				elif bd.has(t) and bd[t][0] != o:
					out.append(t)
				elif full and ep != null and t == ep and not bd.has(t):
					out.append(t)
		"N":
			for d in KN:
				add(out, pos + d, o, bd)
		"K":
			for d in ROOK + DIAG:
				add(out, pos + d, o, bd)
			if full and not att and not pc[2]:
				castle(out, pos, o, bd)
		_:
			var dirs = []
			if pc[1] != "B":
				dirs += ROOK
			if pc[1] != "R":
				dirs += DIAG
			for d in dirs:
				var t = pos + d
				while ok(t):
					if bd.has(t):
						if bd[t][0] != o:
							out.append(t)
						break
					out.append(t)
					t += d
	return out

func castle(out: Array, pos: Vector2i, o: int, bd: Dictionary) -> void:
	var en = other(o)
	var row = pos.y
	if attacked(pos, en, bd):
		return
	var rk = Vector2i(7, row)
	if bd.has(rk) and bd[rk][1] == "R" and bd[rk][0] == o and not bd[rk][2]:
		if not bd.has(Vector2i(5, row)) and not bd.has(Vector2i(6, row)):
			if not attacked(Vector2i(5, row), en, bd) and not attacked(Vector2i(6, row), en, bd):
				out.append(Vector2i(6, row))
	var rq = Vector2i(0, row)
	if bd.has(rq) and bd[rq][1] == "R" and bd[rq][0] == o and not bd[rq][2]:
		if not bd.has(Vector2i(1, row)) and not bd.has(Vector2i(2, row)) and not bd.has(Vector2i(3, row)):
			if not attacked(Vector2i(3, row), en, bd) and not attacked(Vector2i(2, row), en, bd):
				out.append(Vector2i(2, row))

func attacked(sq: Vector2i, by: int, bd: Dictionary) -> bool:
	for k in bd.keys():
		if bd[k][0] == by and gen(k, bd, true).has(sq):
			return true
	return false

func king_pos(o: int, bd: Dictionary):
	for k in bd.keys():
		if bd[k][0] == o and bd[k][1] == "K":
			return k
	return null

func legal_for(pos: Vector2i) -> Array:
	var pc = board[pos]
	if not full:
		return gen(pos, board)
	var res = []
	for d in gen(pos, board):
		var sim = board.duplicate()
		sim.erase(pos)
		if pc[1] == "P" and ep != null and d == ep and not board.has(d):
			sim.erase(Vector2i(d.x, pos.y))
		sim[d] = pc
		var kp = king_pos(pc[0], sim)
		if kp != null and not attacked(kp, other(pc[0]), sim):
			res.append(d)
	return res

func has_any_legal(o: int) -> bool:
	for k in board.keys():
		if board[k][0] == o and legal_for(k).size() > 0:
			return true
	return false

func insufficient() -> bool:
	var n = 0
	for k in board.keys():
		var tp = board[k][1]
		if tp == "K":
			continue
		if tp == "P" or tp == "R" or tp == "Q":
			return false
		n += 1
	return n <= 1

func inp(e: InputEvent) -> void:
	if over:
		return
	if not (e is InputEventMouseButton and e.pressed):
		return
	if promo != null:
		for i in promo_rects.size():
			if promo_rects[i].has_point(e.position):
				var types = ["Q", "R", "B", "N"]
				var pm = promo
				promo = null
				do_move(pm[0], pm[1], types[i])
				body.queue_redraw()
				return
		return
	var v = Vector2i(floori((e.position.x - ox) / cell), floori((e.position.y - oy) / cell))
	if not ok(v):
		return
	if sel != null and legal_moves.has(v):
		var pc = board[sel]
		if full and pc[1] == "P" and not ok(v + DIRV[pc[0]]):
			promo = [sel, v]
			sel = null
			legal_moves = []
		else:
			do_move(sel, v)
	elif board.has(v) and board[v][0] == cur:
		sel = v
		legal_moves = legal_for(v)
		Sound.tone(700, 0.05, 2)
	else:
		sel = null
		legal_moves = []
	body.queue_redraw()

func set_anim(t: float) -> void:
	if anim != null:
		anim[2] = t
	body.queue_redraw()

func end_anim() -> void:
	anim = null
	body.queue_redraw()

func do_move(a: Vector2i, b: Vector2i, ptype: String = "") -> void:
	var pc = board[a]
	var cap = board.get(b)
	if full and pc[1] == "P" and ep != null and b == ep and cap == null:
		cap = board[Vector2i(b.x, a.y)]
		board.erase(Vector2i(b.x, a.y))
	board.erase(a)
	pc[2] = true
	if full and pc[1] == "K" and absi(b.x - a.x) == 2:
		var rx = 7 if b.x > a.x else 0
		var nx = 5 if b.x > a.x else 3
		var r = board[Vector2i(rx, a.y)]
		board.erase(Vector2i(rx, a.y))
		r[2] = true
		board[Vector2i(nx, a.y)] = r
	ep = null
	if full and pc[1] == "P" and absi(b.y - a.y) == 2:
		ep = Vector2i(a.x, (a.y + b.y) / 2)
	if pc[1] == "P" and not ok(b + DIRV[pc[0]]):
		pc[1] = ptype if ptype != "" else "Q"
	board[b] = pc
	lastmv = [a, b]
	sel = null
	legal_moves = []
	anim = [a, b, 0.0]
	var tw = create_tween()
	tw.tween_method(set_anim, 0.0, 1.0, 0.2)
	tw.finished.connect(end_anim)
	if cap != null:
		Sound.tone(200, 0.2, 1)
	else:
		Sound.tone(520, 0.08, 2)
	if not full:
		if cap != null and cap[1] == "K":
			eliminate(cap[0])
		if alive.size() == 1:
			finish(Games.L("فاز ", "") + cname(alive[0]) + Games.L("!", " wins!"), Color.GOLD)
			return
		var i = order.find(cur)
		while true:
			i = (i + 1) % order.size()
			if alive.has(order[i]):
				break
		cur = order[i]
		announce()
		return
	var mover = cur
	cur = other(cur)
	checked = null
	var kp = king_pos(cur, board)
	var incheck = kp != null and attacked(kp, mover, board)
	if not has_any_legal(cur):
		if incheck:
			checked = kp
			finish(Games.L("كش مات! فاز ", "Checkmate! ") + cname(mover) + Games.L("", " wins"), Color.GOLD)
		else:
			finish(Games.L("تعادل (ستالميت)", "Stalemate - draw"), Color.WHITE)
	elif insufficient():
		finish(Games.L("تعادل (مواد غير كافية)", "Draw - insufficient material"), Color.WHITE)
	elif incheck:
		checked = kp
		say(Games.L("كش! دور ", "Check! ") + cname(cur), Color("ff6b6b"))
		Sound.tone(900, 0.15, 1)
	else:
		announce()

func eliminate(o: int) -> void:
	alive.erase(o)
	for k in board.keys():
		if board[k][0] == o:
			board.erase(k)
	Sound.lose()

func paint() -> void:
	var f = ThemeDB.fallback_font
	var m = 14.0 if full else 0.0
	cell = minf((body.size.x - m * 2.0) / S, (body.size.y - m * 2.0) / S)
	ox = (body.size.x - cell * S) / 2.0
	oy = (body.size.y - cell * S) / 2.0
	if full:
		body.draw_style_box(Games.style(Color("2a2f45"), 26, 0), Rect2(ox - 16, oy - 16, cell * S + 32, cell * S + 32))
	var light = Color("e9edf5")
	var dark = Color("8c97b0")
	for y in S:
		for x in S:
			var v = Vector2i(x, y)
			if not ok(v):
				continue
			var r = Rect2(ox + x * cell, oy + y * cell, cell, cell)
			body.draw_rect(r, light if (x + y) % 2 == 0 else dark)
			if lastmv.has(v):
				body.draw_rect(r, Color(1, 0.9, 0.2, 0.38))
			if sel != null and sel == v:
				body.draw_rect(r, Color(0.2, 1, 0.5, 0.5))
			if checked != null and checked == v:
				body.draw_circle(r.get_center(), cell * 0.55, Color(1, 0.1, 0.1, 0.55))
			if full:
				var fs = int(cell * 0.2)
				if x == 0:
					body.draw_string(f, Vector2(r.position.x + 3, r.position.y + fs + 2), str(8 - y), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.2, 0.2, 0.3, 0.7))
				if y == 7:
					body.draw_string(f, Vector2(r.position.x + cell - fs - 2, r.position.y + cell - 4), "abcdefgh".substr(x, 1), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.2, 0.2, 0.3, 0.7))
	var ps = cell * 0.95
	for k in board.keys():
		if anim != null and k == anim[1]:
			continue
		var pc = board[k]
		Games.piece(body, pc[1], Vector2(ox + (k.x + 0.5) * cell, oy + (k.y + 0.5) * cell), ps, SC[pc[0]])
	if anim != null:
		var pc2 = board[anim[1]]
		var p0 = Vector2(ox + (anim[0].x + 0.5) * cell, oy + (anim[0].y + 0.5) * cell)
		var p1 = Vector2(ox + (anim[1].x + 0.5) * cell, oy + (anim[1].y + 0.5) * cell)
		var tt = anim[2]
		tt = 1.0 - pow(1.0 - tt, 3.0)
		Games.piece(body, pc2[1], p0.lerp(p1, tt) + Vector2(0, -sin(tt * PI) * cell * 0.15), ps, SC[pc2[0]])
	for m2 in legal_moves:
		var c2 = Vector2(ox + (m2.x + 0.5) * cell, oy + (m2.y + 0.5) * cell)
		if board.has(m2) or (full and ep != null and m2 == ep and sel != null and board[sel][1] == "P"):
			body.draw_arc(c2, cell * 0.44, 0, TAU, 28, Color("ff4757"), cell * 0.07)
		else:
			body.draw_circle(c2, cell * 0.16, Color(0.1, 0.7, 0.3, 0.75))
	if promo != null:
		body.draw_rect(Rect2(Vector2.ZERO, body.size), Color(0, 0, 0, 0.65))
		var w = minf(cell * 1.3, 130.0)
		var total = 4.0 * w + 3.0 * 14.0
		var sx = (body.size.x - total) / 2.0
		var sy = body.size.y / 2.0 - w / 2.0
		promo_rects = []
		var types2 = ["Q", "R", "B", "N"]
		for i in 4:
			var rc = Rect2(sx + i * (w + 14.0), sy, w, w)
			promo_rects.append(rc)
			body.draw_style_box(Games.style(Color("4a4f6a"), 22, 6), rc)
			Games.piece(body, types2[i], rc.get_center(), w * 0.85, SC[cur])
