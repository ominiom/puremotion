#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <gd.h>

#ifdef RSHIFT
#undef RSHIFT
#endif

#define DEBUG

#include "ruby.h"

#ifndef PM_H
#define PM_H

RUBY_EXTERN VALUE rb_mPureMotion;
RUBY_EXTERN VALUE rb_mStreams;
RUBY_EXTERN VALUE rb_cMedia;
RUBY_EXTERN VALUE rb_cStream;
RUBY_EXTERN VALUE rb_cVideoStream;
RUBY_EXTERN VALUE rb_cAudioStream;
RUBY_EXTERN VALUE rb_cStreamCollection;
RUBY_EXTERN VALUE rb_cFrame;

RUBY_EXTERN VALUE rb_eUnsupportedFormat;

RUBY_EXTERN void Init_puremotion_native();
RUBY_EXTERN void Init_media();
RUBY_EXTERN void Init_stream();
RUBY_EXTERN void Init_video_stream();
RUBY_EXTERN void Init_audio_stream();
RUBY_EXTERN void Init_stream_collection();
RUBY_EXTERN void Init_frame();

VALUE build_stream_collection(VALUE media);
VALUE build_stream(AVStream *stream, VALUE rb_media);
VALUE build_video_stream(AVStream *stream, VALUE rb_media);
VALUE build_audio_stream(AVStream *stream, VALUE rb_media);
VALUE build_frame_object(AVFrame * frame, int width, int height, int pixel_format);

#endif