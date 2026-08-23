
#include <pjmedia-audiodev/audiodev_imp.h>
#include <pj/assert.h>
#include <pj/log.h>
#include <pj/os.h>
#include <pj/string.h>
#include <pjmedia/errno.h>

//A//
#include <pjmedia/stereo.h>

#if defined(PJMEDIA_AUDIO_DEV_HAS_OBOE) && PJMEDIA_AUDIO_DEV_HAS_OBOE != 0

#include <oboe/Oboe.h>

#define THIS_FILE	"oboe_dev.c"
#define DRIVER_NAME	"oboe"

#define NUM_BUFFERS 2 


struct oboe_aud_factory
{
    pjmedia_aud_dev_factory  base;
    pj_pool_factory         *pf;
    pj_pool_t               *pool;
    
    SLObjectItf              engineObject;
    SLEngineItf              engineEngine;
    SLObjectItf              outputMixObject;
};

/*
 * Sound stream descriptor.
 * This struct may be used for both unidirectional or bidirectional sound
 * streams.
 */
struct oboe_aud_stream
{
    pjmedia_aud_stream  base;
    pj_pool_t          *pool;
    pj_str_t            name;
    pjmedia_dir         dir;
    pjmedia_aud_param   param;
    
    void               *user_data;
    pj_bool_t           quit_flag;
    pjmedia_aud_rec_cb  rec_cb;
    pjmedia_aud_play_cb play_cb;

    pj_timestamp	play_timestamp;
    pj_timestamp	rec_timestamp;
    
    pj_bool_t		rec_thread_initialized;
    pj_thread_desc	rec_thread_desc;
    pj_thread_t        *rec_thread;
    
    pj_bool_t		play_thread_initialized;
    pj_thread_desc	play_thread_desc;
    pj_thread_t        *play_thread;
    
    /* Player */
    SLObjectItf         playerObj;
    SLPlayItf           playerPlay;
    SLVolumeItf         playerVol;
    unsigned            playerBufferSize;
    char               *playerBuffer[NUM_BUFFERS+1];
    int                 playerBufIdx;
    
    /* Recorder */
    SLObjectItf         recordObj;
    SLRecordItf         recordRecord;
    unsigned            recordBufferSize;
    char               *recordBuffer[NUM_BUFFERS];
    int                 recordBufIdx;

   // W_SLBufferQueueItf  playerBufQ;
    //W_SLBufferQueueItf  recordBufQ;
};

/* Factory prototypes */
static pj_status_t oboe_init(pjmedia_aud_dev_factory *f);
static pj_status_t oboe_destroy(pjmedia_aud_dev_factory *f);
static pj_status_t oboe_refresh(pjmedia_aud_dev_factory *f);
static unsigned oboe_get_dev_count(pjmedia_aud_dev_factory *f);
static pj_status_t oboe_get_dev_info(pjmedia_aud_dev_factory *f,
                                       unsigned index,
                                       pjmedia_aud_dev_info *info);
static pj_status_t oboe_default_param(pjmedia_aud_dev_factory *f,
                                        unsigned index,
                                        pjmedia_aud_param *param);
static pj_status_t oboe_create_stream(pjmedia_aud_dev_factory *f,
                                        const pjmedia_aud_param *param,
                                        pjmedia_aud_rec_cb rec_cb,
                                        pjmedia_aud_play_cb play_cb,
                                        void *user_data,
                                        pjmedia_aud_stream **p_aud_strm);

/* Stream prototypes */
static pj_status_t strm_get_param(pjmedia_aud_stream *strm,
                                  pjmedia_aud_param *param);
static pj_status_t strm_get_cap(pjmedia_aud_stream *strm,
                                pjmedia_aud_dev_cap cap,
                                void *value);
static pj_status_t strm_set_cap(pjmedia_aud_stream *strm,
                                pjmedia_aud_dev_cap cap,
                                const void *value);
static pj_status_t strm_start(pjmedia_aud_stream *strm);
static pj_status_t strm_stop(pjmedia_aud_stream *strm);
static pj_status_t strm_destroy(pjmedia_aud_stream *strm);

static pjmedia_aud_dev_factory_op oboe_op =
{
    &oboe_init,
    &oboe_destroy,
    &oboe_get_dev_count,
    &oboe_get_dev_info,
    &oboe_default_param,
    &oboe_create_stream,
    &oboe_refresh
};

static pjmedia_aud_stream_op oboe_strm_op =
{
    &strm_get_param,
    &strm_get_cap,
    &strm_set_cap,
    &strm_start,
    &strm_stop,
    &strm_destroy
};

