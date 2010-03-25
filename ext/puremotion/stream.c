#include "puremotion.h"
#include "utils.h"

VALUE rb_cStream;
VALUE rb_mStreams;

static int next_packet(AVFormatContext * format_context, AVPacket * packet)
{
    if(packet->data != NULL)
        av_free_packet(packet);

    if(av_read_frame(format_context, packet) < 0) {
        return -1;
    }

    return 0;
}

static int next_packet_for_stream(AVFormatContext * format_context, int stream_index, AVPacket * packet)
{
    int ret = 0;
    do {
        ret = next_packet(format_context, packet);
    } while(packet->stream_index != stream_index && ret == 0);

    return ret;
}

static VALUE stream_type( VALUE self ) {
    AVStream * stream = get_stream(self);

    VALUE type = rb_sym("unknown");

    switch( stream->codec->codec_type ) {
        case CODEC_TYPE_AUDIO:
            type = rb_sym("audio");
        break;
        case CODEC_TYPE_VIDEO:
            type = rb_sym("video");
        break;
    }

    return type;

}

static VALUE stream_duration(VALUE self) {
    AVStream *stream = get_stream(self);

    if (stream->duration == AV_NOPTS_VALUE) return Qnil;

    return (rb_float_new(stream->duration * av_q2d(stream->time_base)));
}

static VALUE stream_seek(VALUE self, VALUE position) {
    AVFormatContext * format_context = get_format_context(rb_iv_get(self, "@media"));
    AVStream * stream = get_stream(self);

    int64_t timestamp = NUM2LONG(position) / av_q2d(stream->time_base);

    int ret;
    if (format_context->start_time != AV_NOPTS_VALUE)
        timestamp += format_context->start_time;

    //fprintf(stderr, "seeking to %d\n", NUM2INT(position));
    ret = av_seek_frame(format_context, stream->index, timestamp, 0);
    if (ret < 0) {
        rb_raise(rb_eRangeError, "could not seek %s to pos %f",
            format_context->filename, timestamp * av_q2d(stream->time_base));
    }

    //fprintf(stderr, "seeked.\n");
    return self;
}

static VALUE stream_bitrate(VALUE self) {
    AVStream * stream = get_stream(self);

    rb_float_new(stream->codec->bit_rate);
}


static VALUE stream_position(VALUE self) {
    AVFormatContext * format_context = get_format_context(rb_iv_get(self, "@media"));
    AVStream * stream = get_stream(self);
    AVPacket decoding_packet;

    av_init_packet(&decoding_packet);

    do {
        if(av_read_frame(format_context, &decoding_packet) < 0) {
            rb_raise(rb_eRuntimeError, "error extracting packet");
        }
    } while(decoding_packet.stream_index != stream->index);

    return rb_float_new(decoding_packet.pts * (double)av_q2d(stream->time_base));
}

static VALUE stream_init(VALUE self, VALUE media) {
    //printf("Stream initialized\n");
    rb_iv_set(self, "@media", media);
    return self;
}

static VALUE alloc_stream(VALUE self) {
    //printf("Stream allocating...\n");
    AVStream * stream = av_new_stream(NULL, 0);
    //printf("Stream wrapping...\n");
    return Data_Wrap_Struct(rb_cStream, 0, 0, stream);
}

VALUE build_stream(AVStream *stream, VALUE rb_media) {
    //printf("Stream building...\n");
    VALUE rb_stream = Data_Wrap_Struct(rb_cStream, 0, 0, stream);
    //printf("Stream wrapped\n");
    return stream_init(rb_stream, rb_media);
}

void Init_stream() {
    rb_cStream = rb_define_class_under(rb_mStreams, "Stream", rb_cObject);
    rb_define_alloc_func(rb_cStream, alloc_stream);

    rb_define_method(rb_cStream, "type",  stream_type, 0);
    rb_define_method(rb_cStream, "duration",  stream_duration, 0);
    rb_define_method(rb_cStream, "bitrate",  stream_bitrate, 0);
    rb_define_method(rb_cStream, "seek",  stream_seek, 1);
    rb_define_method(rb_cStream, "position", stream_position, 0);
}
