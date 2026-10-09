extends Control
var page = Control.new()

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
	l.text = Games.tx(t)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_outline_color", Color("2d1b69"))
	l.add_theme_constant_override("outline_size", 14)
	l.resized.connect(func(): l.pivot_offset = l.size / 2)
	var tw = get_tree().create_tween().set_loops()
	tw.tween_property(l, "scale", Vector2(1.05, 1.05), 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_property(l, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE)
	return l

func screen(title: String) -> VBoxContainer:
	for c in page.get_children():
		c.queue_free()
	page.modulate.a = 0.0
	get_tree().create_tween().tween_property(page, "modulate:a", 1.0, 0.25)
	var m = MarginContainer.new()
	m.set_anchors_preset(PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", 36)
	m.add_theme_constant_override("margin_right", 36)
	m.add_theme_constant_override("margin_top", Games.safe_top() + 16)
	m.add_theme_constant_override("margin_bottom", 40)
	page.add_child(m)
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 22)
	m.add_child(v)
	if title != "":
		v.add_child(title_label(title))
	return v

func spacer(v: Control) -> void:
	var s = Control.new()
	s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(s)

func note(v: Control, t: String) -> void:
	var l = Label.new()
	l.text = Games.tx(t)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 32)
	l.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	v.add_child(l)

func item(v: Control, t: String, c: Color, cb: Callable, d: float, h: int = 150) -> Button:
	var b = Games.btn(t, c, h, 52)
	b.pressed.connect(cb)
	v.add_child(b)
	Games.pop(b, d)
	return b

func back_btn(v: Control, cb: Callable) -> void:
	item(v, Games.L("رجوع", "Back"), Color("636e72"), cb, 0.3, 90)

func home() -> void:
	var v = screen("")
	var logo = Control.new()
	logo.set_script(load("res://art.gd"))
	logo.set("kind", "logo")
	logo.set("animate", true)
	logo.custom_minimum_size = Vector2(0, 300)
	v.add_child(logo)
	v.add_child(title_label("PARTY RUSH", 72))
	note(v, Games.L("20 لعبة • العب مع أصدقائك", "20 games - play with friends"))
	spacer(v)
	item(v, Games.L("العب", "PLAY"), Color("ff5d73"), local, 0.1, 170)
	item(v, Games.L("أونلاين", "ONLINE"), Color("4da3ff"), online, 0.2, 150)
	spacer(v)
	var hb = HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 28)
	v.add_child(hb)
	var g = Games.icon_btn("gear", Color("636e72"), 120)
	g.pressed.connect(settings)
	hb.add_child(g)
	var s = Games.icon_btn("snd_on" if Games.sfx_on else "snd_off", Color("636e72"), 120)
	s.pressed.connect(func():
		Games.sfx_on = not Games.sfx_on
		Games.music_on = Games.sfx_on
		Games.apply()
		Games.save_cfg()
		home())
	hb.add_child(s)
	Games.pop(g, 0.3)
	Games.pop(s, 0.4)

func local() -> void:
	var v = screen(Games.L("كم لاعب؟", "How many players?"))
	spacer(v)
	var g = GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 24)
	g.add_theme_constant_override("v_separation", 24)
	v.add_child(g)
	for i in 4:
		var b = Games.btn(str(i + 1), Games.PC[i], 280, 150)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(pick.bind(i + 1))
		g.add_child(b)
		Games.pop(b, i * 0.08)
	spacer(v)
	back_btn(v, home)

func pick(n: int) -> void:
	var v = screen(Games.L("اختر لعبة", "Pick a game"))
	var c = Control.new()
	c.set_script(load("res://carousel.gd"))
	c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(c)
	c.call("setup", Games.games_for(n))
	c.connect("chosen", func(g): launch(g, n))
	back_btn(v, local)

func row(v: Control, label: String, ctrls: Array, d: float) -> void:
	var p = PanelContainer.new()
	var sb = Games.flat(Color(1, 1, 1, 0.1), 32)
	sb.set_content_margin_all(18)
	p.add_theme_stylebox_override("panel", sb)
	var h = HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	p.add_child(h)
	var l = Label.new()
	l.text = label
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 38)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.4))
	l.add_theme_constant_override("outline_size", 8)
	h.add_child(l)
	for c in ctrls:
		h.add_child(c)
	v.add_child(p)
	Games.pop(p, d)

