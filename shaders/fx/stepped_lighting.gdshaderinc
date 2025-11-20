uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform int cuts : hint_range(1, 8) = 3;
uniform bool SteppedLightOnOf = true;
uniform bool use_attenuation = true;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;

void light(){
	float NdotL = dot(NORMAL, LIGHT);
    vec3 base_diffuse = ALBEDO.rgb * LIGHT_COLOR / PI;
	float attenuation = 1.0f;
	if (use_attenuation) {
		attenuation = ATTENUATION;
	}
	
	if(SteppedLightOnOf){
	float diffuse_amount = NdotL + (attenuation - 1.0) + wrap;
	diffuse_amount *= steepness;
	float cuts_inv = 1.0f / float(cuts);
	float diffuse_stepped = clamp(diffuse_amount + mod(1.0f - diffuse_amount, cuts_inv), 0.0f, 1.0f);
	
	DIFFUSE_LIGHT += base_diffuse * diffuse_stepped * ATTENUATION ;
	}else{
		float diffuse = max(NdotL, 0.0);
        DIFFUSE_LIGHT += base_diffuse * diffuse * ATTENUATION;
	}
}