/* This callback is called every time a buffer finishes playing. */
void bqPlayerCallback(W_SLBufferQueueItf bq, void *context)
{
    struct oboe_aud_stream *stream = (struct oboe_aud_stream*) context;
    SLresult result;
    int status;

    pj_assert(context != NULL);
    pj_assert(bq == stream->playerBufQ);

    if (stream->play_thread_initialized == 0 || !pj_thread_is_registered())
    {
	pj_bzero(stream->play_thread_desc, sizeof(pj_thread_desc));
	status = pj_thread_register("oboe_play", stream->play_thread_desc,
				    &stream->play_thread);
	stream->play_thread_initialized = 1;
	PJ_LOG(5, (THIS_FILE, "Player thread started"));
    }
    
    char *buf2 = stream->playerBuffer[NUM_BUFFERS];

    if (!stream->quit_flag) {
        pjmedia_frame frame;
        char * buf;
        
        frame.type = PJMEDIA_FRAME_TYPE_AUDIO;
        frame.buf = buf = stream->playerBuffer[stream->playerBufIdx++];
        frame.size = stream->playerBufferSize;
        frame.timestamp.u64 = stream->play_timestamp.u64;
        frame.bit_info = 0;
        
        status = (*stream->play_cb)(stream->user_data, &frame);
        if (status != PJ_SUCCESS || frame.type != PJMEDIA_FRAME_TYPE_AUDIO)
            pj_bzero(buf, stream->playerBufferSize);
        
        stream->play_timestamp.u64 += stream->param.samples_per_frame /
                                      stream->param.channel_count;

        //A//
        if(stream->param.headphones_only)
        {
            PJ_LOG(4, (THIS_FILE, "headphonesOnly ON"));
                        //pjmedia_convert_channel_r1ton((void *)buf,(void *)buf,
                        //pjmedia_convert_channel_1ton((void *)buf,(void *)buf,
                        //2,
                        //stream->playerBufferSize*2*2, 0);
                        
                        //stream->playerBufferSize, 0);  // /2 если инт или просто /1 если тот же
                       //stream->playerBufferSize*2*2, 0); //Странно, не совсем ясно почему. Возможно размер буффера в байтах, а тут в инт мне кажется переполняет
                       //stream->playerBufferSize*2, 0); //Странно, не совсем ясно почему. Возможно размер буффера в байтах, а тут в инт
            //memcpy((void *)buf,(void *)buf2,stream->playerBufferSize*2); //dst,src
            //!!! Возможно сюда не нужно слать *2, если буффер в размере 1 канала
            result = (*bq)->Enqueue(bq, buf, stream->playerBufferSize); // IN SAMPLES!!!
            //result = (*bq)->Enqueue(bq, buf, stream->playerBufferSize*2);
        } else {
            PJ_LOG(4, (THIS_FILE, "headphonesOnly OFF"));
            result = (*bq)->Enqueue(bq, buf, stream->playerBufferSize);
        }
        
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Unable to enqueue next player buffer !!! %d",
                                  result));
        }
        
        stream->playerBufIdx %= NUM_BUFFERS;
    }
}

/* This callback handler is called every time a buffer finishes recording */
void bqRecorderCallback(W_SLBufferQueueItf bq, void *context)
{
    struct oboe_aud_stream *stream = (struct oboe_aud_stream*) context;
    SLresult result;
    int status;

    pj_assert(context != NULL);
    pj_assert(bq == stream->recordBufQ);

    if (stream->rec_thread_initialized == 0 || !pj_thread_is_registered())
    {
	pj_bzero(stream->rec_thread_desc, sizeof(pj_thread_desc));
	status = pj_thread_register("oboe_rec", stream->rec_thread_desc,
				    &stream->rec_thread);
	PJ_UNUSED_ARG(status);  /* Unused for now.. */
	stream->rec_thread_initialized = 1;
	PJ_LOG(5, (THIS_FILE, "Recorder thread started")); 
    }
    
    if (!stream->quit_flag) {
        pjmedia_frame frame;
        char *buf;
        
        frame.type = PJMEDIA_FRAME_TYPE_AUDIO;
        frame.buf = buf = stream->recordBuffer[stream->recordBufIdx++];
        frame.size = stream->recordBufferSize;
        frame.timestamp.u64 = stream->rec_timestamp.u64;
        frame.bit_info = 0;
        
        status = (*stream->rec_cb)(stream->user_data, &frame);
        
        stream->rec_timestamp.u64 += stream->param.samples_per_frame /
                                     stream->param.channel_count;
        
        /* And now enqueue next buffer */
        result = (*bq)->Enqueue(bq, buf, stream->recordBufferSize);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Unable to enqueue next record buffer !!! %d",
                                  result));
        }
        
        stream->recordBufIdx %= NUM_BUFFERS;
    }
}

