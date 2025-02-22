@tool
extends Control

var tab_containers = {  }
var filters = { }
#var tab_button_group: ButtonGroup
#var edit_theme: Theme

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#AJEdit_Singleton.get_instance().callable.call("Load")
	#edit_theme = EditorInterface.get_editor_theme()
	layout_direction = LayoutDirection.LAYOUT_DIRECTION_INHERITED
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var _singleton = AJEdit_Singleton.get_instance()
	_create_main_container(_singleton) 
# 创建插件主界面
func _create_main_container(singleton: AJEdit_Singleton) -> void:
	var _container_info = singleton.get_container_info()
	_container_info["margin"] = 10
	var _main_container = singleton.create_control(self, AJEdit_Singleton.UIType.VBoxContainer, "MainContainer", _container_info)
	_main_container.set_offset(SIDE_TOP, 5)
	# 选项卡按钮容器
	var _tab_button_container = singleton.create_control(_main_container, AJEdit_Singleton.UIType.HBoxContainer, "TabContainer", _container_info)
	# 选项卡容器
	var _tab_panel_container = singleton.create_control(_main_container, AJEdit_Singleton.UIType.VBoxContainer, "PanelContainer", _container_info)
	# 添加选项卡
	_create_resource_container(singleton, _tab_panel_container)
	_create_scene_container(singleton, _tab_panel_container)
	_create_autoload_container(singleton, _tab_panel_container)
	var _button_info = singleton.get_button_info()
	var tab_button_group = ButtonGroup.new()
	if !tab_button_group.pressed.is_connected(_tab_button_pressed):
		tab_button_group.pressed.connect(_tab_button_pressed)
	_button_info["btn_group"] = tab_button_group
	_button_info["toggle_mode"] = true
	var btb = Button.new()
	for key in tab_containers.keys():
		var btn = singleton.create_control(_tab_button_container, AJEdit_Singleton.UIType.Button, key, _button_info)
	tab_button_group.get_buttons()[0].button_pressed = true
	tab_button_group.get_buttons()[0].grab_focus()
# 选项卡切换
func _tab_button_pressed(button: BaseButton) -> void:
	for key in tab_containers.keys():
		tab_containers[key].visible = false
	tab_containers[button.text].visible = true
# 创建资源加载界面
func _create_resource_container(singleton: AJEdit_Singleton, parent: Control) -> void:
	var _container_info = singleton.get_container_info()
	_container_info["size_flags_vertical"] = Control.SIZE_EXPAND_FILL
	var _resource_container = singleton.create_control(parent, AJEdit_Singleton.UIType.VBoxContainer, "Resource", _container_info)
	tab_containers[_resource_container.name] = _resource_container
	var _resource_filter = func(new_text):
		print(new_text)
	var _resource_pressed = func():
		filters["Resource"].text = ""
	var _search_line = _create_filter(singleton, _resource_container, _resource_filter, _resource_pressed)
	filters["Resource"] = _search_line
	#_create_title(singleton, _autoload_container, ["Name", "Path", "Global Variable"])
# 创建场景加载界面
func _create_scene_container(singleton: AJEdit_Singleton, parent: Control) -> void:
	var _container_info = singleton.get_container_info()
	_container_info["size_flags_vertical"] = Control.SIZE_EXPAND_FILL
	var _scene_container = singleton.create_control(parent, AJEdit_Singleton.UIType.VBoxContainer, "Scene", _container_info)
	tab_containers[_scene_container.name] = _scene_container
	var _scene_filter = func(new_text):
		print(new_text)
	var _scene_pressed = func():
		filters["Scene"].text = ""
	var _search_line = _create_filter(singleton, _scene_container, _scene_filter, _scene_pressed)
	filters["Scene"] = _search_line
	#_create_title(singleton, _autoload_container, ["Name", "Path", "Global Variable"])
# 创建自动加载界面
func _create_autoload_container(singleton: AJEdit_Singleton, parent: Control) -> void:
	var _container_info = singleton.get_container_info()
	_container_info["size_flags_vertical"] = Control.SIZE_EXPAND_FILL
	var _autoload_container = singleton.create_control(parent, AJEdit_Singleton.UIType.VBoxContainer, "Autoload", _container_info)
	tab_containers[_autoload_container.name] = _autoload_container
	var _autoload_filter = func(new_text):
		print(new_text)
	var _autoload_pressed = func():
		filters["autoload"].text = ""
	var _search_line = _create_filter(singleton, _autoload_container, _autoload_filter, _autoload_pressed)
	filters["autoload"] = _search_line
	_create_title(singleton, _autoload_container, ["Name", "Path", "Global Variable"])
# 创建标题栏
func _create_title(singleton: AJEdit_Singleton, parent: Control, title_names: Array[String]) -> void:
	var _container_info = singleton.get_container_info()
	_container_info["size_flags_vertical"] = Control.SIZE_EXPAND_FILL
	var title_container = singleton.create_control(parent, AJEdit_Singleton.UIType.HBoxContainer, "Title", _container_info)
	var _title_info = singleton.get_button_info()
	_title_info["mouse_filter"] = Control.MOUSE_FILTER_IGNORE
	for name in title_names:
		var title = singleton.create_control(title_container, AJEdit_Singleton.UIType.Button, name, _title_info)
# 创建搜索栏
func _create_filter(singleton: AJEdit_Singleton, parent: Control, search_callback: Callable, pressed_callback: Callable) -> LineEdit:
	var _filter_info = singleton.get_container_info()
	_filter_info["size_flags_horizontal"] = Control.SIZE_EXPAND_FILL
	_filter_info["split_offset"] = 0
	_filter_info["collapsed"] = true
	_filter_info["dragger_visibility"] = SplitContainer.DRAGGER_VISIBLE
	var _filter_container = singleton.create_control(parent, AJEdit_Singleton.UIType.HSplitContainer, "FilterContainer", _filter_info)
	var _search_container = singleton.create_control(_filter_container, AJEdit_Singleton.UIType.HBoxContainer, "SearchContainer", _filter_info)
	var _line_info = singleton.get_lineedit_info()
	_line_info["placeholder_text"] = "Filter"
	_line_info["right_icon"] = "Search"
	_line_info["clear_button_enabled"] = true
	var _search_line = singleton.create_control(_search_container, AJEdit_Singleton.UIType.LineEdit, "Search", _line_info)
	if !_search_line.text_changed.is_connected(search_callback):
		_search_line.text_changed.connect(search_callback)
	var _refresh_info = singleton.get_button_info()
	_refresh_info["btn_icon"] = "Reload"
	_refresh_info.erase("size_flags_horizontal")
	var _refresh_btn = singleton.create_control(_filter_container, AJEdit_Singleton.UIType.Button, "Refresh", _refresh_info)
	_refresh_btn.text = ""
	if !_refresh_btn.pressed.is_connected(pressed_callback):
		_refresh_btn.pressed.connect(pressed_callback)
	return _search_line
