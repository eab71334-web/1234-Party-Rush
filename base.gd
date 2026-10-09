extends Control
var players = 2
var turn = 0
var over = false
var status = Label.new()
var body = Control.new()
var st = 60

func _ready() -> void:
	st = Games.safe_top()
	body.set_anchors_preset(PRESET_FULL_RECT)
	body.offset_top = st + 120
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(body)
	status.set_anchors_preset(PRESET_TOP_WIDE)
	status.offset_top = st
	status.offset_bottom = st + 90
	status.offset_left = 130
	status.offset_right = -30
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 38)
	status.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	status.add_theme_constant_override("outline_size", 8)
	add_child(status)
	Games.back(self)
	build()

func build() -> void:
	pass

func wait(t: float) -> bool:
	await get_tree().create_timer(t).timeout
	return is_inside_tree()

func col(i: int) -> Color:
	return Games.PC[i % 4]

func say(t: String, c: Color = Color.WHITE) -> void:
	status.text = t
	status.add_theme_color_override("font_color", c)

func show_turn() -> void:
	say("دور " + Games.PN[turn], col(turn))

func next_turn() -> void:
	turn = (turn + 1) % players
	show_turn()

func canvas(painter: Callable, inputter: Callable) -> void:
	body.mouse_filter = Control.MOUSE_FILTER_STOP
	body.draw.connect(painter)
	body.gui_input.connect(inputter)
	body.resized.connect(body.queue_redraw)

func finish(t: String, c: Color = Color.GOLD) -> void:
	if over:
		return
	over = true
	say(t, c)
	Sound.win()
	confetti(Vector2(size.x / 2, size.y * 0.85))
	var b = Games.btn("🔁 مرة ثانية", Color("00b894"), 110, 42)
	b.set_anchors_preset(PRESET_CENTER_BOTTOM)
	b.offset_left = -220
	b.offset_right = 220
	b.offset_top = -170
	b.offset_bottom = -50
	b.pressed.connect(func(): Games.restart_req.emit())
	add_child(b)
	Games.pop(b)

func confetti(pos: Vector2) -> void:
	var p = CPUParticles2D.new()
	p.position = pos
	p.amount = 90
	p.one_shot = true
	p.explosiveness = 1.0
	p.lifetime = 2.2
	p.direction = Vector2(0, -1)
	p.spread = 70.0
	p.initial_velocity_min = 500.0
	p.initial_velocity_max = 900.0
	p.gravity = Vector2(0, 1100)
	p.scale_amount_min = 8.0
	p.scale_amount_max = 16.0
	var g = Gradient.new()
	g.colors = PackedColorArray([Color("ff5d73"), Color("4da3ff"), Color("3ddc97"), Color("ffc93c")])
	g.offsets = PackedFloat32Array([0.0, 0.33, 0.66, 1.0])
	p.color_initial_ramp = g
	add_child(p)
	p.emitting = true

func pad(cb: Callable) -> GridContainer:
	var g = GridContainer.new()
	g.columns = 3
	g.add_theme_constant_override("h_separation", 14)
	g.add_theme_constant_override("v_separation", 14)
	for k in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "حذف", "0", "تم"]:
		var c = Color("6c5ce7")
		if k == "تم":
			c = Color("00b894")
		elif k == "حذف":
			c = Color("e17055")
		var b = Games.btn(k, c, 110, 48)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(cb.bind(k))
		g.add_child(b)
	return g

func spacer(v: Control) -> void:
	var s = Control.new()
	s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(s)

func big_label(t: String, fs: int, c: Color = Color.WHITE) -> Label:
	var l = Label.new()
	l.text = t
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", c)
	return l

func center_grid(cols: int, gap: int = 14) -> GridContainer:
	var g = GridContainer.new()
	g.columns = cols
	g.add_theme_constant_override("h_separation", gap)
	g.add_theme_constant_override("v_separation", gap)
	g.set_anchors_preset(PRESET_CENTER)
	g.grow_horizontal = Control.GROW_DIRECTION_BOTH
	g.grow_vertical = Control.GROW_DIRECTION_BOTH
	body.add_child(g)
	return g
