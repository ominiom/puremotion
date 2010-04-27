#include "puremotion.h"

int next_packet(AVFormatContext * format_context, AVPacket * packet);
int next_packet_for_stream(AVFormatContext * format_context, int stream_index, AVPacket * packet);