shader_type spatial;

uniform float cell_size = 16;
uniform float cell_spacing = 2;
uniform vec4 base_colour: hint_color = vec4(vec3(0.5), 1.0);
uniform vec4 grid_colour: hint_color = vec4(vec3(1.0), 1.0);

varying vec3 v;

render_mode cull_disabled;

void vertex(){
	v = VERTEX;
}

void fragment() {
	float step_size = cell_size + cell_spacing;
	float ratio = cell_spacing / step_size;
	if (fract(v.x / step_size) < ratio || fract(v.z / step_size) < ratio){
		ALBEDO = vec3(1.0, 1.0, 1.0);
	} else{
		ALBEDO = vec3(0.0, 0.0, 0.0);
	}
}