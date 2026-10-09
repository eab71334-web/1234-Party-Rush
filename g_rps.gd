extends "res://base.gd"
var picks = [-1, -1]
var sc = [0, 0]
var stage = 0
var show_l: Control
var show_r: Control
var q: Label

func mk(kind: String) -> Control:
	var a = Control.new()
	a.set_script(load("res://art.gd"))
	a.set("kind", kind)
	return a

func build() -> void:
	var hb = HBoxContainer.new()
	hb.set_anchors_preset(PRESET_FULL_RECT)
	hb.offset_bottom = -260
	hb.add_theme_constant_override("separation", 10)
	body.add_child(hb)
	show_l = mk("rps_hand")
	show_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	show_l.size_flags_vertical = Control.SIZE_EXPAND_FILL
	show_r = mk("rps_hand")
	show_r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	show_r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hb.add_child(show_l)
	hb.add_child(show_r)
	var row = HBoxContainer.new()
	row.set_anchors_preset(PRESET_BOTTOM_WIDE)
	row.offset_top = -230
	row.offset_bottom = -20
	row.add_theme_constant_override("separation", 18)
	body.add_child(row)
	var cs = [Color("fa8231"), Color("45aaf2"), Color("eb3b5a")]
	var ks = ["rps_rock", "rps_paper", "rps_scissors"]
	for k in 3:
		var b = Games.btn("", cs[k], 200, 90)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(pick.bind(k))
		var a = mk(ks[k])
		a.set_anchors_preset(Control.PRESET_FULL_RECT)
		b.add_child(a)
		row.add_child(b)
	prompt()

func prompt() -> void:
	say("%s اختر (سرّي!)   %d : %d" % [Games.PN[stage], sc[0], sc[1]], col(stage))

func pick(k: int) -> void:
	if over or stage > 1:
		return
	picks[stage] = k
	stage += 1
	if stage == 1:
		show_l.set("kind", "rps_hidden")
		prompt()
	else:
		reveal()

func reveal() -> void:
	var names = ["rps_rock", "rps_paper", "rps_scissors"]
	show_l.set("kind", names[picks[0]])
	show_r.set("kind", names[picks[1]])
	show_l.queue_redraw()
	show_r.queue_redraw()
	var r = (picks[0] - picks[1] + 3) % 3
	if r == 1:
		sc[0] += 1
		say("فاز " + Games.PN[0], col(0))
	elif r == 2:
		sc[1] += 1
		say("فاز " + Games.PN[1], col(1))
	else:
		say("تعادل", Color.WHITE)
	Sound.tone(600, 0.2, 2)
	stage = 2
	if not await wait(1.8):
		return
	if sc[0] >= 2 or sc[1] >= 2:
		var w = 0 if sc[0] >= 2 else 1
		finish("فاز " + Games.PN[w], col(w))
		return
	picks = [-1, -1]
	stage = 0
	show_l.set("kind", "rps_hidden")
	show_r.set("kind", "rps_hidden")
	prompt()
