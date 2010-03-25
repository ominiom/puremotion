#include "puremotion.h"

VALUE rb_cStreamCollection;
VALUE rb_mStreams;

static VALUE stream_collection_init(VALUE self) {

    return self;

}

VALUE build_stream_collection(VALUE media) {


    AVFormatContext *format_context = get_format_context(media);

    VALUE rb_streams = rb_ary_new2(format_context->nb_streams);

    int i;

    for( i = 0; i < format_context->nb_streams; i++ ) {
        AVStream *stream = format_context->streams[i];

        VALUE rb_stream;

        if( stream->codec->codec_type == CODEC_TYPE_VIDEO ) rb_stream = build_video_stream( stream, media );
        if( stream->codec->codec_type == CODEC_TYPE_AUDIO ) rb_stream = build_audio_stream( stream, media );
        else rb_stream = build_stream( stream, media );

        rb_ary_store(rb_streams, i, rb_stream);

    }

    return rb_streams;
}

void Init_stream_collection() {

    rb_cStreamCollection = rb_define_class_under(rb_mStreams, "Collection", rb_cArray);
    // rb_define_method(rb_cStreamCollection, "initialize", stream_collection_init, 1);

}
