#include "puremotion.h"
#include "utils.h"

VALUE rb_cStream;
VALUE rb_cAudioStream;
VALUE rb_mStreams;

static VALUE stream_sample_rate(VALUE self) {
    AVStream * stream = get_stream(self);

    rb_float_new(stream->codec->sample_rate);
}

static VALUE audio_stream_init(VALUE self, VALUE media) {
    //printf("Stream initialized\n");
    rb_iv_set(self, "@media", media);
    return self;
}

static VALUE alloc_audio_stream(VALUE self) {
    //printf("Stream allocating...\n");
    AVStream * stream = av_new_stream(NULL, 0);
    //printf("Stream wrapping...\n");
    return Data_Wrap_Struct(rb_cStream, 0, 0, stream);
}

VALUE build_audio_stream(AVStream *stream, VALUE rb_media) {
    //printf("Stream building...\n");
    VALUE rb_stream = Data_Wrap_Struct(rb_cAudioStream, 0, 0, stream);
    //printf("Stream wrapped\n");
    return audio_stream_init(rb_stream, rb_media);
}

void Init_audio_stream() {
    rb_cAudioStream = rb_define_class_under(rb_mStreams, "Audio", rb_cStream);

    rb_define_method(rb_cAudioStream, "sample_rate",  stream_sample_rate, 0);
}