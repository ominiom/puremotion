#include "puremotion.h"

VALUE rb_mPureMotion;
VALUE rb_mStreams;

void Init_puremotion_native() {

    av_register_all();
    avcodec_register_all();

    // Don't sent all output into ruby interpreter
    // This will eventually be changed by calling av_log_callback
    // If you want to develop it's best you set this to AV_LOG_VERBOSE
    av_log_set_level(AV_LOG_QUIET);

    rb_mPureMotion = rb_define_module("PureMotion");
    rb_mStreams = rb_define_module_under(rb_mPureMotion, "Streams");

    Init_media();
    Init_stream();
    Init_video_stream();
    Init_audio_stream();
    Init_stream_collection();
    Init_frame();

}