pj_status_t oboe_to_pj_error(SLresult code)
{
    switch(code) {
	case SL_RESULT_SUCCESS:
            return PJ_SUCCESS;
	case SL_RESULT_PRECONDITIONS_VIOLATED:
	case SL_RESULT_PARAMETER_INVALID:
	case SL_RESULT_CONTENT_CORRUPTED:
	case SL_RESULT_FEATURE_UNSUPPORTED:
            return PJMEDIA_EAUD_INVOP;
	case SL_RESULT_MEMORY_FAILURE:
	case SL_RESULT_BUFFER_INSUFFICIENT:
            return PJ_ENOMEM;
	case SL_RESULT_RESOURCE_ERROR:
	case SL_RESULT_RESOURCE_LOST:
	case SL_RESULT_CONTROL_LOST:
            return PJMEDIA_EAUD_NOTREADY;
	case SL_RESULT_CONTENT_UNSUPPORTED:
            return PJ_ENOTSUP;
	default:
            return PJMEDIA_EAUD_ERR;
    }
}

/* Init Android audio driver. */
pjmedia_aud_dev_factory* pjmedia_oboe_factory(pj_pool_factory *pf)
{
    struct oboe_aud_factory *f;
    pj_pool_t *pool;
    
    pool = pj_pool_create(pf, "oboe", 256, 256, NULL);
    f = PJ_POOL_ZALLOC_T(pool, struct oboe_aud_factory);
    f->pf = pf;
    f->pool = pool;
    f->base.op = &oboe_op;
    
    return &f->base;
}

/* API: Init factory */
static pj_status_t oboe_init(pjmedia_aud_dev_factory *f)
{
    struct oboe_aud_factory *pa = (struct oboe_aud_factory*)f;
    SLresult result;    
    
    /* Create engine */

    
    result = slCreateEngine(&pa->engineObject, 0, NULL, 0, NULL, NULL);
    if (result != SL_RESULT_SUCCESS) {
        PJ_LOG(3, (THIS_FILE, "Cannot create engine %d ", result));
        return oboe_to_pj_error(result);
    }
    
    /* Realize the engine */
    result = (*pa->engineObject)->Realize(pa->engineObject, SL_BOOLEAN_FALSE);
    if (result != SL_RESULT_SUCCESS) {
        PJ_LOG(3, (THIS_FILE, "Cannot realize engine"));
        oboe_destroy(f);
        return oboe_to_pj_error(result);
    }
    
    /* Get the engine interface, which is needed in order to create
     * other objects.
     */
    result = (*pa->engineObject)->GetInterface(pa->engineObject,
                                               SL_IID_ENGINE,
                                               &pa->engineEngine);
    if (result != SL_RESULT_SUCCESS) {
        PJ_LOG(3, (THIS_FILE, "Cannot get engine interface"));
        oboe_destroy(f);
        return oboe_to_pj_error(result);
    }
    
    /* Create output mix */
    result = (*pa->engineEngine)->CreateOutputMix(pa->engineEngine,
                                                  &pa->outputMixObject,
                                                  0, NULL, NULL);
    if (result != SL_RESULT_SUCCESS) {
        PJ_LOG(3, (THIS_FILE, "Cannot create output mix"));
        oboe_destroy(f);
        return oboe_to_pj_error(result);
    }
    
    /* Realize the output mix */
    result = (*pa->outputMixObject)->Realize(pa->outputMixObject,
                                             SL_BOOLEAN_FALSE);
    if (result != SL_RESULT_SUCCESS) {
        PJ_LOG(3, (THIS_FILE, "Cannot realize output mix"));
        oboe_destroy(f);
        return oboe_to_pj_error(result);
    }
    
    PJ_LOG(4,(THIS_FILE, "oboe sound library initialized"));
    return PJ_SUCCESS;
}

/* API: Destroy factory */
static pj_status_t oboe_destroy(pjmedia_aud_dev_factory *f)
{
    struct oboe_aud_factory *pa = (struct oboe_aud_factory*)f;
    pj_pool_t *pool;
    
    PJ_LOG(4,(THIS_FILE, "oboe sound library shutting down.."));
    
    /* Destroy Output Mix object */
    if (pa->outputMixObject) {
        (*pa->outputMixObject)->Destroy(pa->outputMixObject);
        pa->outputMixObject = NULL;
    }
    
    /* Destroy engine object, and invalidate all associated interfaces */
    if (pa->engineObject) {
        (*pa->engineObject)->Destroy(pa->engineObject);
        pa->engineObject = NULL;
        pa->engineEngine = NULL;
    }
    
    pool = pa->pool;
    pa->pool = NULL;
    pj_pool_release(pool);
    
    return PJ_SUCCESS;
}

/* API: refresh the list of devices */
static pj_status_t oboe_refresh(pjmedia_aud_dev_factory *f)
{
    PJ_UNUSED_ARG(f);
    return PJ_SUCCESS;
}

/* API: Get device count. */
static unsigned oboe_get_dev_count(pjmedia_aud_dev_factory *f)
{
    PJ_UNUSED_ARG(f);
    return 1;
}

