/*
# ******************************************************
# Copyright 2004: David Collett
# David Collett <david.collett@dart.net.au>
#
# * This program is free software; you can redistribute it and/or
# * modify it under the terms of the GNU General Public License
# * as published by the Free Software Foundation; either version 2
# * of the License, or (at your option) any later version.
# *
# * This program is distributed in the hope that it will be useful,
# * but WITHOUT ANY WARRANTY; without even the implied warranty of
# * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# * GNU General Public License for more details.
# *
# * You should have received a copy of the GNU General Public License
# * along with this program; if not, write to the Free Software
# * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
# ******************************************************
*/
%module decoder

%{

#include <FLAC/format.h>
#include <FLAC/stream_decoder.h>

// Python Callback Functions Stuff
PyObject *callbacks[3];

FLAC__StreamDecoderWriteStatus PythonWriteCallBack(
    const FLAC__StreamDecoder *decoder,
    const FLAC__Frame *frame,
    const FLAC__int32 *const buffer[],
    void *client_data) {

    // Interleave the audio and return a single buffer object to python
    FLAC__uint32 data_size = frame->header.blocksize * frame->header.channels * (frame->header.bits_per_sample / 8);

    FLAC__uint16 ldb[frame->header.blocksize * frame->header.channels];
    int c_samp, c_chan, d_samp;

    for (c_samp = d_samp = 0; c_samp < frame->header.blocksize; c_samp++) {
        for(c_chan = 0; c_chan < frame->header.channels; c_chan++, d_samp++) {
            ldb[d_samp] = buffer[c_chan][c_samp];
        }
    }

    PyObject *arglist;
    PyObject *result;
    PyObject *dec, *buf;
    FLAC__StreamDecoderWriteStatus res;

    dec = SWIG_NewPointerObj((void *) decoder, SWIGTYPE_p_FLAC__StreamDecoder, 0);
    buf = PyBuffer_FromMemory((void *) ldb, data_size);
    arglist = Py_BuildValue("(OOl)", dec, buf, data_size);
    result = PyEval_CallObject(callbacks[0], arglist);

    Py_DECREF(buf);
    Py_DECREF(dec);
    Py_DECREF(arglist);

    if (result) {
        res = PyInt_AsLong(result);
    } else {
        res = FLAC__STREAM_DECODER_WRITE_STATUS_ABORT;
    }

    Py_XDECREF(result);
    return res;
}

void PythonMetadataCallBack(const FLAC__StreamDecoder *decoder, const FLAC__StreamMetadata *metadata, void *client_data) {
    PyObject *arglist;
    PyObject *dec, *meta;

    dec = SWIG_NewPointerObj((void *) decoder, SWIGTYPE_p_FLAC__StreamDecoder, 0);
    meta = SWIG_NewPointerObj((void *) metadata, SWIGTYPE_p_FLAC__StreamMetadata, 0);
    arglist = Py_BuildValue("(OO)", dec, meta);

    PyEval_CallObject(callbacks[2], arglist);

    Py_DECREF(dec);
    Py_DECREF(meta);
    Py_DECREF(arglist);
}

void PythonErrorCallBack(const FLAC__StreamDecoder *decoder, FLAC__StreamDecoderErrorStatus status, void *client_data) {
    PyObject *arglist;
    PyObject *dec, *stat;

    dec = SWIG_NewPointerObj((void *) decoder, SWIGTYPE_p_FLAC__StreamDecoder, 0);
    stat = PyCObject_FromVoidPtr((void *)status, NULL);
    arglist = Py_BuildValue("(OO)", dec, stat);

    PyEval_CallObject(callbacks[1], arglist);

    Py_DECREF(dec);
    Py_DECREF(stat);
    Py_DECREF(arglist);
}

// Simple Callbacks (for testing etc)
FLAC__StreamDecoderWriteStatus NullWriteCallBack(
    const FLAC__StreamDecoder *decoder,
    const FLAC__Frame *frame,
    const FLAC__int32 *const buffer[],
    void *client_data) {

    //printf("Inside C write cb\n");
    return FLAC__STREAM_DECODER_INIT_STATUS_OK;
}

void NullMetadataCallBack(const FLAC__StreamDecoder *decoder, const FLAC__StreamMetadata *metadata, void *client_data) {
    //printf("Inside C metadata cb\n");
}

void NullErrorCallBack(const FLAC__StreamDecoder *decoder, FLAC__StreamDecoderErrorStatus status, void *client_data) {
    //printf("Inside C error cb\n");
}

%}

