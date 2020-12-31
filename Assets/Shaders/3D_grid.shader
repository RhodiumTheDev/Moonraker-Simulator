shader_type spatial;

render_mode cull_disabled;

uniform vec3 scale = vec3(1.0);
uniform vec4 color1: hint_color = vec4(0.4, 0.4, 0.4, 1.0);
uniform vec4 color2: hint_color = vec4(0.6, 0.6, 0.6, 1.0);

void fragment() {
  vec3 worldCoords = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz / scale;
  vec3 blockIndex = floor(mod(worldCoords, 2.0));
  float colorIndex = mod(blockIndex.x + blockIndex.y + blockIndex.z, 2.0);
  ALBEDO = colorIndex == 0.0 ? color1.rgb : color2.rgb;
}