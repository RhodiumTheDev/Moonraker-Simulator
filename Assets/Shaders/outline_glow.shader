shader_type spatial;

uniform float width: hint_range(0, 0.3) = 0.3;

uniform vec4 base_colour: hint_color = vec4(vec3(0.0), 1.0);
uniform vec4 glow_colour: hint_color = vec4(vec3(1.0), 1.0);

render_mode shadows_disabled, cull_disabled;

void fragment(){
	ALBEDO = base_colour.xyz;
	if(max(UV.x, width) == width || min(UV.x, 1.0 - width) == 1.0 - width){
		EMISSION = glow_colour.xyz * 2.0;
//		max(width - UV.x, 0);
	}else if(max(UV.y, width) == width || min(UV.y, 1.0 - width) == 1.0 - width){
		EMISSION = glow_colour.xyz * 2.0;
	}
	else{
		EMISSION = vec3(0.0);
	}
	
}