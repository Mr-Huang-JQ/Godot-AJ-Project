@tool
extends Node
class_name AJEdit_Singleton

enum UIType {
	Control = 0,
	VBoxContainer = 1,
	HBoxContainer = 2,
	Button = 3,
	Label = 4,
	LineEdit = 5,
	HSplitContainer = 6,
	VSplitContainer = 7,
	ScrollContainer = 8,
}

var callable: Callable
# 获取AJ Edit单例
static func get_instance() -> AJEdit_Singleton:
	return Engine.get_singleton("AJEdit_Singleton")

# 创建UI组件
func create_control(parent: Control, type: UIType, new_name: String, info: Dictionary) -> Control:
	var _control: Control = null
	match type:
		UIType.Control:
			_control = Control.new()
		UIType.VBoxContainer:
			_control = VBoxContainer.new()
		UIType.HBoxContainer:
			_control = HBoxContainer.new()
		UIType.Button:
			_control = Button.new()
			_control.text = new_name
		UIType.Label:
			_control = Label.new()
			_control.text = new_name
		UIType.LineEdit:
			_control = LineEdit.new()
		UIType.HSplitContainer:
			_control = HSplitContainer.new()
		UIType.VSplitContainer:
			_control = VSplitContainer.new()
		UIType.ScrollContainer:
			_control = ScrollContainer.new()
	_control.name = new_name
	parent.add_child(_control)
	set_control(_control, info)
	return _control

# 设置UI组件
func set_control(control: Control, info: Dictionary) -> void:
	var edit_theme = EditorInterface.get_editor_theme()
	# 控制布局方向和文本书写方向
	if info.has("layout_direction"):
		control.layout_direction = info["layout_direction"]
	# 控制布局方向和文本书写方向
	if info.has("anchors_preset"):
		var anchors_preset = info["anchors_preset"]
		var resize_mode = 0
		var margin = 0
		if info.has("resize_mode"):
			resize_mode = info["resize_mode"]
		if info.has("margin"):
			margin = info["margin"]
		control.set_anchors_and_offsets_preset(anchors_preset, resize_mode, margin)
	# 该BOX容器子节点的对齐方式
	if info.has("alignment") && control is BoxContainer:
		control.alignment = info["alignment"]
	# 设置SplitContainer容器
	if control is SplitContainer:
		if info.has("split_offset"):
			control.split_offset = info["split_offset"]
		if info.has("collapsed"):
			control.collapsed = info["collapsed"]
		if info.has("dragger_visibility"):
			control.dragger_visibility = info["dragger_visibility"]
	# xy轴扩展和拉伸比
	if info.has("size_flags_horizontal"):
		control.size_flags_horizontal = info["size_flags_horizontal"]
	if info.has("size_flags_vertical"):
		control.size_flags_vertical = info["size_flags_vertical"]
	if info.has("size_flags_stretch_ratio"):
		control.size_flags_stretch_ratio = info["size_flags_stretch_ratio"]
	# UI最小尺寸
	if info.has("custom_minimum_size"):
		control.custom_minimum_size = info["custom_minimum_size"]
	# UI显示
	if info.has("visible"):
		control.visible = info["visible"]
	# UI鼠标点击
	if info.has("mouse_filter"):
		control.mouse_filter = info["mouse_filter"]
	# 按钮设置
	if control is Button:
		if info.has("flat"):
			control.flat = info["flat"]
		if info.has("disabled"):
			control.disabled = info["disabled"]
		if info.has("btn_group"):
			control.button_group = info["btn_group"]
		if info.has("toggle_mode"):
			control.toggle_mode = info["toggle_mode"]
		if info.has("btn_icon") && info.has("icon_type"):
			if info["btn_icon"] != "" && info["icon_type"]:
				var icon = edit_theme.get_icon(info["btn_icon"], info["icon_type"])
				control.icon = icon
		if info.has("button_alignment"):
			control.alignment = info["button_alignment"]
		if info.has("button_icon_alignment"):
			control.icon_alignment = info["button_icon_alignment"]
		if info.has("vertical_button_icon_alignment"):
			control.vertical_icon_alignment = info["vertical_button_icon_alignment"]
	# 输入框设置
	if control is LineEdit:
		if info.has("placeholder_text"):
			control.placeholder_text = info["placeholder_text"]
		if info.has("line_alignment"):
			control.alignment = info["line_alignment"]
		if info.has("max_length"):
			control.max_length = info["max_length"]
		if info.has("editable"):
			control.editable = info["editable"]
		if info.has("flat"):
			control.flat = info["flat"]
		if info.has("right_icon") && info.has("icon_type"):
			if info["right_icon"] != "" && info["icon_type"]:
				var icon = edit_theme.get_icon(info["right_icon"], info["icon_type"])
				control.right_icon = icon
		if info.has("clear_button_enabled"):
			control.clear_button_enabled = info["clear_button_enabled"]

# 获取UI容器信息
func get_container_info() -> Dictionary:
	var info = {
		"layout_direction" : Control.LAYOUT_DIRECTION_INHERITED,
		"anchors_preset" : Control.PRESET_FULL_RECT,
		"resize_mode": Control.PRESET_MODE_MINSIZE,
		"margin": 0,
		"alignment": BoxContainer.ALIGNMENT_CENTER,
		"visible": true
		# "size_flags_horizontal": Control.SIZE_EXPAND_FILL,
		# "size_flags_vertical": Control.SIZE_EXPAND_FILL,
		# "size_flags_stretch_ratio": 1,
		# "custom_minimum_size": Vector2(0, 0),
		# "split_offset": 0,
		# "collapsed": false,
		# "dragger_visibility": SplitContainer.DRAGGER_VISIBLE,
		# "mouse_filter": Control.MOUSE_FILTER_PASS
	}
	return info
# 获取按钮信息
func get_button_info() -> Dictionary:
	var info = {
		"button_pressed": false,
		"size_flags_horizontal": Control.SIZE_EXPAND_FILL,
		"btn_group": null,
		"toggle_mode": false,
		"btn_icon": "",
		"icon_type": "EditorIcons",
		"disabled": false,
		"flat": false,
		"button_alignment": HORIZONTAL_ALIGNMENT_CENTER,
		"button_icon_alignment": HORIZONTAL_ALIGNMENT_CENTER,
		"vertical_button_icon_alignment": HORIZONTAL_ALIGNMENT_CENTER,
	}
	return info
# 获取输入框信息
func get_lineedit_info() -> Dictionary:
	var info = {
		"placeholder_text": "laceholder Text",
		"size_flags_horizontal": Control.SIZE_EXPAND_FILL,
		"line_alignment": HORIZONTAL_ALIGNMENT_LEFT,
		"max_length": 0,
		"editable": true,
		"flat": false,
		"right_icon": "",
		"icon_type": "EditorIcons",
		"clear_button_enabled": false,
	}
	return info
