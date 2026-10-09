extends "res://base.gd"
const EM = ["🪨", "📄", "✂️"]
var picks = [-1, -1]
var sc = [0, 0]
var stage = 0
var res: Label

func build() -> void:
	res = big_label("؟", 100)
	res.set_anchors_preset(PRESET_FULL_RECT)
	body.add_child(res)
	var row = HBoxContainer.new()
	row.set_anchors_preset(PRESET_BOTTOM_WIDE)
	row.offset_top = -230
	row.offset_bottom = -20
	row.add_theme_constant_override("separation", 18)
	body.add_child(row)
	var cs = [Color("fa8231"), Color("45aaf2"), Color("eb3b5a")]
	for k in 3:
		var b = Games.btn(EM[k], cs[k], 200, 90)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(pick.bind(k))
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
		res.text = "🙈"
		prompt()
	else:
		reveal()

func reveal() -> void:
	res.text = EM[picks[0]] + "  ضد  " + EM[picks[1]]
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
		finish("🏆 فاز " + Games.PN[w], col(w))
		return
	picks = [-1, -1]
	stage = 0
	res.text = "؟"
	prompt()
