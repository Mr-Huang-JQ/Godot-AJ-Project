@tool
extends Control

#var tab_containers = {  }
var filters = { }
var windows = { }
var tab_select_name: String = ""
var resource_path: String
var _aj_edit_singleton: AJEdit_Singleton

func _ready() -> void:
	layout_direction = LayoutDirection.LAYOUT_DIRECTION_INHERITED
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_aj_edit_singleton = AJEdit_Singleton.get_instance()
	_create_start_container()
	# _create_main_container()
	#_aj_edit_singleton.load_autoload()
	# _aj_edit_singleton.change_autoload_name("NewName1", "NewName")
	#_aj_edit_singleton.change_autoload_sort("NewName", false)

func _exit_tree() -> void:
	queue_free()

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var _can_drop = false
	if typeof(data) == TYPE_DICTIONARY:
		if data["type"] == "files":		
			var paths = data["files"]
			if paths.size() > 0:
				var path = paths[0].to_lower()
				if tab_select_name.to_lower() == "resource":
					_can_drop = !path.containsn("cs") || !path.containsn("gd")
				elif tab_select_name.to_lower() == "scene":
					_can_drop = path.containsn("tscn")
				elif tab_select_name.to_lower() == "autoload":
					_can_drop = path.containsn("cs") || path.containsn("gd") || path.containsn("tscn")
	return _can_drop

func _drop_data(at_position: Vector2, data: Variant) -> void:
	resource_path = data["files"][0]
	if tab_select_name.to_lower() == "resource":
		windows["Add Resource"].visible = true
	elif tab_select_name.to_lower() == "scene":
		windows["Add Scene"].visible = true
	elif tab_select_name.to_lower() == "autoload":
		windows["Add Autoload"].visible = true

func _create_start_container() -> void:
	var margin_container = _create_margin_container(self, { "new_name": "StartMarginContainer" })
	var main_container = _create_box_container(margin_container, "V", { "new_name": "MainContainer", "alignment": BoxContainer.ALIGNMENT_CENTER })
	var title = _create_title(main_container, { " ": 2, "Script": 1, "  ": 2 })
	title.get_child(0).flat = true
	# title.get_child(1).disabled = true
	title.get_child(2).flat = true
	var script_container = _create_box_container(main_container, "H", { "new_name": "ChooseScriptContainer", "alignment": BoxContainer.ALIGNMENT_CENTER  })
	var script_button_group = ButtonGroup.new()
	script_button_group.resource_name = "ScriptButtonGroup"
	var gd_script = _create_button(script_container, "GD", "CheckButton", { "new_name": "gd_script", "button_group": script_button_group })
	var c_script = _create_button(script_container, "C#", "CheckButton", { "new_name": "C#", "button_group": script_button_group })
	#script_button_group.pressed.connect(func(btn):
		##print(btn.text)
		#)
	gd_script.button_pressed = true
	var create = _create_button(main_container, "Create", "", { "new_name": "Create", "size_flags_horizontal": Control.SIZE_SHRINK_CENTER })
	create.custom_minimum_size = Vector2(256, create.custom_minimum_size.y)
	var http_request = HTTPRequest.new()
	create.pressed.connect(func():
		print(script_button_group.get_pressed_button().text)
		)
	return

func _create_main_container() -> void:
	var margin_container = _create_margin_container(self)
	var main_container = _create_box_container(margin_container, "V", { "new_name": "MainContainer" })
	var tab_containers = {}
	tab_containers["Resource"] = _create_subject(null, "Resource", { "Name": 2, "Path": 2, "Tags": 2, "Global Variable": 2 }, func(x): print(x))
	tab_containers["Scene"] = _create_subject(null, "Scene", { "Name": 2, "Path": 2, "Global Variable": 1 }, func(x): print(x))
	tab_containers["Autoload"] = _create_subject(null, "Autoload", { "Name": 2, "Path": 2, "Global Variable": 1 }, func(x): print(x))
	_create_tab_container(main_container, tab_containers, func(x):print(x))
	_create_group(_get_subject(tab_containers["Resource"]), "Test")

# 在主界面插件创建MarginContainer。（中文）
# Create MarginContainer to the main screen plugin.(English)
func _create_margin_container(parent: Node, info: Dictionary = { }) -> MarginContainer:
	var margin = MarginContainer.new()
	margin.name = "MarginContainer" if !info.has("new_name") else info["new_name"]
	margin.anchor_top = 0 if !info.has("anchor_top") else info["anchor_top"]
	margin.anchor_left = 0 if !info.has("anchor_left") else info["anchor_left"]
	margin.anchor_bottom = 1 if !info.has("anchor_bottom") else info["anchor_bottom"]
	margin.anchor_right = 1 if !info.has("anchor_right") else info["anchor_right"]
	margin.offset_top = 6 if !info.has("offset_top") else info["offset_top"]
	margin.offset_left = 6 if !info.has("offset_left") else info["offset_left"]
	margin.offset_bottom = -6 if !info.has("offset_bottom") else info["offset_bottom"]
	margin.offset_right = -6 if !info.has("offset_right") else info["offset_right"]
	margin.grow_horizontal = Control.GROW_DIRECTION_BOTH if !info.has("grow_horizontal") else info["grow_horizontal"]
	margin.grow_vertical = Control.GROW_DIRECTION_BOTH if !info.has("grow_vertical") else info["grow_vertical"]
	if parent:
		parent.add_child(margin)
	return margin

# 在主界面插件创建BoxContainer。（中文）
# Create BoxContainer to the main screen plugin.(English)
func _create_box_container(parent: Node, box_class_name: String = "VBoxContainer", info: Dictionary = { }) -> BoxContainer:
	var box: BoxContainer
	if box_class_name.containsn("H") || box_class_name.containsn("HBoxContainer"):
		box = HBoxContainer.new()
		box.name = "HBoxContainer" if !info.has("new_name") else info["new_name"]
	else:
		box = VBoxContainer.new()
		box.name = "VBoxContainer" if !info.has("new_name") else info["new_name"]
	box.alignment = box.alignment if !info.has("alignment") else  info["alignment"]
	var default_size_flags_horizontal = box.size_flags_horizontal if box is VBoxContainer else Control.SIZE_EXPAND_FILL
	var default_size_flags_vertical = box.size_flags_vertical if box is HBoxContainer else Control.SIZE_EXPAND_FILL
	box.size_flags_horizontal = default_size_flags_horizontal if !info.has("size_flags_horizontal") else info["size_flags_horizontal"]
	box.size_flags_vertical = default_size_flags_vertical if !info.has("size_flags_vertical") else info["size_flags_vertical"]
	box.size_flags_stretch_ratio = box.size_flags_stretch_ratio if !info.has("size_flags_stretch_ratio") else info["size_flags_stretch_ratio"]
	if parent:
		parent.add_child(box)
	return box

