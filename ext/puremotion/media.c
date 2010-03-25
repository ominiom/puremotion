#include "puremotion.h"
#include "utils.h"

VALUE rb_cMedia;
VALUE rb_cStreamCollection;
VALUE rb_eUnsupportedFormat;

/* call-seq: filename => String
 *
 * Returns the path to the file encapsulated by this instance of the media class
 *
 * @return [String]
 *
 */
static VALUE media_filename(VALUE self) {
    AVFormatContext * format_context = get_format_context(self);
    if( format_context->filename == NULL ) return Qnil;
    return rb_funcall(rb_cFile, rb_intern("expand_path"), 1, rb_str_new2(format_context->filename));
}

/* call-seq: streams => Array<PureMotion::Streams::Stream>
 *
 * Collection of streams in the media
 *
 * @return [Array<PureMotion::Streams::Stream>]
 */
static VALUE media_streams(VALUE self) {

    return build_stream_collection(self);

}

/* call-seq: bitrate => Number
 *
 * Media bitrate in bytes/sec
 *
 * @return [Number]
 */
static VALUE media_bitrate(VALUE self) {
    AVFormatContext * format_context = get_format_context(self);
    return INT2NUM( format_context->bit_rate );
}

/* call-seq: duration => Float
 *
 * Media duration in seconds
 *
 * @return [Float]
 */
static VALUE media_duration(VALUE self) {
    AVFormatContext * format_context = get_format_context(self);

    if (format_context->duration == AV_NOPTS_VALUE) return Qnil;

    return rb_float_new(format_context->duration / (double)AV_TIME_BASE);
}

/* call-seq: duration_human => String
 *
 * Formatted human-readable duration string
 *
 * @return [String]
 */
static VALUE media_duration_human(VALUE self) {
    AVFormatContext * format_context = get_format_context(self);

    if (format_context->duration == AV_NOPTS_VALUE) return Qnil;

    int hours, mins, secs, us;
    char cstr[64] = "";

    secs = format_context->duration / AV_TIME_BASE;
    us = format_context->duration % AV_TIME_BASE;
    mins = secs / 60;
    secs %= 60;
    hours = mins / 60;
    mins %= 60;
    sprintf(cstr, "%02d:%02d:%02d.%01d", hours, mins, secs,
           (10 * us) / AV_TIME_BASE);

    return rb_str_new2(cstr);
}

// Determines if the file can be read and processed
// @return [Boolean]
static VALUE media_valid(VALUE self) {
    return rb_iv_get(self, "@valid");
}

/* call-seq: initialize(String) => Media
 * 
 * Loads a media file
 *
 * @param [String] file Path to a media file to load
 */
static VALUE media_init(VALUE self, VALUE file) {


    AVFormatContext *fmt_ctx = get_format_context(self);

    AVFormatParameters fp, *ap = &fp;

    memset(ap, 0, sizeof(fp));

    ap->prealloced_context = 1;
    ap->width = 0;
    ap->height = 0;
    ap->pix_fmt = PIX_FMT_NONE;

    if( rb_funcall(rb_cFile, rb_intern("file?"), 1, file) == Qfalse )
        rb_raise(rb_eArgError, "File not found '%s'", StringValuePtr(file));

    int error = av_open_input_file(&fmt_ctx, StringValuePtr(file), NULL, 0, ap);

    if( error < 0 ) {
        rb_raise(rb_eUnsupportedFormat, "File '%s' unable to be opened. Unsupported format.", StringValuePtr(file));
        rb_iv_set(self, "@valid", Qfalse);
        return Qnil;
    }

    error = av_find_stream_info(fmt_ctx);

    if( error < 0 ) {
        rb_raise(rb_eUnsupportedFormat, "File '%s': Streams are unreadable.", StringValuePtr(file));
        rb_iv_set(self, "@valid", Qfalse);
    }

    rb_iv_set(self, "@valid", Qtrue);

    return self;
    
}

static void free_media(AVFormatContext *fmt_ctx) {
    if ( fmt_ctx == NULL) return;
    int i;
    
    rb_funcall(rb_mKernel, "puts", 1, INT2NUM(fmt_ctx->nb_streams));

    for(i = 0; i < fmt_ctx->nb_streams; i++) {
        if( fmt_ctx->streams[i]->codec->codec != NULL )
            avcodec_close(fmt_ctx->streams[i]->codec);
    }
    
    if( fmt_ctx->iformat ) av_close_input_file(fmt_ctx);
    else av_free(fmt_ctx);
}

static VALUE alloc_media(VALUE self) {
    AVFormatContext * fmt_ctx = av_alloc_format_context();
    VALUE obj;
    fmt_ctx->oformat = NULL;
    fmt_ctx->iformat = NULL;

    obj = Data_Wrap_Struct(self, 0, free_media, fmt_ctx);
    return obj;
}

void Init_media() {

    rb_cMedia = rb_define_class_under(rb_mPureMotion, "Media", rb_cObject);

    rb_define_alloc_func(rb_cMedia, alloc_media);
    rb_define_method(rb_cMedia, "initialize", media_init, 1);

    rb_define_method(rb_cMedia, "duration", media_duration, 0);
    rb_define_method(rb_cMedia, "duration_human", media_duration_human, 0);
    rb_define_method(rb_cMedia, "bitrate", media_bitrate, 0);
    rb_define_method(rb_cMedia, "filename", media_filename, 0);
    rb_define_method(rb_cMedia, "streams", media_streams, 0);
    rb_define_method(rb_cMedia, "valid?", media_valid, 0);

    rb_eUnsupportedFormat = rb_define_class_under(rb_mPureMotion, "UnsupportedFormat", rb_eStandardError);

}