/* API: Get device info. */
static pj_status_t oboe_get_dev_info(pjmedia_aud_dev_factory *f,
                                       unsigned index,
                                       pjmedia_aud_dev_info *info)
{
    PJ_UNUSED_ARG(f);

    pj_bzero(info, sizeof(*info));
    
    pj_ansi_strcpy(info->name, "oboe ES Audio");
    info->default_samples_per_sec = 8000;
    info->caps = PJMEDIA_AUD_DEV_CAP_OUTPUT_VOLUME_SETTING;
    info->input_count = 1;
    info->output_count = 1;
    
    return PJ_SUCCESS;
}

/* API: fill in with default parameter. */
static pj_status_t oboe_default_param(pjmedia_aud_dev_factory *f,
                                        unsigned index,
                                        pjmedia_aud_param *param)
{
    
    pjmedia_aud_dev_info adi;
    pj_status_t status;
    
    status = oboe_get_dev_info(f, index, &adi);
    if (status != PJ_SUCCESS)
	return status;
    
    pj_bzero(param, sizeof(*param));
    if (adi.input_count && adi.output_count) {
        param->dir = PJMEDIA_DIR_CAPTURE_PLAYBACK;
        param->rec_id = index;
        param->play_id = index;
    } else if (adi.input_count) {
        param->dir = PJMEDIA_DIR_CAPTURE;
        param->rec_id = index;
        param->play_id = PJMEDIA_AUD_INVALID_DEV;
    } else if (adi.output_count) {
        param->dir = PJMEDIA_DIR_PLAYBACK;
        param->play_id = index;
        param->rec_id = PJMEDIA_AUD_INVALID_DEV;
    } else {
        return PJMEDIA_EAUD_INVDEV;
    }
    
    param->clock_rate = adi.default_samples_per_sec;
    param->channel_count = 1;
    param->samples_per_frame = adi.default_samples_per_sec * 20 / 1000;
    param->bits_per_sample = 16;
    param->input_latency_ms = PJMEDIA_SND_DEFAULT_REC_LATENCY;
    param->output_latency_ms = PJMEDIA_SND_DEFAULT_PLAY_LATENCY;
    
    return PJ_SUCCESS;
}

