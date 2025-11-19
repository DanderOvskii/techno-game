shader_type spatial;
render_mode unshaded,fog_disabled;


uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


uniform int Pixel_Size : hint_range(1, 32) = 8;
uniform bool pixelEffectOnOff = true;

void vertex() {
  POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	if(pixelEffectOnOff){
	float x = float(int(FRAGCOORD.x) % Pixel_Size);
	float y = float(int(FRAGCOORD.y) % Pixel_Size);

	x = FRAGCOORD.x + floor(float(Pixel_Size) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(Pixel_Size) / 2.0) - y;

	ALBEDO = texture(SCREEN_TEXTURE, vec2(x, y) / VIEWPORT_SIZE).xyz;
	}else{
		ALBEDO = texture(SCREEN_TEXTURE,SCREEN_UV).xyz;
	}
}