shader_type spatial;
uniform sampler2D albedo_texture : source_color,filter_nearest;
uniform sampler2D emmision_map : source_color,filter_nearest;
uniform float emission_strength : hint_range(0.0, 10.0) = 0;

#include "res://shaders/fx/curve_world_inc.gdshaderinc"
#include "res://shaders/fx/stepped_lighting.gdshaderinc"
uniform bool emmisionOnOf = false;
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

    vec4 tex = texture(albedo_texture, uv);
	vec4 emi = texture(emmision_map,uv);
	float mask = emi.r;
	mask = mask < 0.1? 0.0 : mask;
	if(emmisionOnOf){
		EMISSION = tex.rgb * mask * emission_strength;
	}else{
		EMISSION = vec3(0.0);
	}

    ALBEDO = tex.rgb;
}