%include "flac/format.i"

PyObject *callbacks[3];

%extend FLAC__StreamDecoder {
    FLAC__StreamDecoder() {
        return FLAC__stream_decoder_new();
    }

    ~FLAC__StreamDecoder() { {
        // SWIG/Python will automatically garbage collect us.
        // FLAC__stream_decoder_delete(self);
    }

    FLAC__bool set_md5_checking(FLAC__bool value) {
        return FLAC__stream_decoder_set_md5_checking(self, value);
    }

    FLAC__bool set_metadata_respond_all() {
        return FLAC__stream_decoder_set_metadata_respond_all(self);
    }

    FLAC__bool set_metadata_respond(FLAC__MetadataType type) {
        return FLAC__stream_decoder_set_metadata_respond(self, type);
    }

    FLAC__bool set_metadata_respond_application(const FLAC__byte id[4]) {
        return FLAC__stream_decoder_set_metadata_respond_application(self, id);
    }

    FLAC__bool set_metadata_ignore_all() {
        return FLAC__stream_decoder_set_metadata_ignore_all(self);
    }

    FLAC__bool set_metadata_ignore(FLAC__MetadataType type) {
        return FLAC__stream_decoder_set_metadata_ignore(self, type);
    }

    FLAC__bool set_metadata_ignore_application(const FLAC__byte id[4]) {
        return FLAC__stream_decoder_set_metadata_ignore_application(self, id);
    }

    FLAC__StreamDecoderState get_state() {
        return FLAC__stream_decoder_get_state(self);
    }

    const char *get_resolved_state_string() {
        return FLAC__stream_decoder_get_resolved_state_string(self);
    }

    FLAC__bool get_md5_checking() {
        return FLAC__stream_decoder_get_md5_checking(self);
    }

    FLAC__ChannelAssignment get_channel_assignment() {
        return FLAC__stream_decoder_get_channel_assignment(self);
    }

    unsigned get_channels() {
        return FLAC__stream_decoder_get_channels (self);
    }

    unsigned get_bits_per_sample() {
        return FLAC__stream_decoder_get_bits_per_sample(self);
    }

    unsigned get_sample_rate() {
        return FLAC__stream_decoder_get_sample_rate(self);
    }

    unsigned get_blocksize() {
        return FLAC__stream_decoder_get_blocksize(self);
    }

    FLAC__uint64 get_decode_position() {
        FLAC__uint64 tmp;
        FLAC__stream_decoder_get_decode_position(self, &tmp);
        return tmp;
    }

    FLAC__StreamDecoderState init(const char *filename, PyObject *write_cb, PyObject *metadata_cb, PyObject *error_cb) {
        callbacks[0] = write_cb;
        callbacks[1] = error_cb;
        callbacks[2] = metadata_cb;

        Py_INCREF(write_cb);
        Py_INCREF(metadata_cb);
        Py_INCREF(error_cb);

        return FLAC__stream_decoder_init_file(self, filename, PythonWriteCallBack, PythonMetadataCallBack, PythonErrorCallBack, NULL);
    }

    FLAC__bool finish() {
        return FLAC__stream_decoder_finish(self);
    }

    FLAC__bool process_single() {
        return FLAC__stream_decoder_process_single(self);
    }

    FLAC__bool process_until_end_of_metadata() {
        return FLAC__stream_decoder_process_until_end_of_metadata (self);
    }

    FLAC__bool process_until_end_of_stream() {
        return FLAC__stream_decoder_process_until_end_of_stream(self);
    }

    FLAC__bool seek_absolute(FLAC__uint64 sample) {
        return FLAC__stream_decoder_seek_absolute(self, sample);
    }
}