# 在主界面插件创建ScrollContainer。（中文）
# Create ScrollContainer to the main screen plugin.(English)
func _create_scroll_container(parent: Node, child_class: String = "VBoxContainer", info: Dictionary = { }) -> ScrollContainer:
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer" if !info.has("new_name") else info["new_name"]
	scroll.follow_focus = scroll.follow_focus if !info.has("follow_focus") else info["follow_focus"]
	scroll.draw_focus_border = scroll.draw_focus_border if !info.has("draw_focus_border") else info["draw_focus_border"]
	scroll.scroll_deadzone = scroll.scroll_deadzone if !info.has("scroll_deadzone") else info["scroll_deadzone"]
	scroll.scroll_horizontal = scroll.scroll_horizontal if !info.has("scroll_horizontal") else info["scroll_horizontal"]
	scroll.scroll_vertical = scroll.scroll_vertical if !info.has("scroll_vertical") else info["scroll_vertical"]
	scroll.scroll_horizontal_custom_step = scroll.scroll_horizontal_custom_step if !info.has("scroll_horizontal_custom_step") else info["scroll_horizontal_custom_step"]
	scroll.scroll_vertical_custom_step = scroll.scroll_vertical if !info.has("scroll_vertical_custom_step") else info["scroll_vertical_custom_step"]
	var box = _create_box_container(scroll, child_class, { "new_name": "Container", "size_flags_vertical": Control.SIZE_EXPAND_FILL, "size_flags_horizontal": Control.SIZE_EXPAND_FILL })
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO if box is HBoxContainer else ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO if box is VBoxContainer else ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL if box is VBoxContainer else Control.SIZE_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL if box is HBoxContainer else Control.SIZE_FILL
	if parent:
		parent.add_child(scroll)
	return scroll

# 在主界面插件创建按钮。（中文）
# Create Button to the main screen plugin.(English)
func _create_button(parent: Node, button_text: String, button_class_name: String = "Button", info: Dictionary = { }, is_plugin: bool = true) -> Button:
	var button: Button
	if button_class_name == "CheckBox":
		button = CheckBox.new()
	elif button_class_name == "CheckButton":
		button = CheckButton.new()
	else:
		button = Button.new()
		button.toggle_mode = button.toggle_mode if !info.has("toggle_mode") else info["toggle_mode"]
		if info.has("icon_name") && is_plugin:
			var edit_theme = EditorInterface.get_editor_theme()
			var theme_type = "EditorIcons" if !info.has("theme_type") else info["theme_type"]
			button.icon = edit_theme.get_icon(info["icon_name"], theme_type)
	button.text = button_text
	button.name = "Button" if !info.has("new_name") else info["new_name"]
	button.flat = button.flat if !info.has("flat") else info["flat"]
	button.alignment = button.alignment if !info.has("alignment") else info["alignment"]
	button.icon_alignment = button.icon_alignment if !info.has("icon_alignment") else info["icon_alignment"]
	button.vertical_icon_alignment = button.vertical_icon_alignment if !info.has("vertical_icon_alignment") else info["vertical_icon_alignment"]
	button.size_flags_horizontal = button.size_flags_horizontal if !info.has("size_flags_horizontal") else info["size_flags_horizontal"]
	button.size_flags_vertical = button.size_flags_vertical if !info.has("size_flags_vertical") else info["size_flags_vertical"]
	button.size_flags_stretch_ratio = button.size_flags_stretch_ratio if !info.has("size_flags_stretch_ratio") else info["size_flags_stretch_ratio"]
	button.disabled = button.disabled if !info.has("disabled") else info["disabled"]
	button.button_pressed = button.button_pressed if !info.has("button_pressed") else info["button_pressed"]
	button.button_group = button.button_group if !info.has("button_group") else info["button_group"]
	button.mouse_filter = button.mouse_filter if !info.has("mouse_filter") else info["mouse_filter"]
	if parent:
		parent.add_child(button)
	return button

# 在主界面插件创建LineEdit。（中文）
# Create LineEdit to the main screen plugin.(English)
func _create_line_edit(parent: Node, placeholder_text: String, info: Dictionary = { }, is_plugin: bool = true) -> LineEdit:
	var line_edit = LineEdit.new()
	line_edit.name = "LineEdit" if !info.has("new_name") else info["new_name"]
	line_edit.placeholder_text = placeholder_text
	line_edit.alignment = line_edit.alignment if !info.has("alignment") else info["alignment"]
	line_edit.editable = line_edit.editable if !info.has("editable") else info["editable"]
	line_edit.clear_button_enabled = line_edit.clear_button_enabled if !info.has("clear_button_enabled") else info["clear_button_enabled"]
	line_edit.flat = line_edit.flat if !info.has("flat") else info["flat"]
	if info.has("icon_name") && is_plugin:
		var edit_theme = EditorInterface.get_editor_theme()
		var theme_type = "EditorIcons" if !info.has("theme_type") else info["theme_type"]
		line_edit.right_icon = edit_theme.get_icon(info["icon_name"], theme_type)
	line_edit.size_flags_horizontal = line_edit.size_flags_horizontal if !info.has("size_flags_horizontal") else info["size_flags_horizontal"]
	line_edit.size_flags_vertical = line_edit.size_flags_vertical if !info.has("size_flags_vertical") else info["size_flags_vertical"]
	line_edit.size_flags_stretch_ratio = line_edit.size_flags_stretch_ratio if !info.has("size_flags_stretch_ratio") else info["size_flags_stretch_ratio"]
	if parent:
		parent.add_child(line_edit)
	return line_edit