/* API: create stream */
static pj_status_t oboe_create_stream(pjmedia_aud_dev_factory *f,
                                        const pjmedia_aud_param *param,
                                        pjmedia_aud_rec_cb rec_cb,
                                        pjmedia_aud_play_cb play_cb,
                                        void *user_data,
                                        pjmedia_aud_stream **p_aud_strm)
{
    /* Audio sink for recorder and audio source for player */
#ifdef __ANDROID__
    SLDataLocator_AndroidSimpleBufferQueue loc_bq =
        { SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE, NUM_BUFFERS };
#else
    SLDataLocator_BufferQueue loc_bq =

        { SL_DATALOCATOR_BUFFERQUEUE, NUM_BUFFERS };
#endif
    struct oboe_aud_factory *pa = (struct oboe_aud_factory*)f;
    pj_pool_t *pool;
    struct oboe_aud_stream *stream;
    pj_status_t status = PJ_SUCCESS;
    int i, bufferSize;
    SLresult result;
    SLDataFormat_PCM format_pcm;
    
    /* Only supports for mono channel for now */
    PJ_ASSERT_RETURN(param->channel_count == 1, PJ_EINVAL);

    PJ_ASSERT_RETURN(play_cb && rec_cb && p_aud_strm, PJ_EINVAL);

    PJ_LOG(4,(THIS_FILE, "Creating oboe stream"));
    
    pool = pj_pool_create(pa->pf, "oboestrm", 1024, 1024, NULL);
    if (!pool)
        return PJ_ENOMEM;
    
    stream = PJ_POOL_ZALLOC_T(pool, struct oboe_aud_stream);
    stream->pool = pool;
    pj_strdup2_with_null(pool, &stream->name, "oboe");
    stream->dir = param->dir;
    pj_memcpy(&stream->param, param, sizeof(*param));
    stream->user_data = user_data;
    stream->rec_cb = rec_cb;
    stream->play_cb = play_cb;
    bufferSize = param->samples_per_frame * param->bits_per_sample / 8;

    /* Configure audio PCM format */
    format_pcm.formatType = SL_DATAFORMAT_PCM;
    format_pcm.numChannels = param->channel_count;
    //A//
    if(param->headphones_only)
    {
        PJ_LOG(4, (THIS_FILE, "headphonesOnly ON"));
        format_pcm.numChannels=2;
        //format_pcm.channelMask = SL_ANDROID_SPEAKER_USE_DEFAULT;
        format_pcm.channelMask = SL_SPEAKER_FRONT_LEFT|SL_SPEAKER_FRONT_RIGHT ;
    } else {
        PJ_LOG(4, (THIS_FILE, "headphonesOnly OFF"));
        format_pcm.channelMask = SL_SPEAKER_FRONT_CENTER;
    }


    /* Here samples per sec should be supported else we will get an error */
    format_pcm.samplesPerSec  = (SLuint32) param->clock_rate * 1000;
    format_pcm.bitsPerSample = (SLuint16) param->bits_per_sample;
    format_pcm.containerSize = (SLuint16) param->bits_per_sample;
    
    format_pcm.endianness = SL_BYTEORDER_LITTLEENDIAN;

    if (stream->dir & PJMEDIA_DIR_PLAYBACK) {
        /* Audio source */
        SLDataSource audioSrc = {&loc_bq, &format_pcm};
        /* Audio sink */
        SLDataLocator_OutputMix loc_outmix = {SL_DATALOCATOR_OUTPUTMIX,
                                              pa->outputMixObject};
        SLDataSink audioSnk = {&loc_outmix, NULL};
        /* Audio interface */
#ifdef __ANDROID__
        int numIface = 3;
        const SLInterfaceID ids[3] = {SL_IID_BUFFERQUEUE,
                                      SL_IID_VOLUME,
                                      SL_IID_ANDROIDCONFIGURATION};
        const SLboolean req[3] = {SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE,
                                  SL_BOOLEAN_TRUE};
        SLAndroidConfigurationItf playerConfig;
        //SLint32 streamType = SL_ANDROID_STREAM_VOICE;
        SLint32 streamType = param->stream_type; //A//
        PJ_LOG(4, (THIS_FILE, "Using audio ouput stream : %d", param->stream_type)); //A//

        /*
        #define SL_ANDROID_STREAM_VOICE        ((SLint32) 0x00000000)
        #define SL_ANDROID_STREAM_SYSTEM       ((SLint32) 0x00000001)
        #define SL_ANDROID_STREAM_RING         ((SLint32) 0x00000002)
        #define SL_ANDROID_STREAM_MEDIA        ((SLint32) 0x00000003)
        #define SL_ANDROID_STREAM_ALARM        ((SLint32) 0x00000004)
        #define SL_ANDROID_STREAM_NOTIFICATION ((SLint32) 0x00000005)
        */


#else
        int numIface = 2;
        const SLInterfaceID ids[2] = {SL_IID_BUFFERQUEUE,
                                      SL_IID_VOLUME};
        const SLboolean req[2] = {SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE};
#endif
        
        /* Create audio player */
        result = (*pa->engineEngine)->CreateAudioPlayer(pa->engineEngine,
                                                        &stream->playerObj,
                                                        &audioSrc, &audioSnk,
                                                        numIface, ids, req);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Cannot create audio player: %d", result));
            goto on_error;
        }

#ifdef __ANDROID__
        /* Set Android configuration */
        result = (*stream->playerObj)->GetInterface(stream->playerObj,
                                                    SL_IID_ANDROIDCONFIGURATION,
                                                    &playerConfig);
        if (result == SL_RESULT_SUCCESS && playerConfig) {
            result = (*playerConfig)->SetConfiguration(
                         playerConfig, SL_ANDROID_KEY_STREAM_TYPE,
                         &streamType, sizeof(SLint32));
        }
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(4, (THIS_FILE, "Warning: Unable to set android "
                                  "player configuration"));
        }
