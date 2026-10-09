extends Control
var page = Control.new()
var ds = 0

func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var bg = Control.new()
	bg.set_script(load("res://bg.gd"))
	add_child(bg)
	page.set_anchors_preset(PRESET_FULL_RECT)
	add_child(page)
	Games.restart_req.connect(relaunch)
	Net.ready_to_start.connect(on_net)
	Sound.music()
	home()

func relaunch() -> void:
	launch(Games.last[0], Games.last[1])

func on_net(n: int) -> void:
	launch(Games.games_for(n)[0], n)

func title_label(t: String, fs: int = 62) -> Label:
	var l = Label.new()
	l.text = t
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_outline_color", Color("2d1b69"))
	l.add_theme_constant_override("outline_size", 14)
	l.resized.connect(func(): l.pivot_offset = l.size / 2)
	var tw = get_tree().create_tween().set_loops()
	tw.tween_property(l, "scale", Vector2(1.06, 1.06), 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_property(l, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE)
	return l

func screen(title: String) -> VBoxContainer:
	for c in page.get_children():
		c.queue_free()
	var m = MarginContainer.new()
	m.set_anchors_preset(PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", 36)
	m.add_theme_constant_override("margin_right", 36)
	m.add_theme_constant_override("margin_top", Games.safe_top() + 24)
	m.add_theme_constant_override("margin_bottom", 40)
	page.add_child(m)
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 22)
	m.add_child(v)
	v.add_child(title_label(title))
	return v

func spacer(v: Control) -> void:
	var s = Control.new()
	s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(s)

func note(v: Control, t: String) -> void:
	var l = Label.new()
	l.text = t
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 32)
	l.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	v.add_child(l)

func item(v: Control, t: String, c: Color, cb: Callable, d: float, h: int = 150) -> Button:
	var b = Games.btn(t, c, h, 50)
	b.pressed.connect(cb)
	v.add_child(b)
	Games.pop(b, d)
	return b

func back_btn(v: Control, cb: Callable) -> void:
	item(v, "رجوع", Color("636e72"), cb, 0.3, 90)

func home() -> void:
	var v = screen("🎮 ألعاب مصغرة")
	note(v, "20 لعبة • العب مع أصدقائك")
	spacer(v)
	item(v, "📱  نفس الشاشة", Color("ff5d73"), local, 0.1, 190)
	item(v, "🌐  لعب جماعي", Color("4da3ff"), online, 0.25, 190)
	spacer(v)
	var m = item(v, "🔊 الصوت: شغال", Color("636e72"), func(): pass, 0.4, 90)
	m.pressed.connect(func():
		Sound.music_on = not Sound.music_on
		m.text = "🔊 الصوت: شغال" if Sound.music_on else "🔇 الصوت: مطفي")

func local() -> void:
	var v = screen("كم لاعب؟")
	var g = GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 22)
	g.add_theme_constant_override("v_separation", 22)
	v.add_child(g)
	var labels = ["👤 لاعب واحد", "👥 لاعبين", "👨‍👩‍👦 3 لاعبين", "🎉 4 لاعبين"]
	for i in 4:
		var b = Games.btn(labels[i], Games.PC[i], 200, 42)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(pick.bind(i + 1))
		g.add_child(b)
		Games.pop(b, i * 0.08)
	spacer(v)
	back_btn(v, home)

func pick(n: int) -> void:
	var v = screen("اختر لعبة")
	var sc = ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(sc)
	var g = GridContainer.new()
	g.columns = 2
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	g.add_theme_constant_override("h_separation", 20)
	g.add_theme_constant_override("v_separation", 20)
	sc.add_child(g)
	var i = 0
	for game in Games.games_for(n):
		var b = Games.btn(game[0] + "\n" + game[1], Color(game[5]), 230, 40)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.button_down.connect(func(): ds = sc.scroll_vertical)
		b.pressed.connect(func():
			if absi(sc.scroll_vertical - ds) < 12:
				launch(game, n))
		g.add_child(b)
		Games.pop(b, minf(i * 0.05, 0.5))
		i += 1
	back_btn(v, local)

func online() -> void:
	var v = screen("🌐 لعب جماعي")
	note(v, "كل الأجهزة على نفس شبكة الواي فاي")
	spacer(v)
	item(v, "🏠  افتح غرفة", Color("ff5d73"), host_menu, 0.1, 170)
	item(v, "🚪  انضم لغرفة", Color("3ddc97"), join_menu, 0.2, 170)
	spacer(v)
	back_btn(v, home)

func host_menu() -> void:
	var v = screen("كم لاعب؟")
	spacer(v)
	for n in [2, 3, 4]:
		item(v, "%d لاعبين" % n, Games.PC[n - 1], do_host.bind(n), n * 0.05, 150)
	spacer(v)
	back_btn(v, online)

func do_host(n: int) -> void:
	Net.host(n)
	var v = screen("🟢 الغرفة جاهزة")
	spacer(v)
	var l = Label.new()
	l.text = "IP\n" + Net.my_ip()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 70)
	l.add_theme_color_override("font_color", Color.GOLD)
	v.add_child(l)
	note(v, "ننتظر اكتمال %d لاعبين..." % n)
	spacer(v)
	back_btn(v, func():
		Net.close()
		online())

func join_menu() -> void:
	var v = screen("🚪 انضم لغرفة")
	spacer(v)
	var e = LineEdit.new()
	e.placeholder_text = "اكتب IP الغرفة"
	e.alignment = HORIZONTAL_ALIGNMENT_CENTER
	e.custom_minimum_size = Vector2(0, 110)
	e.add_theme_font_size_override("font_size", 46)
	v.add_child(e)
	item(v, "دخول", Color("3ddc97"), do_join.bind(e, v), 0.1, 130)
	spacer(v)
	back_btn(v, online)

func do_join(e: LineEdit, v: Control) -> void:
	Net.join(e.text)
	note(v, "جاري الاتصال...")

func launch(g: Array, n: int) -> void:
	Games.last = [g, n]
	for c in page.get_children():
		c.queue_free()
	var s = Control.new()
	s.set_script(load(g[2]))
	s.set("players", n)
	s.set_anchors_preset(PRESET_FULL_RECT)
	page.add_child(s)
