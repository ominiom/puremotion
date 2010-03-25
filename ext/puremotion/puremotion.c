#include "puremotion.h"

VALUE rb_mPureMotion;
VALUE rb_mStreams;

void Init_puremotion_native() {

    av_register_all();
    avcodec_register_all();

    rb_mPureMotion = rb_define_module("PureMotion");
    rb_mStreams = rb_define_module_under(rb_mPureMotion, "Streams");

    Init_media();
    Init_stream();
    Init_video_stream();
    Init_audio_stream();
    Init_stream_collection();
    Init_frame();

}
