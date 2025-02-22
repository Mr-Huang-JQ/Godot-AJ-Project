@tool
extends EditorPlugin

var main_panel
var singleton

func _enter_tree() -> void:
	if !singleton:
		singleton = Node.new()
		singleton.set_script(load("res://addons/aj_plugin/aj_edit_singleton.gd"))
		if !Engine.has_singleton("AJEdit_Singleton"):
			Engine.register_singleton("AJEdit_Singleton", singleton)
		singleton.callable = callable
	if !main_panel:
		main_panel = Control.new()
		main_panel.set_script(load("res://addons/aj_plugin/aj_edit_main_panel.gd"))
		EditorInterface.get_editor_main_screen().add_child(main_panel)
	_make_visible(false)

func callable(call) -> void:
	print("Call:", call)

func _exit_tree() -> void:
	if main_panel:
		main_panel.queue_free()
	Engine.unregister_singleton("AJEdit_Singleton")

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if main_panel:
		main_panel.visible = visible

func _get_plugin_name() -> String:
	return "AJ Manager"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("GDScript", "EditorIcons")
