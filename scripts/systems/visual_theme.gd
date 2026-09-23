extends CanvasLayer

const MINIMAL_SHADER := """
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float invert_output = 0.0;

void fragment() {
	vec4 source = textureLod(screen_texture, SCREEN_UV, 0.0);
	float luminance = dot(source.rgb, vec3(0.299, 0.587, 0.114));
	float shape = smoothstep(0.27, 0.38, luminance);
	float monochrome = mix(shape, 1.0 - shape, invert_output);
	COLOR = vec4(vec3(monochrome), 1.0);
}
"""

var _filter: ColorRect
var _material: ShaderMaterial


func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_filter = ColorRect.new()
	_filter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_filter.color = Color.WHITE
	add_child(_filter)
	_filter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shader := Shader.new()
	shader.code = MINIMAL_SHADER
	_material = ShaderMaterial.new()
	_material.shader = shader
	_filter.material = _material
	SaveManager.settings_changed.connect(_apply_theme)
	_apply_theme()


func _apply_theme() -> void:
	var selected := clampi(int(SaveManager.settings.get("visual_theme", 0)), 0, 2)
	visible = selected != 0
	_material.set_shader_parameter("invert_output", 1.0 if selected == 2 else 0.0)


func get_selected_theme() -> int:
	return clampi(int(SaveManager.settings.get("visual_theme", 0)), 0, 2)
