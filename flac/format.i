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
// do some renaming
%rename (StreamDecoder) FLAC__StreamDecoder;
%rename (StreamEncoder) FLAC__StreamEncoder;

%rename (Metadata) FLAC__StreamMetadata;
%rename (StreamInfo) FLAC__StreamMetadata_StreamInfo;
%rename (Padding) FLAC__StreamMetadata_Padding;
%rename (Application) FLAC__StreamMetadata_Application;
%rename (SeekTable) FLAC__StreamMetadata_SeekTable;
%rename (VorbisComment) FLAC__StreamMetadata_VorbisComment;
%rename (CueSheet) FLAC__StreamMetadata_CueSheet;
%rename (Unknown) FLAC__StreamMetadata_Unknown;
%rename (VorbisCommentEntry) FLAC__StreamMetadata_VorbisComment_Entry;
%rename (SeekPoint) FLAC__StreamMetadata_SeekPoint;
%rename (Picture) FLAC__StreamMetadata_Picture;
%rename (CueSheetTrack) FLAC__StreamMetadata_CueSheet_Track;
%rename (CueSheetIndex) FLAC__StreamMetadata_CueSheet_Index;

%rename (STREAMINFO) FLAC__METADATA_TYPE_STREAMINFO;
%rename (PADDING) FLAC__METADATA_TYPE_PADDING;
%rename (APPLICATION) FLAC__METADATA_TYPE_APPLICATION;
%rename (SEEKTABLE) FLAC__METADATA_TYPE_SEEKTABLE;
%rename (VORBIS_COMMENT) FLAC__METADATA_TYPE_VORBIS_COMMENT;
%rename (CUESHEET) FLAC__METADATA_TYPE_CUESHEET;
%rename (PICTURE) FLAC__METADATA_TYPE_PICTURE;
%rename (UNDEFINED) FLAC__METADATA_TYPE_UNDEFINED;
/*
typedef enum FLAC__Metadata_ChainStatus {
    FLAC__METADATA_CHAIN_STATUS_OK = 0,
    FLAC__METADATA_CHAIN_STATUS_ILLEGAL_INPUT,
    FLAC__METADATA_CHAIN_STATUS_ERROR_OPENING_FILE,
    FLAC__METADATA_CHAIN_STATUS_NOT_A_FLAC_FILE,
    FLAC__METADATA_CHAIN_STATUS_NOT_WRITABLE,
    FLAC__METADATA_CHAIN_STATUS_BAD_METADATA,
    FLAC__METADATA_CHAIN_STATUS_READ_ERROR,
    FLAC__METADATA_CHAIN_STATUS_SEEK_ERROR,
    FLAC__METADATA_CHAIN_STATUS_WRITE_ERROR,
    FLAC__METADATA_CHAIN_STATUS_RENAME_ERROR,
    FLAC__METADATA_CHAIN_STATUS_UNLINK_ERROR,
    FLAC__METADATA_CHAIN_STATUS_MEMORY_ALLOCATION_ERROR,
    FLAC__METADATA_CHAIN_STATUS_INTERNAL_ERROR
*/
%{
#include <FLAC/format.h>
#include <FLAC/metadata.h>
#include <FLAC/stream_decoder.h>
#include <FLAC/stream_encoder.h>
%}
// common defs

typedef int FLAC__bool;
typedef signed char FLAC__int8;
typedef unsigned char FLAC__uint8;
typedef short FLAC__int16;
typedef int FLAC__int32;
typedef long long FLAC__int64;
typedef unsigned short FLAC__uint16;
typedef unsigned int FLAC__uint32;
typedef unsigned long long FLAC__uint64;
typedef char FLAC__byte;
typedef float FLAC__real;

// StreamDecoder defs

