extends CanvasLayer

const Design := preload("res://scripts/ui/design.gd")
var _previous_pause := false
var _previous_focus: Control
var _status: Label
var _confirmation: Control
var _confirm_cancel: Button
var _privacy: Control
var _privacy_back: Button
var _main: Control
var _page: MarginContainer
var _reset_button: Button
var _controls: Dictionary = {}
var _closing := false

func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_previous_pause = get_tree().paused
	_previous_focus = get_viewport().gui_get_focus_owner()
	get_tree().paused = true
	_main = Control.new()
	_main.theme = Design.theme()
	add_child(_main)
	_main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Design.INK
	_main.add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	_page = Design.margin(_main, 20)
	_page.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var back := Design.button("← Voltar", go_back)
	header.add_child(back)
	var title := Design.label("Configurações", 22)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	content.add_child(Design.label("APARÊNCIA", 12, Design.MINT))
	var appearance_help := Design.label("Escolha a identidade visual. Os temas minimalistas removem as cores e os detalhes do fundo.", 12, Design.MUTED)
	appearance_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(appearance_help)
	_theme_choice(content, "Original · cores atuais", 0)
	_theme_choice(content, "Minimalista escuro · preto e branco", 1)
	_theme_choice(content, "Minimalista claro · branco e preto", 2)
	content.add_child(Design.label("ÁUDIO", 12, Design.MINT))
	_toggle(content, "Silenciar tudo", "muted")
	_volume(content, "Volume geral", "master_volume")
	_toggle(content, "Música", "music_enabled")
	_volume(content, "Volume da música", "music_volume")
	_toggle(content, "Efeitos sonoros", "sfx_enabled")
	_volume(content, "Volume dos efeitos", "sfx_volume")
	content.add_child(Design.button("Ouvir efeito de teste", func() -> void: Feedback.play_sound("win")))
	content.add_child(Design.label("TOQUE", 12, Design.MINT))
	_toggle(content, "Vibração", "vibration_enabled")
	var haptics := Design.label("Vibração disponível em aparelhos Android compatíveis.", 12, Design.MUTED)
	haptics.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(haptics)
	content.add_child(Design.label("SOBRE", 12, Design.MINT))
	content.add_child(Design.button("Privacidade e dados", _show_privacy))
	var version := Design.label("VERTICAL  ·  versão %s" % ProjectSettings.get_setting("application/config/version", "1.0.0"), 12, Design.MUTED)
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(version)
	content.add_child(Design.label("PROGRESSO", 12, Design.CORAL))
	_reset_button = Design.button("Reiniciar meu progresso…", _ask_reset)
	_reset_button.add_theme_color_override("font_color", Design.CORAL)
	content.add_child(_reset_button)
	_status = Design.label("Alterações salvas automaticamente.", 12, Design.MUTED)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_status)
	_build_confirmation()
	_build_privacy()
	back.grab_focus()


func _theme_choice(parent: Node, _title: String, theme_index: int) -> void:
	var button := Design.button("", func() -> void:
		_commit("visual_theme", theme_index)
		_refresh_theme_buttons())
	parent.add_child(button)
	_controls["theme_%d" % theme_index] = button
	_refresh_theme_buttons()


func _refresh_theme_buttons() -> void:
	var selected := int(SaveManager.settings.get("visual_theme", 0))
	var titles := [
		"Original · cores atuais",
		"Minimalista escuro · preto e branco",
		"Minimalista claro · branco e preto",
	]
	for index in range(titles.size()):
		var button := _controls.get("theme_%d" % index) as Button
		if button != null:
			button.text = ("●  " if selected == index else "○  ") + titles[index]

func _toggle(parent: Node, title: String, key: String) -> void:
	var toggle := Design.button("", func() -> void: pass)
	toggle.toggle_mode = true
	toggle.set_pressed_no_signal(bool(SaveManager.settings[key]))
	toggle.text = title + (": ligado" if toggle.button_pressed else ": desligado")
	toggle.toggled.connect(func(value: bool) -> void:
		_commit(key, value)
		toggle.set_pressed_no_signal(bool(SaveManager.settings[key]))
		toggle.text = title + (": ligado" if toggle.button_pressed else ": desligado"))
	parent.add_child(toggle)
	_controls[key] = toggle

