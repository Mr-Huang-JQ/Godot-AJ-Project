@tool
extends EditorPlugin

var _main_panel
var _singleton

func _enter_tree() -> void:
	_singleton = _singleton if _singleton != null else _create_singleton("AJEdit_Singleton", "res://addons/aj_plugin/aj_edit_singleton.gd")
	_singleton.add_autoload_singleton = func(n,p): add_autoload_singleton(n, p)
	_singleton.remove_autoload_singleton = func(n): remove_autoload_singleton(n)
	_main_panel = _main_panel if _main_panel != null else _create_main_plugin()
	EditorInterface.get_editor_main_screen().add_child(_main_panel)
	_make_visible(false)

func _exit_tree() -> void:
	if _main_panel:
		_main_panel.queue_free()
	Engine.unregister_singleton("AJEdit_Singleton")

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if _main_panel:
		_main_panel.visible = visible

func _get_plugin_name() -> String:
	return "AJ Manager"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("GDScript", "EditorIcons")

# 创建插件单例
func _create_singleton(singleton_name: String, singleton_path: String) -> Node:
	var _singleton = Node.new()
	_singleton.set_script(load(singleton_path))
	if !Engine.has_singleton(singleton_name):
		Engine.register_singleton(singleton_name, _singleton)
	return _singleton

# 创建自定义主界面插件
func _create_main_plugin() -> Control:
	var _control = Control.new()
	_control.name = "main_panel"
	_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_control.set_script(load("res://addons/aj_plugin/aj_edit_main_panel.gd"))
	return _control
