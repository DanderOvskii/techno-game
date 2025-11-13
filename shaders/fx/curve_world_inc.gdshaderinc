uniform float curvature_strength : hint_range(-2, 2) = 0.001;
uniform vec3 camera_position = vec3(0.0, 0.0, 0.0);


vec3 apply_world_curvature(vec3 world_pos) {
    vec2 diff = world_pos.xz - camera_position.xz;
    float dist = length(diff);
    world_pos.y += dist * dist * curvature_strength;
    return world_pos;
}