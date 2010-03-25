#include "puremotion.h"
#include "utils.h"

VALUE rb_cStream;
VALUE rb_cVideoStream;
VALUE rb_mStreams;

static VALUE stream_frame_rate(VALUE self) {
    AVStream * stream = get_stream(self);
    return(rb_float_new(av_q2d(stream->r_frame_rate)));
}

static int extract_next_frame(AVFormatContext * format_context, AVCodecContext * codec_context, int stream_index, AVFrame * frame, AVPacket * decoding_packet) {
    // open codec to decode the video if needed
    if (NULL == codec_context->codec) {
            rb_fatal("codec should have already been opened");
    }

    uint8_t * databuffer;

    int remaining = 0;
    int decoded;
    int frame_complete = 0;
    int next;

    while(!frame_complete &&
            0 == (next = next_packet_for_stream(format_context, stream_index, decoding_packet))) {
        // setting parameters before processing decoding_packet data
        remaining = decoding_packet->size;
        databuffer = decoding_packet->data;

        while(remaining > 0) {
            decoded = avcodec_decode_video(codec_context, frame, &frame_complete,
                databuffer, remaining);
            remaining -= decoded;
            // pointer seek forward
            databuffer += decoded;
        }
    }

    return next;
}

/*
 * call-seq: grab => PureMotion::Frame
 *
 *
 *
 */

static VALUE stream_grab(VALUE self) {
    AVFormatContext * format_context = get_format_context(rb_iv_get(self, "@media"));
    AVStream * stream = get_stream(self);

    AVCodecContext * codec_context = stream->codec;

    // open codec to decode the video if needed
    if (!codec_context->codec) {
        AVCodec * codec = avcodec_find_decoder(codec_context->codec_id);
        if (!codec)
            rb_raise(rb_eRuntimeError, "error codec not found");
        if (avcodec_open(codec_context, codec) < 0)
            rb_raise(rb_eRuntimeError, "error while opening codec : %s", codec->name);
    }

    VALUE rb_frame = rb_funcall(rb_const_get(rb_mPureMotion, rb_intern("Frame")),
        rb_intern("new"), 3,
        INT2NUM(codec_context->width),
        INT2NUM(codec_context->height),
        INT2NUM(codec_context->pix_fmt));

    AVFrame * frame = get_frame(rb_frame);
    avcodec_get_frame_defaults(frame);

    AVPacket decoding_packet;
    av_init_packet(&decoding_packet);

    if (rb_block_given_p()) {
        int ret;
        do {
            ret = extract_next_frame(format_context, stream->codec,
                stream->index, frame, &decoding_packet);
            rb_yield(
                rb_ary_new3(
                    3,
                    rb_frame,
                    rb_float_new(decoding_packet.pts * (double)av_q2d(stream->time_base)),
                    rb_float_new(decoding_packet.dts * (double)av_q2d(stream->time_base))
                )
            );
        } while (ret == 0);
    } else {
        extract_next_frame(format_context, stream->codec,
            stream->index, frame, &decoding_packet);
        return rb_frame;
    }

    return self;
}

static VALUE stream_resolution(VALUE self, VALUE media) {
    AVFormatContext * format_context = get_format_context(rb_iv_get(self, "@media"));
    AVStream * stream = get_stream(self);

    VALUE width = INT2NUM(stream->codec->width);
    VALUE height = INT2NUM(stream->codec->height);

    VALUE res = rb_ary_new2(2);
    rb_ary_store(res, 0, width);
    rb_ary_store(res, 1, height);

    return res;
}

static VALUE video_stream_init(VALUE self, VALUE media) {
    //printf("Stream initialized\n");
    rb_iv_set(self, "@media", media);
    return self;
}

static VALUE alloc_video_stream(VALUE self) {
    //printf("Stream allocating...\n");
    AVStream * stream = av_new_stream(NULL, 0);
    //printf("Stream wrapping...\n");
    return Data_Wrap_Struct(rb_cVideoStream, 0, 0, stream);
}

VALUE build_video_stream(AVStream *stream, VALUE rb_media) {
    //printf("Stream building...\n");
    VALUE rb_stream = Data_Wrap_Struct(rb_cVideoStream, 0, 0, stream);
    //printf("Stream wrapped\n");
    return video_stream_init(rb_stream, rb_media);
}

void Init_video_stream() {
    rb_cVideoStream = rb_define_class_under(rb_mStreams, "Video", rb_cStream);

    rb_define_method(rb_cVideoStream, "resolution", stream_resolution, 0);
    rb_define_method(rb_cVideoStream, "frame_rate", stream_frame_rate, 0);
    rb_define_method(rb_cVideoStream, "grab", stream_grab, 0);
}