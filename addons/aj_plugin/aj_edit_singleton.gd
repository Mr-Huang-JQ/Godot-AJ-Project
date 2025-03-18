@tool
extends Node
class_name AJEdit_Singleton
var add_autoload_singleton: Callable
var remove_autoload_singleton: Callable

# 获取AJ Edit单例。（中文）
# Get AJ Edit singleton.(English)
static func get_instance() -> AJEdit_Singleton:
	return Engine.get_singleton("AJEdit_Singleton")

# 

# 创建自动加载数据。（中文）
# Create autoload data.(English)
# 获取自动加载路径。（中文）
# Gets autoload path.(English)
func _get_autoload_paths() -> Array:
	var propertys = ProjectSettings.get_property_list().map(func(prop): return prop.name)
	var autoloads = propertys.filter(func(prop): return ProjectSettings.has_setting(prop)).filter(func(prop): return prop.containsn("autoload/"))
	return autoloads

# 读取自动加载。（中文）
# Loading autoload.(English)
func load_autoload() -> Array:
	var autoload_paths = _get_autoload_paths()
	var autoload_infos: Array
	var sort = 0
	for path in autoload_paths:
		var autoload_setting = ProjectSettings.get_setting(path)
		var autoload_name = path.replacen("autoload/", "")
		var autoload_path = autoload_setting.replacen("*", "")
		var autoload_enable = autoload_setting.contains("*")
		autoload_infos.append({"name": autoload_name, "path": autoload_path, "enable": autoload_enable, "setting": autoload_setting, "sort": sort})
		sort = sort + 1
	#print(autoload_infos)
	return autoload_infos

# 添加自动加载。（中文）
# Add autoload.(English)
func add_autoload(name: String, path: String) -> void:
	add_autoload_singleton.call(name, path)

# 删除自动加载。（中文）
# Remove autoload.(English)
func remove_autoload(name: String) -> void:
	remove_autoload_singleton.call(name)

# 修改自动加载名称。（中文）
# Change autoload name.(English)
func change_autoload_name(name: String, new_name: String) -> Array:
	var autoload_infos = load_autoload()
	var idx = load_autoload().find_custom(func(info): return info["name"] == name)
	if idx < 0:
		return autoload_infos
	var autoload = autoload_infos[idx]
	var sort = autoload["sort"]
	var path = autoload["path"]
	var autoload_path = "autoload/" + new_name
	var setting  = autoload["setting"]
	remove_autoload(name)
	add_autoload(new_name, path)
	ProjectSettings.set_order(autoload_path, sort)
	ProjectSettings.set_setting(autoload_path, setting)
	return load_autoload()

# 启动自动加载。（中文）
# Enable autoload.(English)
func enable_autoload(name: String, enable: bool) -> Array:
	var autoload_infos = load_autoload()
	var idx = load_autoload().find_custom(func(info): return info["name"] == name)
	if idx < 0:
		return autoload_infos
	var autoload = autoload_infos[idx]
	var setting  = autoload["path"] if !enable else "*" + autoload["path"]
	var autoload_path = "autoload/" + name
	ProjectSettings.set_setting(autoload_path, setting)
	return load_autoload()

# 修改自动加载顺序。（中文）
# Change autoload sort.(English)
func change_autoload_sort(name: String, up: bool) -> Array:
	var autoload_infos = load_autoload()
	var idx = load_autoload().find_custom(func(info): return info["name"] == name)
	if idx < 0:
		return autoload_infos
	var autoload = autoload_infos[idx]
	var sort = autoload["sort"] - 1 if up else autoload["sort"] + 1
	var autoload_path = "autoload/" + name
	if sort < 0:
		return autoload_infos
	ProjectSettings.set_order(autoload_path, sort)
	return load_autoload()
