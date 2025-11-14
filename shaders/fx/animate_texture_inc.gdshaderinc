uniform int frames = 4;           // total frames in your sprite sheet
uniform float frame_offset = 0.0; // optional per-object offset
uniform float bpm = 0;

void animate_sprite(inout vec2 uv, sampler2D texture_albedo) {
    float frame_time = TIME + frame_offset;
	float beat = 60.0/bpm;
    int loop_length = (frames * 2) - 2;
    float total_length = float(loop_length);
    float beat_time = total_length / beat;

    float anim_pos = floor(mod(frame_time * beat_time, total_length));

    float frame = anim_pos;
    if (anim_pos >= float(frames)) {
        frame = float(loop_length) - anim_pos;
    }

    float frame_width = 1.0 / float(frames);
    uv.x = uv.x / float(frames) + frame * frame_width;
}
