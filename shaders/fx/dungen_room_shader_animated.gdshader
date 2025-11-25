shader_type spatial;
uniform sampler2D albedo_texture : source_color,filter_nearest;

#include "res://shaders/fx/curve_world_inc.gdshaderinc"
#include "res://shaders/fx/animate_texture_inc.gdshaderinc"
#include "res://shaders/fx/stepped_lighting.gdshaderinc"
uniform bool CurfOnOf = true;


void vertex() {
	if (CurfOnOf){
	vec3 orig_normal = NORMAL;
    // Convert local vertex to world space
    vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
    
    // Apply world curvature
    world_pos.xyz = apply_world_curvature(world_pos.xyz);
    
    // Convert back to local space
    VERTEX = (inverse(MODEL_MATRIX) * world_pos).xyz;
    NORMAL = orig_normal;
	}
	
}




void fragment() {
 	vec2 uv = UV;
    animate_sprite(uv, albedo_texture);

    vec4 tex = texture(albedo_texture, uv);
    ALBEDO = tex.rgb;
}
