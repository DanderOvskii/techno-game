shader_type spatial;

#include "res://shaders/fx/curve_world_inc.gdshaderinc"

uniform sampler2D albedo_texture : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform sampler2D normal_texture : hint_normal;
uniform sampler2D roughness_texture;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform bool tun_off_curf = true;

void vertex() {
	if (tun_off_curf == true){
		
    // Convert local vertex to world space
    vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
    
    // Apply world curvature
    world_pos.xyz = apply_world_curvature(world_pos.xyz);
    
    // Convert back to local space
    VERTEX = (inverse(MODEL_MATRIX) * world_pos).xyz;
	}
}

void fragment() {
    vec4 albedo_tex = texture(albedo_texture, UV);
    ALBEDO = (albedo_tex * albedo_color).rgb;
    METALLIC = metallic;
    ROUGHNESS = roughness;
    NORMAL_MAP = texture(normal_texture, UV).rgb;
}
