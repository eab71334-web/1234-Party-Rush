extends "res://base.gd"
var vals = []
var coins = []
var lo = 0
var hi = 8
var scores = []
var info: Label

func build() -> void:
	for i in players:
		scores.append(0)
	var hb = HBoxContainer.new()
	hb.set_anchors_preset(PRESET_CENTER)
	hb.grow_horizontal = Control.GROW_DIRECTION_BOTH
	hb.grow_vertical = Control.GROW_DIRECTION_BOTH
	hb.add_theme_constant_override("separation", 8)
	body.add_child(hb)
	var sz = minf(120.0, (get_viewport_rect().size.x - 40.0) / 9.0 - 8.0)
	for i in 9:
		vals.append(rng.randi_range(1, 25))
		var b = Games.btn(str(vals[i]), Color("f1c40f"), 60, 34)
		b.custom_minimum_size = Vector2(sz, sz)
		b.button_down.connect(pick.bind(i))
		hb.add_child(b)
		coins.append(b)
	info = big_label("", 36)
	info.set_anchors_preset(PRESET_BOTTOM_WIDE)
	info.offset_top = -200
	info.offset_bottom = -20
	body.add_child(info)
	refresh()
	show_turn()

func refresh() -> void:
	var s = ""
	for i in players:
		s += "%s: %d     " % [Games.PN[i], scores[i]]
	info.text = s

func pick(i: int) -> void:
	if over or not my_turn():
		return
	if i != lo and i != hi:
		return
	act({"i": i})

func on_action(seat: int, d: Dictionary) -> void:
	if over or seat != turn:
		return
	var i = int(d.get("i", -1))
	if i != lo and i != hi:
		return
	scores[seat] += vals[i]
	coins[i].disabled = true
	coins[i].modulate.a = 0.3
	Sound.tone(600 + vals[i] * 15, 0.08, 2)
	if i == lo:
		lo += 1
	else:
		hi -= 1
	if lo > hi:
		var best = 0
		for s in players:
			if scores[s] > scores[best]:
				best = s
		if scores.count(scores[best]) > 1:
			finish(Games.L("تعادل", "Draw"), Color.WHITE)
		else:
			finish("فاز " + Games.PN[best], col(best))
	else:
		refresh()
		next_turn()