# 在主界面插件创建选项卡。（中文）
# Create TAB to the main screen plugin.(English)
func _create_tab_container(parent: Node, containers: Dictionary, callable: Callable) -> Container:
	var tab_button_container = _create_box_container(parent, "HBoxContainer", { "new_name": "Tab", "size_flags_vertical": Control.SIZE_FILL })
	var tab_container = _create_box_container(parent, "VBoxContainer", { "new_name": "TabContainer" })
	var tab_button_group = ButtonGroup.new()
	var tab_button_info = { "size_flags_horizontal": Control.SIZE_EXPAND_FILL, "toggle_mode": true, "button_pressed": false, "button_group": tab_button_group }
	for key in containers.keys():
		var value = containers[key] as Control
		tab_button_info["new_name"] = key + "Button"
		_create_button(tab_button_container, key, tab_button_info)
		value.visible = false
		tab_container.add_child(value)
	var tab_button_pressed = func(button):
		for key in containers.keys():
			containers[key].visible = false
		containers[button.text].visible = true
		callable.call(button.text)
	tab_button_group.pressed.connect(tab_button_pressed)
	var pressed = tab_button_group.get_buttons()[0]	
	pressed.button_pressed = true
	pressed.grab_focus()
	return

# 在主界面插件创建标题。（中文）
# Create Title to the main screen plugin.(English)
func _create_title(parent: Node, titles: Dictionary) -> Container:
	var container = _create_box_container(parent, "HBoxContainer", { "new_name": "TitleContainer",  "size_flags_vertical": Control.SIZE_FILL })
	var title_info = {"size_flags_horizontal": Control.SIZE_EXPAND_FILL, "mouse_filter": Control.MOUSE_FILTER_IGNORE}
	for key in titles.keys():
		title_info["size_flags_stretch_ratio"] = titles[key]
		title_info["new_name"] = key
		_create_button(container, key, "", title_info)
	return container

# 在主界面插件创建搜索栏。（中文）
# Create Filter to the main screen plugin.(English)
func _create_filter(parent: Node, containers: Array, refresh_callable: Callable) -> LineEdit:
	var filter_container = _create_box_container(parent, "HBoxContainer", { "new_name": "FilterContainer", "size_flags_vertical": Control.SIZE_FILL})
	var filter = _create_line_edit(filter_container, "Filter", { "size_flags_horizontal": Control.SIZE_EXPAND_FILL, "icon_name": "Search", "clear_button_enabled": true })
	var refresh = _create_button(filter_container, "Refresh", "", { "icon_name":"Reload" })
	refresh.text = ""
	var text_changed = func(txt):
		for container in containers:
			var files = container.get_children()
			for file in files:
				if file.name.containsn(txt) || txt == "" || txt == null:
					file.visible = true
				else:
					file.visible = false
	filter.text_changed.connect(text_changed)
	var pressed = func():
		filter.text = ""
		refresh_callable.call(filter.text)
	refresh.pressed.connect(pressed)
	return filter

# 在主界面插件创建主体界面。（中文）
# Create subject to the main screen plugin.(English)
func _create_subject(parent: Node, box_name: String, titles: Dictionary, refresh_callable: Callable) -> Container:
	var box_container = _create_box_container(parent, "VBoxContainer", { "new_name": box_name })
	var containers: Array
	_create_filter(box_container, containers, refresh_callable)
	_create_title(box_container, titles)
	var subject = _create_scroll_container(box_container, "VBoxContainer", { "new_name": "SubjectContainer" })
	containers.append(subject.get_child(0))
	return box_container
func _get_subject(subject: Container) -> Container:
	if subject.get_child_count() >= 3:
		return subject.get_child(2).get_child(0)
	return subject

# 在主界面插件创建新窗口。（中文）
# Create window to the main screen plugin.(English)
func _create_window(title: String) -> Window:
	var window = Window.new()
	window.name = title + "Window"
	window.title = title
	window.visible = false
	window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	window.transient = true
	window.exclusive = true
	window.size = Vector2(400, 300)
	window.close_requested.connect(func(): window.visible = false)
	var color = ColorRect.new()
	color.name = "Background"
	color.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# color.color = EditorInterface.get_editor_theme().get_color("base_color", "Editor")
	window.add_child(color)
	var container = _create_box_container(window, "V", { "new_name": "Container", "size_flags_vertical": Control.SIZE_EXPAND_FILL, "size_flags_horizontal": Control.SIZE_EXPAND_FILL })
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	self.add_child(window)
	return window

# 在主界面插件创建下拉窗。（中文）
# Create dropdown to the main screen plugin.(English)
func _create_dropdown(parent: Node) -> Button:
	var dropdown = _create_button(parent, "Dropdown",  "", { "new_name": "Dropdwon", "size_flags_horizontal": Control.SIZE_FILL, "alignment": HORIZONTAL_ALIGNMENT_LEFT, "icon_alignment": HORIZONTAL_ALIGNMENT_RIGHT })
	var popup = PopupPanel.new()
	popup.name = "OptionItems"
	dropdown.add_child(popup)
	var color = ColorRect.new()
	color.name = "Background"
	color.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color.color = EditorInterface.get_editor_theme().get_color("base_color", "Editor")
	popup.add_child(color)
	var container = _create_box_container(popup, "V", { "new_name": "Container", "size_flags_horizontal": Control.SIZE_EXPAND_FILL, "size_flags_vertical": Control.SIZE_EXPAND_FILL })
	dropdown.pressed.connect(func():
		var popup_pos = dropdown.get_screen_position()
		parent = parent as Control
		popup.size = Vector2i(196, container.get_child_count() * 32)
		var viewport_size = parent.get_viewport_rect().size
		if popup_pos.y + popup.size.y >= viewport_size.y:
			popup_pos.y = popup_pos.y - popup.size.y
		else:
			popup_pos.y = popup_pos.y + dropdown.size.y
		popup.position = popup_pos
		popup.visible = container.get_child_count() > 0)
	return dropdown
func _dropdown_add_item(dropdown: Control, item_name: String) -> void:
	if dropdown.get_child_count() <= 0:
		return
	if dropdown.get_child(0).name != "OptionItems":
		return
	var popup = dropdown.get_child(0)
	var container = popup.get_child(1)
	var item_container = _create_box_container(container, "H", { "new_name": item_name })
	var checkbox = _create_button(item_container, "",  "CheckBox", { "icon_name":"CheckBox" })
	var line = _create_line_edit(item_container, "", { "size_flags_horizontal": Control.SIZE_EXPAND_FILL })
	line.text = item_name
	var button = _create_button(item_container, "",  "", { "icon_name":"Remove" })
	button.pressed.connect(func():
		popup.visible = false
		item_container.queue_free()
		)

