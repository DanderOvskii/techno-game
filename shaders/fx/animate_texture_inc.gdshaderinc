uniform int frames = 4;           // total frames in your sprite sheet
uniform float frame_offset = 0.0; // optional per-object offset
uniform float bpm = 0;
uniform bool playbackSecondbBeat = false;

void animate_sprite(inout vec2 uv, sampler2D texture_albedo) {
	float beat = 60.0/bpm;
    float frame_time = TIME + frame_offset;
	float frame_count = float(frames);
    float frame_width = 1.0 / frame_count;
    

	if (!playbackSecondbBeat){
		int loop_length = (frames * 2) - 2;
	    float total_length = float(loop_length);
	    float anim_pos = floor(mod(frame_time * (total_length / beat), total_length));
	    float frame = anim_pos;
	    if (anim_pos >= float(frames)) {
	        frame = float(loop_length) - anim_pos;
	    }
		 uv.x = uv.x / float(frames) + frame * frame_width;
		return;
	}
	if (playbackSecondbBeat){
		float beat_index = floor(frame_time / beat);
	 	bool reverse = mod(beat_index, 2.0) == 1.0;
		float beat_phase = fract(frame_time / beat);
		float frame = floor (beat_phase * frame_count);
		if (reverse) {
            frame = (frame_count - 1.0) - frame; // reverse direction
        }

        frame = clamp(frame, 0.0, frame_count - 1.0); // safety

        uv.x = uv.x / frame_count + frame * frame_width;
		
	}

}