func opt_btn(t: String, on: bool, key: String, val) -> Button:
	var b = Games.btn(t, Color("2ed573") if on else Color("636e72"), 90, 34)
	b.custom_minimum_size = Vector2(130, 90)
	b.pressed.connect(set_opt.bind(key, val))
	return b

func set_opt(key: String, val) -> void:
	Games.set(key, val)
	Games.apply()
	Games.save_cfg()
	settings()

func settings() -> void:
	var v = screen(Games.L("الإعدادات", "Settings"))
	var on = Games.L("شغال", "ON")
	var off = Games.L("مطفي", "OFF")
	row(v, Games.L("المؤثرات الصوتية", "Sound effects"), [opt_btn(on if Games.sfx_on else off, Games.sfx_on, "sfx_on", not Games.sfx_on)], 0.0)
	row(v, Games.L("الموسيقى", "Music"), [opt_btn(on if Games.music_on else off, Games.music_on, "music_on", not Games.music_on)], 0.06)
	row(v, Games.L("اللغة", "Language"), [opt_btn("EN", Games.lang == "en", "lang", "en"), opt_btn("عربي", Games.lang == "ar", "lang", "ar")], 0.12)
	row(v, Games.L("حد الفريمات", "FPS limit"), [opt_btn("30", Games.max_fps == 30, "max_fps", 30), opt_btn("60", Games.max_fps == 60, "max_fps", 60), opt_btn("120", Games.max_fps == 120, "max_fps", 120)], 0.18)
	row(v, Games.L("إظهار عدّاد الفريمات", "Show FPS counter"), [opt_btn(on if Games.show_fps else off, Games.show_fps, "show_fps", not Games.show_fps)], 0.24)
	spacer(v)
	back_btn(v, home)

func online() -> void:
	var v = screen(Games.L("لعب جماعي", "Multiplayer"))
	note(v, Games.L("كل الأجهزة على نفس شبكة الواي فاي", "All devices on the same Wi-Fi"))
	spacer(v)
	item(v, Games.L("افتح غرفة", "Host a room"), Color("ff5d73"), host_menu, 0.1, 170)
	item(v, Games.L("انضم لغرفة", "Join a room"), Color("3ddc97"), join_menu, 0.2, 170)
	spacer(v)
	back_btn(v, home)

func host_menu() -> void:
	var v = screen(Games.L("كم لاعب؟", "How many players?"))
	spacer(v)
	for n in [2, 3, 4]:
		item(v, str(n), Games.PC[n - 1], do_host.bind(n), n * 0.05, 150)
	spacer(v)
	back_btn(v, online)

func do_host(n: int) -> void:
	Net.host(n)
	var v = screen(Games.L("الغرفة جاهزة", "Room ready"))
	spacer(v)
	var l = Label.new()
	l.text = "IP\n" + Net.my_ip()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 70)
	l.add_theme_color_override("font_color", Color.GOLD)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.5))
	l.add_theme_constant_override("outline_size", 10)
	v.add_child(l)
	note(v, Games.L("ننتظر اكتمال %d لاعبين..." % n, "Waiting for %d players..." % n))
	spacer(v)
	back_btn(v, cancel_host)

func cancel_host() -> void:
	Net.close()
	online()

func join_menu() -> void:
	var v = screen(Games.L("انضم لغرفة", "Join a room"))
	spacer(v)
	var e = LineEdit.new()
	e.placeholder_text = Games.L("اكتب IP الغرفة", "Enter room IP")
	e.alignment = HORIZONTAL_ALIGNMENT_CENTER
	e.custom_minimum_size = Vector2(0, 110)
	e.add_theme_font_size_override("font_size", 46)
	v.add_child(e)
	item(v, Games.L("دخول", "Join"), Color("3ddc97"), do_join.bind(e, v), 0.1, 130)
	spacer(v)
	back_btn(v, online)

func do_join(e: LineEdit, v: Control) -> void:
	Net.join(e.text)
	note(v, Games.L("جاري الاتصال...", "Connecting..."))

func launch(g: Array, n: int) -> void:
	Games.last = [g, n]
	for c in page.get_children():
		c.queue_free()
	page.modulate.a = 0.0
	get_tree().create_tween().tween_property(page, "modulate:a", 1.0, 0.3)
	var s = Control.new()
	s.set_script(load(g[2]))
	s.set("players", n)
	s.set_anchors_preset(PRESET_FULL_RECT)
	page.add_child(s)