# 在主界面插件创建资源组。（中文）
# Create resource group to the main screen plugin.(English)
func _create_group(parent: Node, group_name: String) -> Container:
	var group_container = _create_box_container(parent, "V", { "new_name": group_name })
	var button = _create_button(group_container, group_name,  "", { "new_name": "Collapse", "alignment": HORIZONTAL_ALIGNMENT_LEFT, "icon_alignment": HORIZONTAL_ALIGNMENT_LEFT, "size_flags_horizontal": Control.SIZE_EXPAND_FILL, "icon_name":"GuiTreeArrowRight" })
	var collapse_container = _create_box_container(button, "H", { "alignment": BoxContainer.ALIGNMENT_END, "size_flags_horizontal": Control.SIZE_EXPAND_FILL })
	collapse_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	collapse_container.set_offset(SIDE_RIGHT, -5)
	var up_button = _create_button(collapse_container, "",  "", { "new_name": "Up", "icon_name": "MoveUp", "flat": true })
	var down_button = _create_button(collapse_container, "",  "", { "new_name": "Down", "icon_name": "MoveDown", "flat": true })
	var remove_button = _create_button(collapse_container, "",  "", { "new_name": "Remove", "icon_name": "Remove", "flat": true })
	var entry_count = Label.new()
	entry_count.text = str(0)
	collapse_container.add_child(entry_count)
	var expand_container = _create_box_container(group_container, "H", { "new_name": "Expand" })
	expand_container.visible = false
	button.pressed.connect(func():
		expand_container.visible = !expand_container.visible
		var edit_theme = EditorInterface.get_editor_theme()
		var theme_type = "EditorIcons"
		var icon_name = "GuiTreeArrowDown" if expand_container.visible else "GuiTreeArrowRight"
		button.icon = edit_theme.get_icon(icon_name, theme_type)
		)
	return expand_container

# 在主界面插件创建资源词条。（中文）
# Create resource entry to the main screen plugin.(English)
func _create_entry(parent: Node, entry_name: String) -> Container:
	var box_container = _create_box_container(parent, "HBoxContainer", { "new_name": entry_name })
	_create_box_container(parent, "HBoxContainer", { "new_name": entry_name })
	_create_box_container(parent, "HBoxContainer", { "new_name": entry_name })
	
	return box_container
func _create_text_entry(parent: Node, entry_name: String, text_submitted_callable: Callable, editable: bool = true) -> LineEdit:
	var box_container = _create_box_container(parent, "HBoxContainer", { "new_name": entry_name, "size_flags_vertical": Control.SIZE_FILL})
	var entry = _create_line_edit(box_container, "", { "size_flags_horizontal": Control.SIZE_EXPAND_FILL, "flat": true, "editable": editable })
	entry.text = entry_name
	var text_submitted = func(txt):
		if txt == "":
			entry.text = box_container.name
		else:
			box_container.name = entry.text
			text_submitted_callable.call(txt)
	var focus_exited = func():
		if entry.text != box_container.name:
			entry.text = box_container.name
	entry.text_submitted.connect(text_submitted)
	entry.focus_exited.connect(focus_exited)
	return entry

# 插件界面配置文件
#func _get_control_info(new_class_name: String, new_name: String, parent: Node) -> Dictionary:
	#var _info = {
		#"class_name": new_class_name,
		#"name": new_name,
		#"visible": true,
		## "clip_contents": false,
		## "custom_minimum_size": Vector2(0, 0),
		#"layout_direction" : Control.LAYOUT_DIRECTION_INHERITED,
		#"anchors_preset" : Control.PRESET_FULL_RECT,
		#"resize_mode": Control.PRESET_MODE_MINSIZE,
		#"margin": 0,
		#"size_flags_horizontal": Control.SIZE_EXPAND_FILL,
		#"size_flags_vertical": Control.SIZE_EXPAND_FILL,
		#"size_flags_stretch_ratio": 1,
		#"parent": parent,
	#}
	#return _info
#
## 插件Box容器配置文件
#enum BoxContainerType {
	#VBoxContainer = 0,
	#HBoxContainer = 1,
#}
#func _get_box_container_info(new_class: BoxContainerType, new_name: String, parent: Node) -> Dictionary:
	#var new_class_name = "VBoxContainer" if new_class == BoxContainerType.VBoxContainer else "HBoxContainer"
	#var _info = _get_control_info(new_class_name, new_name + "BoxContainer", parent)
	#_info.erase("anchors_preset")
	#_info.erase("resize_mode")
	#_info.erase("margin")
	#_info["alignment"] = BoxContainer.ALIGNMENT_BEGIN
	#return _info
#
## 插件Scroll容器配置文件
#func _get_scroll_container_info(new_name: String, parent: Node) -> Dictionary:
	#var _info = _get_control_info("ScrollContainer", new_name + "ScrollContainer", parent)
	#_info["clip_contents"] = true
	#_info["follow_focus"] = false
	#_info["horizontal_scroll_mode"] = ScrollContainer.SCROLL_MODE_DISABLED
	#_info["vertical_scroll_mode"] = ScrollContainer.SCROLL_MODE_AUTO
	#_info["scroll_deadzone"] = 0
	#_info["scroll_horizontal"] = 0
	#_info["scroll_vertical"] = 0
	#_info["scroll_horizontal_custom_step"] = -1
	#_info["scroll_vertical_custom_step"] = -1
	#return _info
#
## 插件Margin容器配置文件
#func _get_margin_container_info(new_name: String, parent: Node) -> Dictionary:
	#var _info = _get_control_info("MarginContainer", new_name + "MarginContainer", parent)
	#_info.erase("layout_direction")
	#_info.erase("anchors_preset")
	#_info.erase("resize_mode")
	#_info.erase("margin")
	#_info.erase("size_flags_horizontal")
	#_info.erase("size_flags_vertical")
	#_info.erase("size_flags_stretch_ratio")
	#_info["anchor_top"] = 0
	#_info["anchor_left"] = 0
	#_info["anchor_bottom"] = 1
	#_info["anchor_right"] = 1
	#_info["offset_top"] = 6
	#_info["offset_left"] = 6
	#_info["offset_bottom"] = -6
	#_info["offset_right"] = -6
	#_info["grow_horizontal"] = Control.GROW_DIRECTION_BOTH
	#_info["grow_vertical"] = Control.GROW_DIRECTION_BOTH
	#return _info