typedef enum {
        FLAC__STREAM_DECODER_INIT_STATUS_OK = 0,
        FLAC__STREAM_DECODER_INIT_STATUS_UNSUPPORTED_CONTAINER,
        FLAC__STREAM_DECODER_INIT_STATUS_ERROR_OPENING_FILE,
        FLAC__STREAM_DECODER_INIT_STATUS_MEMORY_ALLOCATION_ERROR,
        FLAC__STREAM_DECODER_INIT_STATUS_INVALID_CALLBACKS,
        FLAC__STREAM_DECODER_INIT_STATUS_ALREADY_INITIALIZED
} FLAC__StreamDecoderState;

typedef struct FLAC__StreamDecoder {
        struct FLAC__StreamDecoderProtected *protected_; /* avoid the C++ keyword 'protected' */
        struct FLAC__StreamDecoderPrivate *private_; /* avoid the C++ keyword 'private' */
} FLAC__StreamDecoder;

// StreamEncoder defs

typedef enum {
        FLAC__STREAM_ENCODER_OK = 0,
        FLAC__STREAM_ENCODER_UNINITIALIZED,
        FLAC__STREAM_ENCODER_OGG_ERROR,
        FLAC__STREAM_ENCODER_VERIFY_DECODER_ERROR,
        FLAC__STREAM_ENCODER_VERIFY_MISMATCH_IN_AUDIO_DATA,
        FLAC__STREAM_ENCODER_CLIENT_ERROR,
        FLAC__STREAM_ENCODER_IO_ERROR,
        FLAC__STREAM_ENCODER_FRAMING_ERROR,
        FLAC__STREAM_ENCODER_MEMORY_ALLOCATION_ERROR
} FLAC__StreamEncoderState;

typedef struct FLAC__StreamEncoder {
        struct FLAC__StreamEncoderProtected *protected_; /* avoid the C++ keyword 'protected' */
        struct FLAC__StreamEncoderPrivate *private_; /* avoid the C++ keyword 'private' */
} FLAC__StreamEncoder;

// Metadata defs

%typemap(in) FLAC__StreamMetadata_VorbisComment_Entry entry {

    if (!PyString_Check($input)) {
        PyErr_SetString(PyExc_TypeError, "Expecting a string object");
        return NULL;
    }

    FLAC__StreamMetadata_VorbisComment_Entry entry;
    entry.length = PyString_Size($input);
    entry.entry = PyString_AsString($input);
    $1 = entry;
}

typedef struct FLAC__StreamMetadata {
    FLAC__MetadataType type;
    FLAC__bool is_last;
    unsigned length;

    union {
        FLAC__StreamMetadata_StreamInfo stream_info;
        FLAC__StreamMetadata_Padding padding;
        FLAC__StreamMetadata_Application application;
        FLAC__StreamMetadata_SeekTable seek_table;
        FLAC__StreamMetadata_VorbisComment vorbis_comment;
        FLAC__StreamMetadata_CueSheet cue_sheet;
        FLAC__StreamMetadata_Unknown unknown;
    } data;
} FLAC__StreamMetadata;

typedef struct FLAC__StreamMetadata_StreamInfo {
    unsigned min_blocksize, max_blocksize;
    unsigned min_framesize, max_framesize;
    unsigned sample_rate;
    unsigned channels;
    unsigned bits_per_sample;
    FLAC__uint64 total_samples;
    FLAC__byte md5sum[16];
} FLAC__StreamMetadata_StreamInfo;

typedef struct FLAC__StreamMetadata_Padding {
    int dummy;
} FLAC__StreamMetadata_Padding;

typedef struct FLAC__StreamMetadata_Application {
    FLAC__byte id[4];
    FLAC__byte *data;
} FLAC__StreamMetadata_Application;

typedef struct FLAC__StreamMetadata_SeekPoint {
    FLAC__uint64 sample_number;
    FLAC__uint64 stream_offset;
    unsigned frame_samples;
} FLAC__StreamMetadata_SeekPoint;