func _volume(parent: Node, title: String, key: String) -> void:
	var label := Design.label(title + "  ·  %d%%" % roundi(float(SaveManager.settings[key]) * 100), 13, Design.MUTED)
	parent.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = float(SaveManager.settings[key]) * 100
	slider.custom_minimum_size = Vector2(0, 44)
	slider.scrollable = false
	var track := Design.thin_bar(Design.EDGE)
	track.content_margin_top = 2
	track.content_margin_bottom = 2
	var fill := Design.thin_bar(Design.MINT)
	fill.content_margin_top = 2
	fill.content_margin_bottom = 2
	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)
	slider.value_changed.connect(func(value: float) -> void:
		_commit(key, value / 100.0)
		slider.set_value_no_signal(float(SaveManager.settings[key]) * 100)
		label.text = title + "  ·  %d%%" % roundi(slider.value))
	parent.add_child(slider)
	_controls[key] = slider

func _commit(key: String, value: Variant) -> void:
	var success := SaveManager.set_setting(key, value)
	_status.text = "Alterações salvas automaticamente." if success else "Não foi possível salvar. A alteração foi desfeita."
	_status.add_theme_color_override("font_color", Design.MUTED if success else Design.CORAL)

func _build_confirmation() -> void:
	var overlay := ColorRect.new()
	_confirmation = overlay
	overlay.color = Color(0.02, 0.04, 0.07, 0.97)
	_main.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var card := PanelContainer.new()
	card.custom_minimum_size.x = 312
	center.add_child(card)
	var column := VBoxContainer.new()
	card.add_child(column)
	column.add_child(Design.label("Começar do zero?", 24, Design.CORAL))
	var explanation := Design.label("Todas as fases concluídas, medalhas, recordes e skins de recompensa serão apagados. Apenas a skin clássica e a fase 1 ficarão disponíveis.\n\nSuas configurações de áudio e aparência serão mantidas. Esta ação não pode ser desfeita.", 15)
	explanation.custom_minimum_size.x = 275
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(explanation)
	_confirm_cancel = Design.button("Cancelar e manter progresso", _cancel_reset, true)
	column.add_child(_confirm_cancel)
	var erase := Design.button("Sim, apagar meu progresso", _confirm_reset)
	erase.add_theme_color_override("font_color", Design.CORAL)
	column.add_child(erase)
	_confirmation.hide()

func _build_privacy() -> void:
	var overlay := ColorRect.new()
	_privacy = overlay
	overlay.color = Design.INK
	_main.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var page := Design.margin(overlay, 20)
	var column := VBoxContainer.new()
	page.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	_privacy_back = Design.button("← Voltar", _hide_privacy)
	header.add_child(_privacy_back)
	var title := Design.label("Privacidade", 22)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var text := Design.label("VERTICAL funciona sem conta e sem conexão com a internet.\n\nO jogo não coleta, transmite, vende nem compartilha dados pessoais. Progresso, recordes, preferências, estatísticas e skins ficam somente no aparelho. Esses dados podem ser apagados em ‘Reiniciar meu progresso’ ou ao desinstalar o jogo.\n\nA vibração é usada apenas como resposta tátil durante a partida e pode ser desativada. O jogo não contém anúncios, compras, rastreadores ou serviços de análise.\n\nPublicador: Vertical Jump.\nContato: pedrobonini.dev@gmail.com\n\nÚltima atualização: 23 de setembro de 2026.", 14)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(text)
	_privacy.hide()

func _show_privacy() -> void:
	_page.hide()
	_privacy.show()
	_privacy_back.grab_focus()

func _hide_privacy() -> void:
	_privacy.hide()
	_page.show()

func _ask_reset() -> void:
	_page.hide()
	_confirmation.show()
	_confirm_cancel.grab_focus()

func _cancel_reset() -> void:
	_confirmation.hide()
	_page.show()
	_reset_button.grab_focus()

func _confirm_reset() -> void:
	if not _confirmation.visible or _closing:
		return
	if not SaveManager.reset_progress():
		_cancel_reset()
		_status.text = "Não foi possível salvar. Seu progresso foi mantido."
		return
	_close()
	Feedback.change_scene("res://scenes/ui/MainMenu.tscn")

func go_back() -> void:
	if _privacy.visible:
		_hide_privacy()
	elif _confirmation.visible:
		_cancel_reset()
	else:
		_close()

func _close() -> void:
	if _closing:
		return
	_closing = true
	get_tree().paused = _previous_pause
	if is_instance_valid(_previous_focus):
		_previous_focus.grab_focus()
	queue_free()