#
## 插件按钮配置文件
#func _get_button_info(new_name: String, parent: Node) -> Dictionary:
	#var _info = _get_control_info("Button", new_name + "Button", parent)
	#_info.erase("layout_direction")
	#_info.erase("anchors_preset")
	#_info.erase("resize_mode")
	#_info.erase("margin")
	#_info.erase("size_flags_horizontal")
	#_info.erase("size_flags_vertical")
	#_info.erase("size_flags_stretch_ratio")
	#_info["button_pressed"] = false
	#_info["button_group"] = null
	#_info["toggle_mode"] = false
	#_info["btn_icon"] = ""
	#_info["icon_type"] = "EditorIcons"
	#_info["disabled"] = false
	#_info["flat"] = false
	#_info["alignment"] = HORIZONTAL_ALIGNMENT_CENTER
	#_info["icon_alignment"] = HORIZONTAL_ALIGNMENT_CENTER
	#_info["vertical_icon_alignment"] = HORIZONTAL_ALIGNMENT_CENTER
	#_info["text"] = "Click"
	#return _info
#
## 获取输入框信息
#func _get_lineedit_info(new_name: String, parent: Node) -> Dictionary:
	#var _info = _get_control_info("LineEdit", new_name + "LineEdit", parent)
	#_info["placeholder_text"] = "laceholder Text"
	#_info["size_flags_horizontal"] = Control.SIZE_EXPAND_FILL
	#_info["alignment"] = HORIZONTAL_ALIGNMENT_LEFT
	#_info["max_length"] = 0
	#_info["editable"] = true
	#_info["flat"] = false
	#_info["right_icon"] = ""
	#_info["icon_type"] = "EditorIcons"
	#_info["clear_button_enabled"] = false
	#return _info
#
#func _get_control_property(default_value: Variant, property_key: String, control_info: Dictionary) -> Variant:
	#return control_info[property_key] if control_info.has(property_key) else default_value
#
## 创建插件界面
#func _create_control(control_info: Dictionary) -> Control:
	#var edit_theme = EditorInterface.get_editor_theme()
	#var _control = ClassDB.instantiate(control_info["class_name"]) as Control
	## 设置节点名称
	#_control.name = control_info["name"]
	## 设置节点显示
	#_control.visible = control_info["visible"]
	## 设置扩展
	#_control.size_flags_horizontal = _get_control_property(_control.size_flags_horizontal, "size_flags_horizontal", control_info)
	#_control.size_flags_vertical = _get_control_property(_control.size_flags_vertical, "size_flags_vertical", control_info)
	#_control.size_flags_stretch_ratio = _get_control_property(_control.size_flags_stretch_ratio, "size_flags_stretch_ratio", control_info)
	## 将节点添加到指定父节点里
	#control_info["parent"].add_child(_control)
	## 渲染基于 CanvasItem 的子节点时，是否应剪裁到该控件的矩形中
	#_control.clip_contents = _get_control_property(_control.clip_contents, "clip_contents", control_info)
	## 设置节点边界矩形的最小尺寸
	#_control.custom_minimum_size = _get_control_property(_control.custom_minimum_size, "custom_minimum_size", control_info)
	## 控制布局方向和文本书写方向
	#_control.layout_direction = _get_control_property(_control.layout_direction, "layout_direction", control_info)
	## 设置节点锚点和整体偏移量
	#if control_info.has("anchors_preset"):
		#var _anchors_preset = control_info["anchors_preset"]
		#var _resize_mode = _get_control_property(0, "resize_mode", control_info)
		#var _margin = _get_control_property(0, "margin", control_info)
		#_control.set_anchors_and_offsets_preset(_anchors_preset, _resize_mode, _margin)
	## 设置鼠标模式
	#_control.mouse_filter = _get_control_property(_control.mouse_filter, "mouse_filter", control_info)
	## 设置Box容器
	#if _control is BoxContainer:
		#_control = _control as BoxContainer
		#_control.alignment = _get_control_property(_control.alignment, "alignment", control_info)
	## 设置Scroll容器
	#if _control is ScrollContainer:
		#_control = _control as ScrollContainer
		#_control.follow_focus = _get_control_property(_control.follow_focus, "follow_focus", control_info)
		#_control.horizontal_scroll_mode = _get_control_property(_control.horizontal_scroll_mode, "horizontal_scroll_mode", control_info)
		#_control.vertical_scroll_mode = _get_control_property(_control.vertical_scroll_mode, "vertical_scroll_mode", control_info)
		#_control.scroll_deadzone = _get_control_property(_control.scroll_deadzone, "scroll_deadzone", control_info)
		#_control.scroll_horizontal = _get_control_property(_control.scroll_horizontal, "scroll_horizontal", control_info)
		#_control.scroll_vertical = _get_control_property(_control.scroll_vertical, "scroll_vertical", control_info)
		#_control.scroll_horizontal_custom_step = _get_control_property(_control.scroll_horizontal_custom_step, "scroll_horizontal_custom_step", control_info)
		#_control.scroll_vertical_custom_step = _get_control_property(_control.scroll_vertical_custom_step, "scroll_vertical_custom_step", control_info)
	## 设置Margin容器
	#if _control is MarginContainer:
		#_control = _control as MarginContainer
		#_control.anchor_top = _get_control_property(_control.anchor_top, "anchor_top", control_info)
		#_control.anchor_left = _get_control_property(_control.anchor_left, "anchor_left", control_info)
		#_control.anchor_bottom = _get_control_property(_control.anchor_bottom, "anchor_bottom", control_info)
		#_control.anchor_right = _get_control_property(_control.anchor_right, "anchor_right", control_info)
		#_control.offset_top = _get_control_property(_control.offset_top, "offset_top", control_info)
		#_control.offset_left = _get_control_property(_control.offset_left, "offset_left", control_info)
		#_control.offset_bottom = _get_control_property(_control.offset_bottom, "offset_bottom", control_info)
		#_control.offset_right = _get_control_property(_control.offset_right, "offset_right", control_info)
		#_control.grow_horizontal = _get_control_property(_control.grow_horizontal, "grow_horizontal", control_info)
		#_control.grow_vertical = _get_control_property(_control.grow_vertical, "grow_vertical", control_info)
	## 设置按钮
	#if _control is Button:
		#_control = _control as Button
		#_control.button_pressed = _get_control_property(_control.button_pressed, "button_pressed", control_info)
		#_control.button_group = _get_control_property(_control.button_group, "button_group", control_info)
		#_control.toggle_mode = _get_control_property(_control.toggle_mode, "toggle_mode", control_info)
		#if control_info.has("btn_icon") && control_info.has("icon_type"):
			#if control_info["btn_icon"] != "" && control_info["icon_type"] != "":
				#var _button_icon = edit_theme.get_icon(control_info["btn_icon"], control_info["icon_type"])
				#_control.icon = _button_icon
		#_control.disabled = _get_control_property(_control.disabled, "disabled", control_info)
		#_control.flat = _get_control_property(_control.flat, "flat", control_info)
		#_control.alignment = _get_control_property(_control.alignment, "alignment", control_info)
		#_control.icon_alignment = _get_control_property(_control.icon_alignment, "icon_alignment", control_info)
		#_control.vertical_icon_alignment = _get_control_property(_control.vertical_icon_alignment, "vertical_icon_alignment", control_info)
		#_control.text = _get_control_property(_control.text, "text", control_info)
	## 输入框设置
	#if _control is LineEdit:
		#_control = _control as LineEdit
		#_control.placeholder_text = _get_control_property(_control.placeholder_text, "placeholder_text", control_info)
		#_control.size_flags_horizontal = _get_control_property(_control.size_flags_horizontal, "size_flags_horizontal", control_info)
		#_control.alignment = _get_control_property(_control.alignment, "alignment", control_info)
		#_control.max_length = _get_control_property(_control.max_length, "max_length", control_info)
		#_control.editable = _get_control_property(_control.editable, "editable", control_info)
		#_control.flat = _get_control_property(_control.flat, "flat", control_info)
		#if control_info.has("right_icon") && control_info.has("icon_type"):
			#if control_info["right_icon"] != "" && control_info["icon_type"] != "":
				#var _icon = edit_theme.get_icon(control_info["right_icon"], control_info["icon_type"])
				#_control.right_icon = _icon
		#_control.clear_button_enabled = _get_control_property(_control.clear_button_enabled, "clear_button_enabled", control_info)
	#return _control
