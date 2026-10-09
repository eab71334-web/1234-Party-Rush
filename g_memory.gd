extends "res://base.gd"
const EM = ["🐶", "🐱", "🦊", "🐼", "🐸", "🦁", "🐵", "🐙", "🦄", "🐯"]
var cards = []
var bs = []
var open = []
var scores = []
var lock = false
var found = 0
var moves = 0

func build() -> void:
	for i in 10:
		cards.append(EM[i])
		cards.append(EM[i])
	cards.shuffle()
	for i in players:
		scores.append(0)
	var g = center_grid(4, 14)
	for i in 20:
		var b = Games.btn("❓", Color("6c5ce7"), 150, 70)
		b.custom_minimum_size = Vector2(150, 150)
		b.pressed.connect(flip.bind(i))
		g.add_child(b)
		bs.append(b)
	refresh()

func reveal(i: int, up: bool) -> void:
	var b = bs[i]
	b.pivot_offset = b.size / 2
	var t = create_tween()
	t.tween_property(b, "scale:x", 0.0, 0.1)
	await t.finished
	b.text = cards[i] if up else "❓"
	t = create_tween()
	t.tween_property(b, "scale:x", 1.0, 0.1)
	await t.finished

func flip(i: int) -> void:
	if lock or over or open.has(i) or bs[i].disabled:
		return
	open.append(i)
	if open.size() == 2:
		lock = true
	Sound.tone(600, 0.06, 2)
	await reveal(i, true)
	if open.size() < 2:
		return
	var a = open[0]
	var b = open[1]
	moves += 1
	await get_tree().create_timer(0.7).timeout
	if cards[a] == cards[b]:
		scores[turn] += 1
		found += 1
		Sound.tone(900, 0.2, 2)
		for k in [a, b]:
			bs[k].disabled = true
			bs[k].modulate = col(turn)
	else:
		await reveal(a, false)
		await reveal(b, false)
		if players > 1:
			turn = (turn + 1) % players
	open.clear()
	lock = false
	refresh()
	if found == 10:
		if players == 1:
			finish("🎉 خلصت في %d حركة" % moves)
		else:
			var best = 0
			for i2 in players:
				if scores[i2] > scores[best]:
					best = i2
			var tie = scores.count(scores[best]) > 1
			if tie:
				finish("🤝 تعادل", Color.WHITE)
			else:
				finish("🏆 فاز " + Games.PN[best], col(best))

func refresh() -> void:
	if players == 1:
		say("🧠 الحركات: %d" % moves)
	else:
		var s = ""
		for i in players:
			s += "%d " % scores[i]
		say("دور %s  |  %s" % [Games.PN[turn], s], col(turn))
