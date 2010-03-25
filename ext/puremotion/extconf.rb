require 'mkmf'

if find_executable('pkg-config')
  $CFLAGS << ' ' + `pkg-config libavfilter --cflags`.strip
  $CFLAGS << ' ' + `pkg-config libavcodec --cflags`.strip
  $CFLAGS << ' ' + `pkg-config libavutil --cflags`.strip
  $CFLAGS << ' ' + `pkg-config libswscale --cflags`.strip
  $LDFLAGS << ' ' + `pkg-config libavfilter --libs`.strip
  $LDFLAGS << ' ' + `pkg-config libavcodec --libs`.strip
  $LDFLAGS << ' ' + `pkg-config libavutil --libs`.strip
  $LDFLAGS << ' ' + `pkg-config libswscale --libs`.strip
  $LDFLAGS << ' ' + `pkg-config libgd --libs`.strip
end

ffmpeg_include, ffmpeg_lib = dir_config("ffmpeg")
dir_config("libswscale")

$CFLAGS << " -W -Wall -static"
#$LDFLAGS << " -rpath #{ffmpeg_lib}"

if have_library("avformat") and find_header('libavformat/avformat.h') and
   have_library("avcodec") and find_header('libavutil/avutil.h') and
   have_library("avutil") and find_header('libavcodec/avcodec.h') and
   have_library("swscale") and find_header('libswscale/swscale.h') and
   have_library("gd") and find_header('gd.h') then

$objs = %w(puremotion.o media.o stream_collection.o stream.o video.o audio.o utils.o frame.o)

create_makefile("puremotion_native")

else
  STDERR.puts "missing library"
  exit 1
end