#
## 创建插件主界面
#func _create_main_container() -> void:
	#var _margin_info = _get_margin_container_info("", self)
	#var _margin_container = _create_control(_margin_info) as MarginContainer
	#var _box_info = _get_box_container_info(BoxContainerType.VBoxContainer, "Main", _margin_container)
	#_box_info["anchors_preset"] = Control.PRESET_FULL_RECT
	#_box_info["margin"] = 10
	#var _main_container = _create_control(_box_info)
	#_main_container.set_offset(SIDE_TOP, 5)
	#_box_info["margin"] = 0
	#_box_info["parent"] = _main_container
	## 选项卡按钮容器
	#_box_info["class_name"] = "HBoxContainer"
	#_box_info["anchors_preset"] = Control.PRESET_TOP_WIDE
	#_box_info.erase("anchors_preset")
	#_box_info.erase("size_flags_vertical")
	#_box_info.erase("size_flags_horizontal")
	#var _tab_button_container = _create_control(_box_info)
	#var _tab_containers = { }
	#_tab_containers["Resource"] = null
	#_tab_containers["Scene"] = null
	#_tab_containers["Autoload"] = null
	#var _tab_button_group = ButtonGroup.new()
	#var _button_info = _get_button_info("", _tab_button_container)
	#_button_info["toggle_mode"] = true
	#_button_info["button_group"] = _tab_button_group
	#_button_info["size_flags_horizontal"] = Control.SIZE_EXPAND_FILL
	#for key in _tab_containers.keys():
		#_button_info["name"] = key
		#_button_info["text"] = key
		#var _button = _create_control(_button_info)
		#print(key, ":", _button.size)
	#var _tab_button_pressed = func(button):
		#for key in _tab_containers.keys():
			#_tab_containers[key].visible = false
		#_tab_containers[button.text].visible = true
		#tab_select_name = button.text
	#_tab_button_group.pressed.connect(_tab_button_pressed)
	##_tab_button_container.set_anchors_preset(Control.PRESET_TOP_WIDE)
	##_tab_button_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	## 选项卡容器
	#_box_info["class_name"] = "VBoxContainer"
	#_box_info["anchors_preset"] = Control.PRESET_BOTTOM_WIDE
	##_box_info["size_flags_vertical"] = Control.SIZE_EXPAND_FILL
	#var _tab_panel_container = _create_control(_box_info)
	##_tab_panel_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	##_tab_button_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	## 添加选项卡
	##_box_info = _get_box_container_info(BoxContainerType.VBoxContainer, "", _tab_panel_container)
	##_box_info["visible"] = false
	##_box_info["size_flags_vertical"] = Control.SIZE_EXPAND_FILL
	##_box_info["anchors_preset"] = Control.PRESET_FULL_RECT
	##_tab_containers["Resource"] = _create_resource_container(_box_info)
	##_tab_containers["Scene"] = _create_scene_container(_box_info)
	##_tab_containers["Autoload"] = _create_autoload_container(_box_info)
	##_tab_button_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	##_tab_button_group.get_buttons()[0].button_pressed = true
	##_tab_button_group.get_buttons()[0].grab_focus()
	#print("margin:", _margin_container.size)
	#print("main:", _main_container.size)
	#print("tab_button:", _tab_button_container.size)
	#print("tab_panel:", _tab_panel_container.size)
