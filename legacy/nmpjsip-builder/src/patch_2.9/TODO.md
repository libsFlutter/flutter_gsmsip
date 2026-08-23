    AUDIO_STREAM_DEFAULT          = -1,
    AUDIO_STREAM_MIN              = 0,
    AUDIO_STREAM_VOICE_CALL       = 0,
    AUDIO_STREAM_SYSTEM           = 1,
    AUDIO_STREAM_RING             = 2,
    AUDIO_STREAM_MUSIC            = 3,
    AUDIO_STREAM_ALARM            = 4,
    AUDIO_STREAM_NOTIFICATION     = 5,
    AUDIO_STREAM_BLUETOOTH_SCO    = 6,
    AUDIO_STREAM_ENFORCED_AUDIBLE = 7, /* Sounds that cannot be muted by user
                                        * and must be routed to speaker
                                        */
    AUDIO_STREAM_DTMF             = 8,
    AUDIO_STREAM_TTS              = 9,  /* Transmitted Through Speaker.
                                         * Plays over speaker only, silent on other devices.
                                         */
    AUDIO_STREAM_ACCESSIBILITY    = 10, /* For accessibility talk back prompts */
    AUDIO_STREAM_REROUTING        = 11, /* For dynamic policy output mixes */
    AUDIO_STREAM_PATCH            = 12, /* For internal audio flinger tracks. Fixed volume */
    AUDIO_STREAM_PUBLIC_CNT       = AUDIO_STREAM_TTS + 1,
    AUDIO_STREAM_CNT              = AUDIO_STREAM_PATCH + 1,




    https://android.googlesource.com/platform/system/core/+/dd50edcbe71397ca3be0d2d0b782618921cf859f/include/system/audio.h


MSM
https://android.googlesource.com/platform/hardware/qcom/audio/+/582e0a5e965897ea54ecfa5fe206797dab577a45/msm8909/policy_hal/AudioPolicyManager.cpp
https://github.com/bcyj/android_tools_leeco_msm8996/blob/master/qrdplus/Extension/apps/PhoneFeatures/src/com/qualcomm/qti/phonefeature/CallRecorder.java

https://git.szzt.com/yixing/ticai_src/blob/e4cf598561b3a54559de5643dededf42530b8b41/LA.UM.5.6/LINUX/android/vendor/qcom/proprietary/qrdplus/Extension/apps/PhoneFeatures/src/com/qualcomm/qti/phonefeature/FeatureProvider.java

чтобы запись была не ограничена на qualcomах:
voice.record.conc.disabled=false
voice.voip.conc.disabled=false

Проигрывание
voice.playback.conc.disabled=false
Обходится через AUDIO_STREAM_PATCH

MAGISK

https://github.com/Magisk-Modules-Repo/callrecorder-skvalex/blob/master/README.md
    
VOLTE

https://4pda.ru/pages/go/?u=https%3A%2F%2Fgithub.com%2Fedgd1er%2Fvoenabler&e=95075726



getUnderrunCount


setPerformanceMode PERFORMANCE_MODE_LOW_LATENCY


https://developer.android.com/ndk/guides/audio/aaudio/aaudio


https://android.googlesource.com/platform/frameworks/wilhelm/+/master/include/SLES/OpenSLES.h
https://android.googlesource.com/platform/frameworks/wilhelm/+/master/include/SLES/OpenSLES_AndroidConfiguration.h

https://gist.github.com/hrydgard/3072540 - min opensl
https://raw.githubusercontent.com/google/oboe/master/docs/GettingStarted.md
-min oboe ???




https://github.com/android/ndk-samples/blob/master/hello-oboe/app/src/main/cpp/hello-oboe.cpp
 


https://suvitruf.ru/2014/04/05/3457/android-ndk-rabota-s-opensl-es/


https://github.com/google/oboe/tree/master/samples/hello-oboe/src/main/cpp


Digma Android 7.0 JNI STREAM_CALL - конвертирует СТЕРЕО в МОНО

НУЖЕН 8?


https://www.youtube.com/watch?v=tAChemeSbgo
screenshots+ otg usb


def
https://rossvyaz.ru/about/otkrytoe-pravitelstvo/otkrytye-dannee/reestr-otkrytykh-dannykh
https://phonenum.info/
https://zniis.ru/bdpn/check


AUDIO_DEVICE_IN_VOICE_CALL



opt/replica