#endif

        /* Realize the player */
        result = (*stream->playerObj)->Realize(stream->playerObj,
                                               SL_BOOLEAN_FALSE);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Cannot realize player : %d", result));
            goto on_error;
        }
        
        /* Get the play interface */
        result = (*stream->playerObj)->GetInterface(stream->playerObj,
                                                    SL_IID_PLAY,
                                                    &stream->playerPlay);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Cannot get play interface"));
            goto on_error;
        }
        
        /* Get the buffer queue interface */
        result = (*stream->playerObj)->GetInterface(stream->playerObj,
                                                    SL_IID_BUFFERQUEUE,
                                                    &stream->playerBufQ);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Cannot get buffer queue interface"));
            goto on_error;
        }
        
        /* Get the volume interface */
        result = (*stream->playerObj)->GetInterface(stream->playerObj,
                                                    SL_IID_VOLUME,
                                                    &stream->playerVol);
        
        /* Register callback on the buffer queue */
        result = (*stream->playerBufQ)->RegisterCallback(stream->playerBufQ,
                                                         bqPlayerCallback,
                                                         (void *)stream);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Cannot register player callback"));
            goto on_error;
        }
        
     
        stream->playerBufferSize = bufferSize;
        
            if(param->headphones_only) //A//
            {
                PJ_LOG(4, (THIS_FILE, "headphonesOnly ON"));
                for (i = 0; i < NUM_BUFFERS+1; i++) {
                        stream->playerBuffer[i] = (char *)
                                            pj_pool_alloc(stream->pool,
                                                            //stream->playerBufferSize*2);
                                                            stream->playerBufferSize*4);
                }
            } else {
                for (i = 0; i < NUM_BUFFERS; i++) {
                    stream->playerBuffer[i] = (char *)
                                        pj_pool_alloc(stream->pool,
                                                        stream->playerBufferSize);
                }
            }
        




    }

    if (stream->dir & PJMEDIA_DIR_CAPTURE) {
        /* Audio source */
        SLDataLocator_IODevice loc_dev = {SL_DATALOCATOR_IODEVICE,
                                          SL_IODEVICE_AUDIOINPUT,
                                          SL_DEFAULTDEVICEID_AUDIOINPUT,
                                          NULL};
        SLDataSource audioSrc = {&loc_dev, NULL};
        /* Audio sink */
        SLDataSink audioSnk = {&loc_bq, &format_pcm};
        /* Audio interface */
#ifdef __ANDROID__
        int numIface = 2;
        const SLInterfaceID ids[2] = {W_SL_IID_BUFFERQUEUE,
                                      SL_IID_ANDROIDCONFIGURATION};
        const SLboolean req[2] = {SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE};
        SLAndroidConfigurationItf recorderConfig;
#else
        int numIface = 1;
        const SLInterfaceID ids[1] = {W_SL_IID_BUFFERQUEUE};
        const SLboolean req[1] = {SL_BOOLEAN_TRUE};
#endif
        
        /* Create audio recorder
         * (requires the RECORD_AUDIO permission)
         */
        result = (*pa->engineEngine)->CreateAudioRecorder(pa->engineEngine,
                                                          &stream->recordObj,
                                                          &audioSrc, &audioSnk,
                                                          numIface, ids, req);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Cannot create recorder: %d", result));
            goto on_error;
        }

#ifdef __ANDROID__
        /* Set Android configuration */
        result = (*stream->recordObj)->GetInterface(stream->recordObj,
                                                    SL_IID_ANDROIDCONFIGURATION,
                                                    &recorderConfig);
        if (result == SL_RESULT_SUCCESS) {
            SLint32 streamType = SL_ANDROID_RECORDING_PRESET_GENERIC;
#if __ANDROID_API__ >= 14
	    //streamType = SL_ANDROID_RECORDING_PRESET_VOICE_COMMUNICATION; //A//
        streamType=param->mic_source; //A//
        PJ_LOG(4, (THIS_FILE, "Using audio input source : %d", param->mic_source)); //A//

        
        /*//A//
        https://android.googlesource.com/platform/frameworks/wilhelm/+/master/include/SLES/oboe_AndroidConfiguration.h
        https://android.googlesource.com/platform/frameworks/wilhelm/+/master/include/SLES/oboe_Android.h


        #define SL_ANDROID_RECORDING_PRESET_VOICE_COMMUNICATION ((SLuint32) 0x00000004)
        #define SL_ANDROID_RECORDING_PRESET_UNPROCESSED         ((SLuint32) 0x00000005)
        */
#endif

#if 0
            /* Android-L (android-21) removes __system_property_get
             * from the NDK.
	     */
            char sdk_version[PROP_VALUE_MAX];
            pj_str_t pj_sdk_version;
            int sdk_v;

            __system_property_get("ro.build.version.sdk", sdk_version);
            pj_sdk_version = pj_str(sdk_version);
            sdk_v = pj_strtoul(&pj_sdk_version);
            if (sdk_v >= 14)
                streamType = SL_ANDROID_RECORDING_PRESET_VOICE_COMMUNICATION;
            PJ_LOG(4, (THIS_FILE, "Recording stream type %d, SDK : %d",
                                  streamType, sdk_v));
#endif
            result = (*recorderConfig)->SetConfiguration(
                         recorderConfig, SL_ANDROID_KEY_RECORDING_PRESET,
                         &streamType, sizeof(SLint32));
        }
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(4, (THIS_FILE, "Warning: Unable to set android "
                                  "recorder configuration"));
        }
#endif
        
        /* Realize the recorder */
        result = (*stream->recordObj)->Realize(stream->recordObj,
                                               SL_BOOLEAN_FALSE);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Cannot realize recorder : %d", result));
            goto on_error;
        }
        
        /* Get the record interface */
        result = (*stream->recordObj)->GetInterface(stream->recordObj,
                                                    SL_IID_RECORD,
                                                    &stream->recordRecord);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Cannot get record interface"));
            goto on_error;
        }
        
        /* Get the buffer queue interface */
        result = (*stream->recordObj)->GetInterface(
                     stream->recordObj, W_SL_IID_BUFFERQUEUE,
                     &stream->recordBufQ);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Cannot get recorder buffer queue iface"));
            goto on_error;
        }
        
        /* Register callback on the buffer queue */
        result = (*stream->recordBufQ)->RegisterCallback(stream->recordBufQ,
                                                         bqRecorderCallback, 
                                                         (void *) stream);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Cannot register recorder callback"));
            goto on_error;
        }
        
        stream->recordBufferSize = bufferSize;
        for (i = 0; i < NUM_BUFFERS; i++) {
            stream->recordBuffer[i] = (char *)
                                      pj_pool_alloc(stream->pool,
                                                    stream->recordBufferSize);
        }

    }
    
    if (param->flags & PJMEDIA_AUD_DEV_CAP_OUTPUT_VOLUME_SETTING) {
	strm_set_cap(&stream->base, PJMEDIA_AUD_DEV_CAP_OUTPUT_VOLUME_SETTING,
                     &param->output_vol);
    }
    
    /* Done */
    stream->base.op = &oboe_strm_op;
    *p_aud_strm = &stream->base;
    return PJ_SUCCESS;
    