typedef struct FLAC__StreamMetadata_SeekTable {
    unsigned num_points;
    FLAC__StreamMetadata_SeekPoint *points;
} FLAC__StreamMetadata_SeekTable;

// This typemap returns a python string instead of vc entry
%typemap(out) FLAC__StreamMetadata_VorbisComment_Entry * {
    $result = PyString_FromStringAndSize($1->entry, $1->length);
}

typedef struct FLAC__StreamMetadata_VorbisComment_Entry {
    FLAC__uint32 length;
    FLAC__byte *entry;
} FLAC__StreamMetadata_VorbisComment_Entry;


typedef struct FLAC__StreamMetadata_VorbisComment {
    FLAC__StreamMetadata_VorbisComment_Entry vendor_string;
    FLAC__uint32 num_comments;
    %typemap(out) FLAC__StreamMetadata_VorbisComment_Entry *;
    FLAC__StreamMetadata_VorbisComment_Entry *comments;
} FLAC__StreamMetadata_VorbisComment;

typedef struct FLAC__StreamMetadata_CueSheet_Index {
    FLAC__uint64 offset;
    FLAC__byte number;
} FLAC__StreamMetadata_CueSheet_Index;

typedef struct FLAC__StreamMetadata_CueSheet_Track {
    FLAC__uint64 offset;
    FLAC__byte number;
    char isrc[13];
    unsigned type:1;
    unsigned pre_emphasis:1;
    FLAC__byte num_indices;
    FLAC__StreamMetadata_CueSheet_Index *indices;
} FLAC__StreamMetadata_CueSheet_Track;

typedef struct FLAC__StreamMetadata_CueSheet {
    char media_catalog_number[129];
    FLAC__uint64 lead_in;
    FLAC__bool is_cd;
    unsigned num_tracks;
    FLAC__StreamMetadata_CueSheet_Track *tracks;
} FLAC__StreamMetadata_CueSheet;

typedef struct FLAC__StreamMetadata_Unknown {
    FLAC__byte *data;
} FLAC__StreamMetadata_Unknown;

typedef enum FLAC__MetadataType {
    FLAC__METADATA_TYPE_STREAMINFO = 0,
    FLAC__METADATA_TYPE_PADDING = 1,
    FLAC__METADATA_TYPE_APPLICATION = 2,
    FLAC__METADATA_TYPE_SEEKTABLE = 3,
    FLAC__METADATA_TYPE_VORBIS_COMMENT = 4,
    FLAC__METADATA_TYPE_CUESHEET = 5,
    FLAC__METADATA_TYPE_PICTURE = 6,
    FLAC__METADATA_TYPE_UNDEFINED = 7
} FLAC__MetadataType;

typedef enum FLAC__Metadata_ChainStatus {
    FLAC__METADATA_CHAIN_STATUS_OK = 0,
    FLAC__METADATA_CHAIN_STATUS_ILLEGAL_INPUT,
    FLAC__METADATA_CHAIN_STATUS_ERROR_OPENING_FILE,
    FLAC__METADATA_CHAIN_STATUS_NOT_A_FLAC_FILE,
    FLAC__METADATA_CHAIN_STATUS_NOT_WRITABLE,
    FLAC__METADATA_CHAIN_STATUS_BAD_METADATA,
    FLAC__METADATA_CHAIN_STATUS_READ_ERROR,
    FLAC__METADATA_CHAIN_STATUS_SEEK_ERROR,
    FLAC__METADATA_CHAIN_STATUS_WRITE_ERROR,
    FLAC__METADATA_CHAIN_STATUS_RENAME_ERROR,
    FLAC__METADATA_CHAIN_STATUS_UNLINK_ERROR,
    FLAC__METADATA_CHAIN_STATUS_MEMORY_ALLOCATION_ERROR,
    FLAC__METADATA_CHAIN_STATUS_INTERNAL_ERROR
} FLAC__Metadata_ChainStatus;