WHERE
(numberb>=	79006200000	 and numberb<= 	79006599999	) OR
(numberb>=	79022010000	 and numberb<= 	79022019999	) OR
(numberb>=	79022020000	 and numberb<= 	79022029999	) OR
(numberb>=	79042150000	 and numberb<= 	79042179999	) OR
(numberb>=	79042620000	 and numberb<= 	79042629999	) OR
(numberb>=	79043300000	 and numberb<= 	79043399999	) OR
(numberb>=	79045100000	 and numberb<= 	79045199999	) OR
(numberb>=	79045500000	 and numberb<= 	79045599999	) OR
(numberb>=	79046000000	 and numberb<= 	79046199999	) OR
(numberb>=	79046300000	 and numberb<= 	79046499999	) OR
(numberb>=	79048560000	 and numberb<= 	79048569999	) OR
(numberb>=	79500000000	 and numberb<= 	79500499999	) OR
(numberb>=	79502200000	 and numberb<= 	79502299999	) OR
(numberb>=	79506620000	 and numberb<= 	79506649999	) OR
(numberb>=	79512790000	 and numberb<= 	79512799999	) OR
(numberb>=	79516400000	 and numberb<= 	79516899999	) OR
(numberb>=	79520950000	 and numberb<= 	79520999999	) OR
(numberb>=	79522000000	 and numberb<= 	79522499999	) OR
(numberb>=	79522600000	 and numberb<= 	79522899999	) OR
(numberb>=	79523500000	 and numberb<= 	79523999999	) OR
(numberb>=	79526650000	 and numberb<= 	79526699999	) OR
(numberb>=	79531400000	 and numberb<= 	79531799999	) OR
(numberb>=	79533400000	 and numberb<= 	79533799999	) OR
(numberb>=	79534100000	 and numberb<= 	79534109999	) OR
(numberb>=	79944010000	 and numberb<= 	79944409999	) OR
(numberb>=	79967550000	 and numberb<= 	79967999999	) OR
(numberb>=	79581716100	 and numberb<= 	79581810599	) OR
(numberb>=	79585874000	 and numberb<= 	79585901916	) OR
(numberb>=	79588579950	 and numberb<= 	79588601099	) OR
(numberb>=	79910190000	 and numberb<= 	79910519999	) OR
(numberb>=	79913851000	 and numberb<= 	79913895999	) OR
(numberb>=	79914856000	 and numberb<= 	79914881999	) OR
(numberb>=	79915484000	 and numberb<= 	79915523999	) OR
(numberb>=	79916721000	 and numberb<= 	79916819999	) OR
(numberb>=	79932030000	 and numberb<= 	79932214999	) 

SELECT * FROM `total_numberb` WHERE total_billsec<2147483647 and total_billsec>0 and 
(
(numberb>=	79022010000	 and numberb<= 	79022019999	) OR
(numberb>=	79022020000	 and numberb<= 	79022029999	) OR
(numberb>=	79042150000	 and numberb<= 	79042179999	) OR
(numberb>=	79042620000	 and numberb<= 	79042629999	) OR
(numberb>=	79043300000	 and numberb<= 	79043399999	) OR
(numberb>=	79045100000	 and numberb<= 	79045199999	) OR
(numberb>=	79045500000	 and numberb<= 	79045599999	) OR
(numberb>=	79046000000	 and numberb<= 	79046199999	) OR
(numberb>=	79046300000	 and numberb<= 	79046499999	) OR
(numberb>=	79048560000	 and numberb<= 	79048569999	) OR
(numberb>=	79500000000	 and numberb<= 	79500499999	) OR
(numberb>=	79502200000	 and numberb<= 	79502299999	) OR
(numberb>=	79506620000	 and numberb<= 	79506649999	) OR
(numberb>=	79512790000	 and numberb<= 	79512799999	) OR
(numberb>=	79516400000	 and numberb<= 	79516899999	) OR
(numberb>=	79520950000	 and numberb<= 	79520999999	) OR
(numberb>=	79522000000	 and numberb<= 	79522499999	) OR
(numberb>=	79522600000	 and numberb<= 	79522899999	) OR
(numberb>=	79523500000	 and numberb<= 	79523999999	) OR
(numberb>=	79526650000	 and numberb<= 	79526699999	) OR
(numberb>=	79531400000	 and numberb<= 	79531799999	) OR
(numberb>=	79533400000	 and numberb<= 	79533799999	) OR
(numberb>=	79534100000	 and numberb<= 	79534109999	) OR
(numberb>=	79944010000	 and numberb<= 	79944409999	) OR
(numberb>=	79967550000	 and numberb<= 	79967999999	) OR
(numberb>=	79581716100	 and numberb<= 	79581810599	) OR
(numberb>=	79585874000	 and numberb<= 	79585901916	) OR
(numberb>=	79588579950	 and numberb<= 	79588601099	) OR
(numberb>=	79910190000	 and numberb<= 	79910519999	) OR
(numberb>=	79913851000	 and numberb<= 	79913895999	) OR
(numberb>=	79914856000	 and numberb<= 	79914881999	) OR
(numberb>=	79915484000	 and numberb<= 	79915523999	) OR
(numberb>=	79916721000	 and numberb<= 	79916819999	) OR
(numberb>=	79932030000	 and numberb<= 	79932214999	))
ORDER BY total_billsec DESC, total_answered ASC, total_calls DESC
LIMIT 1000