on_error:
    strm_destroy(&stream->base);
    return status;
}

/* API: Get stream parameters */
static pj_status_t strm_get_param(pjmedia_aud_stream *s,
                                  pjmedia_aud_param *pi)
{
    struct oboe_aud_stream *strm = (struct oboe_aud_stream*)s;
    PJ_ASSERT_RETURN(strm && pi, PJ_EINVAL);
    pj_memcpy(pi, &strm->param, sizeof(*pi));

    if (strm_get_cap(s, PJMEDIA_AUD_DEV_CAP_OUTPUT_VOLUME_SETTING,
                     &pi->output_vol) == PJ_SUCCESS)
    {
        pi->flags |= PJMEDIA_AUD_DEV_CAP_OUTPUT_VOLUME_SETTING;
    }    
    
    return PJ_SUCCESS;
}

/* API: get capability */
static pj_status_t strm_get_cap(pjmedia_aud_stream *s,
                                pjmedia_aud_dev_cap cap,
                                void *pval)
{
    struct oboe_aud_stream *strm = (struct oboe_aud_stream*)s;    
    pj_status_t status = PJMEDIA_EAUD_INVCAP;
    
    PJ_ASSERT_RETURN(s && pval, PJ_EINVAL);
    
    if (cap==PJMEDIA_AUD_DEV_CAP_OUTPUT_VOLUME_SETTING &&
	(strm->param.dir & PJMEDIA_DIR_PLAYBACK))
    {
        if (strm->playerVol) {
            SLresult res;
            SLmillibel vol, mvol;
            
            res = (*strm->playerVol)->GetMaxVolumeLevel(strm->playerVol,
                                                        &mvol);
            if (res == SL_RESULT_SUCCESS) {
                res = (*strm->playerVol)->GetVolumeLevel(strm->playerVol,
                                                         &vol);
                if (res == SL_RESULT_SUCCESS) {
                    *(int *)pval = ((int)vol - SL_MILLIBEL_MIN) * 100 /
                                   ((int)mvol - SL_MILLIBEL_MIN);
                    return PJ_SUCCESS;
                }
            }
        }
    }
    
    return status;
}

/* API: set capability */
static pj_status_t strm_set_cap(pjmedia_aud_stream *s,
                                pjmedia_aud_dev_cap cap,
                                const void *value)
{
    struct oboe_aud_stream *strm = (struct oboe_aud_stream*)s;
    
    PJ_ASSERT_RETURN(s && value, PJ_EINVAL);

    if (cap==PJMEDIA_AUD_DEV_CAP_OUTPUT_VOLUME_SETTING &&
	(strm->param.dir & PJMEDIA_DIR_PLAYBACK))
    {
        if (strm->playerVol) {
            SLresult res;
            SLmillibel vol, mvol;
            
            res = (*strm->playerVol)->GetMaxVolumeLevel(strm->playerVol,
                                                        &mvol);
            if (res == SL_RESULT_SUCCESS) {
                vol = (SLmillibel)(*(int *)value *
                      ((int)mvol - SL_MILLIBEL_MIN) / 100 + SL_MILLIBEL_MIN);
                res = (*strm->playerVol)->SetVolumeLevel(strm->playerVol,
                                                         vol);
                if (res == SL_RESULT_SUCCESS)
                    return PJ_SUCCESS;
            }
        }
    }

    return PJMEDIA_EAUD_INVCAP;
}

