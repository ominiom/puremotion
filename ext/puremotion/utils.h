#include "puremotion.h"

AVFormatContext * get_format_context(VALUE self);
AVStream * get_stream(VALUE self);
AVCodecContext * get_codec_context(VALUE self);
AVFrame * get_frame(VALUE self);
