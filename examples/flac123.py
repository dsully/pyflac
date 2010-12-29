#!/usr/bin/python

# Very simple FLAC player using the FLAC FileDecoder and libao

import flac.decoder as decoder
import flac.metadata as metadata
import ao
import sys

# setup libao audio device
#ao = ao.AudioDevice('esd')
#ao = ao.AudioDevice('alsa09')
#ao = ao.AudioDevice('wav', filename='out.wav')
ao = ao.AudioDevice('oss')

# write our callbacks (in Python!!)
def metadata_callback(dec, block):
    if block.type == metadata.VORBIS_COMMENT:
        # use flac.metadata to access vorbis comments!
        vc = metadata.VorbisComment(block)
        print vc.vendor_string
        for k in vc.comments:
            print '%s=%s' % (k, vc.comments[k])

def error_callback(dec, status):
    pass

def write_callback(dec, buff, size):
    # print dec.get_decode_position()
    ao.play(buff, size)
    return decoder.FLAC__STREAM_DECODER_OK

if len(sys.argv) < 2:
  sys.exit("Usage: %s <filename.flac>" % sys.argv[0])

# create a new file decoder
mydec = decoder.StreamDecoder()

# set some properties
mydec.set_md5_checking(False);
mydec.set_metadata_respond_all()

# initialise, process metadata
mydec.init(sys.argv[1], write_callback, metadata_callback, error_callback)
mydec.process_until_end_of_metadata()

# print out some stats, have to decode some data first
mydec.process_single()
print 'Channels: %d' % mydec.get_channels()
print 'Bits Per Sample: %d' % mydec.get_bits_per_sample()
print 'Sample Rate: %d' % mydec.get_sample_rate()
print 'BlockSize: %d' % mydec.get_blocksize()

# play the rest of the stream
mydec.process_until_end_of_stream()

# cleanup
mydec.finish()