/* API: start stream. */
static pj_status_t strm_start(pjmedia_aud_stream *s)
{
    struct oboe_aud_stream *stream = (struct oboe_aud_stream*)s;
    int i;
    SLresult result = SL_RESULT_SUCCESS;
    
    PJ_LOG(4, (THIS_FILE, "Starting %s stream..", stream->name.ptr));
    stream->quit_flag = 0;

    if (stream->recordBufQ && stream->recordRecord) {
        /* Enqueue an empty buffer to be filled by the recorder
         * (for streaming recording, we need to enqueue at least 2 empty
         * buffers to start things off)
         */
        for (i = 0; i < NUM_BUFFERS-1; i++) {
            result = (*stream->recordBufQ)->Enqueue(stream->recordBufQ,
                                                stream->recordBuffer[i],
                                                stream->recordBufferSize);
            /* The most likely other result is SL_RESULT_BUFFER_INSUFFICIENT,
             * which for this code would indicate a programming error
             */
            pj_assert(result == SL_RESULT_SUCCESS);
        }
        
        result = (*stream->recordRecord)->SetRecordState(
                     stream->recordRecord, SL_RECORDSTATE_RECORDING);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Cannot start recorder"));
            goto on_error;
        }
    }
    
    if (stream->playerPlay && stream->playerBufQ) {
        /* Set the player's state to playing */
        result = (*stream->playerPlay)->SetPlayState(stream->playerPlay,
                                                     SL_PLAYSTATE_PLAYING);
        if (result != SL_RESULT_SUCCESS) {
            PJ_LOG(3, (THIS_FILE, "Cannot start player"));
            goto on_error;
        }
        
        for (i = 0; i < NUM_BUFFERS; i++) {

            
            if(stream->param.headphones_only) //A//
            {
                pj_bzero(stream->playerBuffer[i], stream->playerBufferSize/100*2);
                result = (*stream->playerBufQ)->Enqueue(stream->playerBufQ,
                                                    stream->playerBuffer[i],
                                                    //A//stream->playerBufferSize/100*2);
                                                    stream->playerBufferSize/100); //без *2, т.к. буффер на канал

            } else {
                pj_bzero(stream->playerBuffer[i], stream->playerBufferSize/100);
                result = (*stream->playerBufQ)->Enqueue(stream->playerBufQ,
                                                    stream->playerBuffer[i],
                                                    stream->playerBufferSize/100);
            }
            pj_assert(result == SL_RESULT_SUCCESS);
        }
    }
    
    PJ_LOG(4, (THIS_FILE, "%s stream started", stream->name.ptr));
    return PJ_SUCCESS;
    
on_error:
    if (result != SL_RESULT_SUCCESS)
        strm_stop(&stream->base);
    return oboe_to_pj_error(result);
}

/* API: stop stream. */
static pj_status_t strm_stop(pjmedia_aud_stream *s)
{
    struct oboe_aud_stream *stream = (struct oboe_aud_stream*)s;
    
    if (stream->quit_flag)
        return PJ_SUCCESS;
    
    PJ_LOG(4, (THIS_FILE, "Stopping stream"));
    
    stream->quit_flag = 1;    
    
    if (stream->recordBufQ && stream->recordRecord) {
        /* Stop recording and clear buffer queue */
        (*stream->recordRecord)->SetRecordState(stream->recordRecord,
                                                  SL_RECORDSTATE_STOPPED);
        (*stream->recordBufQ)->Clear(stream->recordBufQ);
    }

    if (stream->playerBufQ && stream->playerPlay) {
        /* Wait until the PCM data is done playing, the buffer queue callback
         * will continue to queue buffers until the entire PCM data has been
         * played. This is indicated by waiting for the count member of the
         * SLBufferQueueState to go to zero.
         */
/*      
        SLresult result;
        W_SLBufferQueueState state;

        result = (*stream->playerBufQ)->GetState(stream->playerBufQ, &state);
        while (state.count) {
            (*stream->playerBufQ)->GetState(stream->playerBufQ, &state);
        } */
        /* Stop player */
        (*stream->playerPlay)->SetPlayState(stream->playerPlay,
                                            SL_PLAYSTATE_STOPPED);
    }

    PJ_LOG(4,(THIS_FILE, "oboe stream stopped"));
    
    return PJ_SUCCESS;
    
}

/* API: destroy stream. */
static pj_status_t strm_destroy(pjmedia_aud_stream *s)
{    
    struct oboe_aud_stream *stream = (struct oboe_aud_stream*)s;
    
    /* Stop the stream */
    strm_stop(s);
    
    if (stream->playerObj) {
        /* Destroy the player */
        (*stream->playerObj)->Destroy(stream->playerObj);
        /* Invalidate all associated interfaces */
        stream->playerObj = NULL;
        stream->playerPlay = NULL;
        stream->playerBufQ = NULL;
        stream->playerVol = NULL;
    }
    
    if (stream->recordObj) {
        /* Destroy the recorder */
        (*stream->recordObj)->Destroy(stream->recordObj);
        /* Invalidate all associated interfaces */
        stream->recordObj = NULL;
        stream->recordRecord = NULL;
        stream->recordBufQ = NULL;
    }
    
    pj_pool_release(stream->pool);
    PJ_LOG(4, (THIS_FILE, "oboe stream destroyed"));
    
    return PJ_SUCCESS;
}

#endif	/* PJMEDIA_AUDIO_DEV_HAS_OBOE */