#
## 创建资源加载界面
#func _create_resource_container(_box_info: Dictionary) -> Container:
	#_box_info["name"] = "Resource"
	#var _resource_container = _create_control(_box_info) as VBoxContainer
	#var _search_line: LineEdit
	#var _resource_filter = func(new_text):
		#print(new_text)
	#var _resource_pressed = func():
		#print("Resource")
	#_search_line = _create_filter(_resource_container, _resource_filter, _resource_pressed)
	#_create_title(_resource_container, ["*Name", "Path", "*Global Variable"])
	#return _resource_container
	##var _container_info = singleton.get_container_info()
	##_container_info["size_flags_vertical"] = Control.SIZE_EXPAND_FILL
	##var _resource_container = singleton.create_control(parent, AJEdit_Singleton.UIType.VBoxContainer, "Resource", _container_info)
	##tab_containers[_resource_container.name] = _resource_container
	##var _resource_filter = func(new_text):
		##print(new_text)
	##var _resource_pressed = func():
		##filters["resource"].text = ""
	##var _search_line = _create_filter(singleton, _resource_container, _resource_filter, _resource_pressed)
	##filters["resource"] = _search_line
	###_create_title(singleton, _autoload_container, ["Name", "Path", "Global Variable"])
	##var subject = _create_subject(singleton, _resource_container)
	##var _window = _create_add_window(singleton, self, "Add Resource")
	#
#
## 创建场景加载界面
#func _create_scene_container(_box_info: Dictionary) -> Container:
	#_box_info["name"] = "Scene"
	#var _scene_container = _create_control(_box_info) as VBoxContainer
	#var _search_line: LineEdit
	#var _scene_filter = func(new_text):
		#print(new_text)
	#var _scene_pressed = func():
		#print("Scene")
	#_search_line = _create_filter(_scene_container, _scene_filter, _scene_pressed)
	#_create_title(_scene_container, ["*Name", "Path", "*Global Variable"])
	#return _scene_container
	##var _container_info = singleton.get_container_info()
	##_container_info["size_flags_vertical"] = Control.SIZE_EXPAND_FILL
	##var _scene_container = singleton.create_control(parent, AJEdit_Singleton.UIType.VBoxContainer, "Scene", _container_info)
	##tab_containers[_scene_container.name] = _scene_container
	##var _scene_filter = func(new_text):
		##print(new_text)
	##var _scene_pressed = func():
		##filters["scene"].text = ""
	##var _search_line = _create_filter(singleton, _scene_container, _scene_filter, _scene_pressed)
	##filters["scene"] = _search_line
	###_create_title(singleton, _autoload_container, ["Name", "Path", "Global Variable"])
	##var subject = _create_subject(singleton, _scene_container)
	##var _window = _create_add_window(singleton, self, "Add Scene")
	#
#
## 创建自动加载界面
#func _create_autoload_container(_box_info: Dictionary) -> Container:
	#_box_info["name"] = "Autoload"
	#var _autoload_container = _create_control(_box_info) as VBoxContainer
	#var _search_line: LineEdit
	#var _autoload_filter = func(new_text):
		#print(new_text)
	#var _autoload_pressed = func():
		#print("Autoload")
	#_search_line = _create_filter(_autoload_container, _autoload_filter, _autoload_pressed)
	#_create_title(_autoload_container, ["*Name", "Path", "*Global Variable"])
	#var _subject_container = _create_subject(_autoload_container)
	#for key in ["Name", "Path", "Global Variable"]:
		#var btn = Button.new()	
		#btn.name = key
		#btn.text = key
		#_subject_container.add_child(btn)
		#btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#return _autoload_container
	##var _container_info = singleton.get_container_info()
	##_container_info["size_flags_vertical"] = Control.SIZE_EXPAND_FILL
	##var _autoload_container = singleton.create_control(parent, AJEdit_Singleton.UIType.VBoxContainer, "Autoload", _container_info)
	##tab_containers[_autoload_container.name] = _autoload_container
	##var _autoload_filter = func(new_text):
		##print(new_text)
	##var _autoload_pressed = func():
		##filters["autoload"].text = ""
	##var _search_line = _create_filter(singleton, _autoload_container, _autoload_filter, _autoload_pressed)
	##filters["autoload"] = _search_line
	##_create_title(singleton, _autoload_container, ["Name", "Path", "*Global Variable"])
	##var _subject = _create_subject(singleton, _autoload_container)
	##var _window = _create_add_window(singleton, self, "Add Autoload")
	##var path_input = _create_input_field(singleton, _window.get_child(1), "Path")
	##path_input.editable = false
	##var name_input = _create_input_field(singleton, _window.get_child(1), "Name")
	##var add_button = singleton.create_control(_window.get_child(1), AJEdit_Singleton.UIType.Button, "Add Autoload", {})
	##var _window_visibility_changed = func():
		##path_input.text = resource_path
		##name_input.text = ""
	##if !_window.visibility_changed.is_connected(_window_visibility_changed):
		##_window.visibility_changed.connect(_window_visibility_changed)
	##_create_autoload_item(singleton, _subject, "Test", "res://", 0)
	##_create_autoload_item(singleton, _subject, "Test1", "res://", 1)
#
## 创建自动加载词条
#func _create_autoload_item(singleton: AJEdit_Singleton, parent: Control, autoload_name: String, autoload_path: String, sort_index: int) -> Control:
	#var _container_info = singleton.get_container_info()
	#_container_info["size_flags_vertical"] = Control.SIZE_EXPAND_FILL
	#_container_info["size_flags_horizontal"] = Control.SIZE_EXPAND_FILL
	#var _container = singleton.create_control(parent, AJEdit_Singleton.UIType.HBoxContainer, autoload_name + "Container", _container_info)
	#var _line_info = singleton.get_lineedit_info()
	#_line_info["flat"] = true
	#var _name_field = singleton.create_control(_container, AJEdit_Singleton.UIType.LineEdit, "Name", _line_info)
	#_name_field.text = autoload_name
	#var _button_info = singleton.get_button_info()
	#_button_info["flat"] = true
	#var _path_field = singleton.create_control(_container, AJEdit_Singleton.UIType.Button, "Path", _button_info)
	#_path_field.text = autoload_path
	#_container_info["size_flags_stretch_ratio"] = 0.3
	#var _variable = singleton.create_control(_container, AJEdit_Singleton.UIType.HBoxContainer, "Variable", _container_info)
	#_container_info["size_flags_stretch_ratio"] = 1
	#var _enble_container = singleton.create_control(_variable, AJEdit_Singleton.UIType.HSplitContainer, "EnbleContainer", _container_info)
	#var _enble_box = CheckBox.new()
	#_enble_box.name = "EnbleButton"
	#_enble_container.add_child(_enble_box)
	#var _enble_label = singleton.create_control(_enble_container, AJEdit_Singleton.UIType.Label, "Enble", _button_info)
	#_enble_label.text = "Enble"
	#_button_info["btn_icon"] = "Folder"
	#var _open_btn = singleton.create_control(_variable, AJEdit_Singleton.UIType.Button, "open", _button_info)
	#_open_btn.text = ""
	#_button_info["btn_icon"] = "MoveUp"
	#var _up_btn = singleton.create_control(_variable, AJEdit_Singleton.UIType.Button, "up", _button_info)
	#_up_btn.text = ""
	#_button_info["btn_icon"] = "MoveDown"
	#var _down_btn = singleton.create_control(_variable, AJEdit_Singleton.UIType.Button, "down", _button_info)
	#_down_btn.text = ""
	#_button_info["btn_icon"] = "Remove"
	#var _remove_btn = singleton.create_control(_variable, AJEdit_Singleton.UIType.Button, "remove", _button_info)
	#_remove_btn.text = ""
	#var _sort = singleton.create_control(_variable, AJEdit_Singleton.UIType.Label, "sort", _button_info)
	#_sort.text = str(sort_index)
	#return null
