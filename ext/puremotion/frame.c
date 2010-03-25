#include "puremotion.h"
#include "utils.h"

VALUE rb_cFrame;

static AVFrame * alloc_picture(int pix_fmt, int width, int height) {
    AVFrame *picture;
    uint8_t *picture_buf;
    int size;

    picture = avcodec_alloc_frame();
    if (!picture)
        return NULL;
    size = avpicture_get_size(pix_fmt, width, height);
    picture_buf = av_malloc(size);
    if (!picture_buf) {
        av_free(picture);
        return NULL;
    }
    avpicture_fill((AVPicture *)picture, picture_buf,
        pix_fmt, width, height);
    return picture;
}

static VALUE frame_to_rgb24(VALUE self) {
    int width = NUM2INT(rb_iv_get(self, "@width"));
    int height = NUM2INT(rb_iv_get(self, "@height"));
    int pixel_format = NUM2INT(rb_iv_get(self, "@pixel_format"));

    struct SwsContext *img_convert_ctx = NULL;
    img_convert_ctx = sws_getContext(width, height, pixel_format,
        width, height, PIX_FMT_RGB24, SWS_BICUBIC, NULL, NULL, NULL);

    AVFrame * from = get_frame(self);
    AVFrame * to = alloc_picture(PIX_FMT_RGB24, width, height);

    sws_scale(img_convert_ctx, from->data, from->linesize,
        0, height, to->data, to->linesize);

    av_free(img_convert_ctx);

    return build_frame_object(to, width, height, PIX_FMT_RGB24);
}



static VALUE frame_to_ppm(VALUE self) {
    VALUE rb_frame = frame_to_rgb24(self);
    AVFrame * frame = get_frame(rb_frame);

    int width = NUM2INT(rb_iv_get(self, "@width"));
    int height = NUM2INT(rb_iv_get(self, "@height"));

    char header[255];
    sprintf(header, "P6\n%d %d\n255\n", width, height);

    int size = strlen(header) + frame->linesize[0] * height;
    char * data_string = malloc(size);
    strcpy(data_string, header);

    memcpy(data_string + strlen(header), frame->data[0], frame->linesize[0] * height);

    return rb_str_new(data_string, size);
}

static VALUE frame_resize(VALUE self, VALUE w, VALUE h) {

    int orig_width = NUM2INT(rb_iv_get(self, "@width"));
    int orig_height = NUM2INT(rb_iv_get(self, "@height"));

    int new_width = NUM2INT(w);
    int new_height = NUM2INT(h);

    int pixel_format = NUM2INT(rb_iv_get(self, "@pixel_format"));

    struct SwsContext *img_convert_ctx = NULL;
    img_convert_ctx = sws_getContext(orig_width, orig_height, pixel_format,
        new_width, new_height, PIX_FMT_RGB24, SWS_BICUBIC, NULL, NULL, NULL);

    AVFrame * from = get_frame(self);
    AVFrame * to = alloc_picture(PIX_FMT_RGB24, new_width, new_height);

    sws_scale(img_convert_ctx, from->data, from->linesize,
        0, orig_height, to->data, to->linesize);

    av_free(img_convert_ctx);

    return build_frame_object(to, new_width, new_height, PIX_FMT_RGB24);
    
}

static VALUE frame_save(VALUE self, VALUE filename) {

    int w = NUM2INT(rb_iv_get(self, "@width"));
    int h = NUM2INT(rb_iv_get(self, "@height"));

    gdImagePtr img = gdImageCreateTrueColor(w, h);

    AVFrame *frame = get_frame(self);

    int x, y;

    // Copy pixel by pixel...
    for( x = 0; x <= w; x++ ) {
        for( y = 0; y <= h; y++ ) {

            int off = (y * frame->linesize[0])+(3*x);
            int red = frame->data[0][off];
            int green = frame->data[0][off + 1];
            int blue = frame->data[0][off + 2];
            
            int c = gdImageColorAllocate(img,
                red,
                green,
                blue
            );
            
            gdImageSetPixel(img, x, y, c);
        }
    }

    FILE *f = fopen(StringValuePtr(filename), "wb");
    gdImagePng(img, f);
    fclose(f);

    // Gone forever....
    gdImageDestroy(img);

    return self;

}

static void free_frame(AVFrame * frame) {
    //fprintf(stderr, "will free frame\n");
    av_free(frame);
}

static VALUE alloc_frame(VALUE klass) {
    AVFrame * frame = avcodec_alloc_frame();
    VALUE obj;
    obj = Data_Wrap_Struct(klass, 0, free_frame, frame);
    return obj;
}

static VALUE frame_init(VALUE self, VALUE width, VALUE height, VALUE pixel_format) {
    //fprintf(stderr, "new frame : %dx%d, pix:%d\n", NUM2INT(width), NUM2INT(height), NUM2INT(pixel_format));
    rb_iv_set(self, "@width", width);
    rb_iv_set(self, "@height", height);
    rb_iv_set(self, "@pixel_format", pixel_format);
    return self;
}

VALUE build_frame_object(AVFrame * frame, int width, int height, int pixel_format) {
    VALUE obj = Data_Wrap_Struct(rb_cFrame, 0, free_frame, frame);

    return frame_init(obj,
        INT2FIX(width),
        INT2FIX(height),
        INT2FIX(pixel_format));
}

void Init_frame() {
    rb_cFrame = rb_define_class_under(rb_mPureMotion, "Frame", rb_cObject);

    rb_define_alloc_func(rb_cFrame, alloc_frame);
    rb_define_method(rb_cFrame, "initialize", frame_init, 3);

    rb_funcall(rb_cFrame, rb_intern("attr_reader"), 1, rb_sym("width"));
    rb_funcall(rb_cFrame, rb_intern("attr_reader"), 1, rb_sym("height"));
    rb_funcall(rb_cFrame, rb_intern("attr_reader"), 1, rb_sym("pixel_format"));

    rb_define_method(rb_cFrame, "to_rgb24", frame_to_rgb24, 0);
    rb_define_method(rb_cFrame, "to_ppm", frame_to_ppm, 0);
    rb_define_method(rb_cFrame, "resize", frame_resize, 2);
    rb_define_method(rb_cFrame, "save", frame_save, 1);
}