#
## 创建标题栏
#func _create_title(parent: Control, title_names: Array[String]) -> void:
	#var _container_info = _get_box_container_info(BoxContainerType.HBoxContainer, "Title", parent)
	#_container_info["size_flags_horizontal"] = Control.SIZE_EXPAND_FILL
	#var _title_container = _create_control(_container_info)
	#var _title_info = _get_button_info("", _title_container)
	#_title_info["mouse_filter"] = Control.MOUSE_FILTER_IGNORE
	#_title_info["size_flags_horizontal"] = Control.SIZE_EXPAND_FILL
	#for name in title_names:
		#_title_info["name"] = name
		#_title_info["size_flags_stretch_ratio"] = 1 if name.contains("*") else 2
		#var title = _create_control(_title_info)
		#title.text = name.split("*")[1] if name.contains("*") else name
#
## 创建搜索栏
#func _create_filter(parent: Control, search_callback: Callable, pressed_callback: Callable) -> LineEdit:
	#var _filter_info = _get_box_container_info(BoxContainerType.HBoxContainer, "Filter", parent)
	#_filter_info["anchors_preset"] = Control.PRESET_CENTER_TOP
	#_filter_info["size_flags_horizontal"] = Control.SIZE_EXPAND_FILL
	#var _filter_container = _create_control(_filter_info)
	#var _line_info = _get_lineedit_info("Fileter", _filter_container)
	#_line_info["placeholder_text"] = "Filter"
	#_line_info["right_icon"] = "Search"
	#_line_info["clear_button_enabled"] = true
	#var _search_line = _create_control(_line_info) as LineEdit
	#if !_search_line.text_changed.is_connected(search_callback):
		#_search_line.text_changed.connect(search_callback)
	#var _refresh_info = _get_button_info("Refresh", _filter_container)
	#_refresh_info["btn_icon"] = "Reload"
	#_refresh_info.erase("size_flags_horizontal")
	#var _refresh_btn = _create_control(_refresh_info) as Button
	#_refresh_btn.text = ""
	#if !_refresh_btn.pressed.is_connected(pressed_callback):
		#_search_line.text = ""
		#_refresh_btn.pressed.connect(pressed_callback)
	#return _search_line
#
## 创建资源主体容器
#func _create_subject(parent: Control) -> Container:
	#var _scroll_info = _get_scroll_container_info("Subject", parent)
	## _scroll_info["horizontal_scroll_mode"] = ScrollContainer.SCROLL_MODE_DISABLED
	#var _scroll_container = _create_control(_scroll_info) as ScrollContainer
	## _scroll_container.custom_minimum_size = parent.size
	## _scroll_info.erase("size_flags_vertical")
	#_scroll_info.erase("clip_contents")
	#var _subject_container = _create_control(_scroll_info)
	## _scroll_container.custom_minimum_size = parent.size
	#return _subject_container
#
## 创建输入框
#func _create_input_field(singleton: AJEdit_Singleton, parent: Control, field_name: String) -> LineEdit:
	#var _input_info = singleton.get_container_info()
	#_input_info["size_flags_horizontal"] = Control.SIZE_EXPAND_FILL
	#_input_info["split_offset"] = 0
	#_input_info["collapsed"] = true
	#_input_info["dragger_visibility"] = SplitContainer.DRAGGER_VISIBLE
	#var _input_container = singleton.create_control(parent, AJEdit_Singleton.UIType.HSplitContainer, field_name + "Container", _input_info)
	#var _label = singleton.create_control(_input_container, AJEdit_Singleton.UIType.Label, field_name + "Label", {})
	#_label.text = field_name + ":"
	#var _line_info = singleton.get_lineedit_info()
	#_line_info["placeholder_text"] = ""
	#var _input_line = singleton.create_control(_input_container, AJEdit_Singleton.UIType.LineEdit, field_name, _line_info)
	#return _input_line
#
## 创建新建资源窗口
#func _create_add_window(singleton: AJEdit_Singleton, parent: Control, title: String) -> Window:
	#var _window = Window.new()
	#parent.add_child(_window)
	#_window.title = title
	#_window.visible = false
	#_window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	#_window.transient = true
	#_window.exclusive = true
	#_window.size = Vector2(400, 300)
	#windows[title] = _window
	#var _close_window = func():
		#windows[title].visible = false
	#if !_window.close_requested.is_connected(_close_window):
		#_window.close_requested.connect(_close_window)
	#var _container_info = singleton.get_container_info()
	#_container_info["set_anchors_and_offsets_preset"] = Control.PRESET_FULL_RECT
	#_container_info["size_flags_vertical"] = Control.SIZE_EXPAND_FILL
	#_container_info["size_flags_horizontal"] = Control.SIZE_EXPAND_FILL
	#var _color_background = singleton.create_control(null, AJEdit_Singleton.UIType.ColorRect, "ColorBackground", {})
	#_window.add_child(_color_background)
	#singleton.set_control(_color_background, _container_info)
	#_color_background.color = EditorInterface.get_editor_theme().get_color("base_color", "Editor")
	#var _container = singleton.create_control(null, AJEdit_Singleton.UIType.VBoxContainer, "Create", {})
	#_window.add_child(_container)
	#_container_info["margin"] = 5
	##_container_info["alignment"] = BoxContainer.ALIGNMENT_CENTER
	#singleton.set_control(_container, _container_info)
	#return _window
