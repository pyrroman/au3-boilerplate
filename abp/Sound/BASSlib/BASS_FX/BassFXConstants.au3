; ==========================================================================================================================================================
; Error codes returned by BASS_ErrorGetCode()
; ==========================================================================================================================================================
Global Const $BASS_ERROR_FX_NODECODE = 4000;    // Not a decoding channel
Global Const $BASS_ERROR_FX_BPMINUSE = 4001;    // BPM/Beat detection is in use

; ==========================================================================================================================================================
; Tempo / Reverse / BPM / Beat flag
; ==========================================================================================================================================================
Global Const $BASS_FX_FREESOURCE = 0x10000;      // Free the source handle as well?

; ==========================================================================================================================================================
; DSP channels flags
; ==========================================================================================================================================================
Global Const $BASS_BFX_CHANALL = -1;     // all channels at once (as by default)
Global Const $BASS_BFX_CHANNONE = 0;     // disable an effect for all channels
Global Const $BASS_BFX_CHAN1 = 1;        // left-front channel
Global Const $BASS_BFX_CHAN2 = 2;        // right-front channel
Global Const $BASS_BFX_CHAN3 = 4;        // see above info
Global Const $BASS_BFX_CHAN4 = 8;        // see above info
Global Const $BASS_BFX_CHAN5 = 16;       // see above info
Global Const $BASS_BFX_CHAN6 = 32;       // see above info
Global Const $BASS_BFX_CHAN7 = 64;       // see above info
Global Const $BASS_BFX_CHAN8 = 128;      // see above info

; ==========================================================================================================================================================
; DSP effects
; ==========================================================================================================================================================
Global Const $BASS_FX_BFX_ROTATE = "BASS_FX_BFX_ROTATE"
Global Const $BASS_FX_BFX_ROTATE_VALUE = 0x10000
Global Const $BASS_FX_BFX_ECHO = "BASS_FX_BFX_ECHO"
Global Const $BASS_FX_BFX_ECHO_VALUE = 0x10001
Global Const $BASS_FX_BFX_FLANGER = "BASS_FX_BFX_FLANGER"
Global Const $BASS_FX_BFX_FLANGER_VALUE = 0x10002
Global Const $BASS_FX_BFX_VOLUME = "BASS_FX_BFX_VOLUME"
Global Const $BASS_FX_BFX_VOLUME_VALUE = 0x10003
Global Const $BASS_FX_BFX_PEAKEQ = "BASS_FX_BFX_PEAKEQ"
Global Const $BASS_FX_BFX_PEAKEQ_VALUE = 0x10004
Global Const $BASS_FX_BFX_REVERB = "BASS_FX_BFX_REVERB"
Global Const $BASS_FX_BFX_REVERB_VALUE = 0x10005
Global Const $BASS_FX_BFX_LPF = "BASS_FX_BFX_LPF"
Global Const $BASS_FX_BFX_LPF_VALUE = 0x10006
Global Const $BASS_FX_BFX_MIX = "BASS_FX_BFX_MIX"
Global Const $BASS_FX_BFX_MIX_VALUE = 0x10007
Global Const $BASS_FX_BFX_DAMP = "BASS_FX_BFX_DAMP"
Global Const $BASS_FX_BFX_DAMP_VALUE = 0x10008
Global Const $BASS_FX_BFX_AUTOWAH = "BASS_FX_BFX_AUTOWAH"
Global Const $BASS_FX_BFX_AUTOWAH_VALUE = 0x10009
Global Const $BASS_FX_BFX_ECHO2 = "BASS_FX_BFX_ECHO2"
Global Const $BASS_FX_BFX_ECHO2_VALUE = 0x1000A
Global Const $BASS_FX_BFX_PHASER = "BASS_FX_BFX_PHASER"
Global Const $BASS_FX_BFX_PHASER_VALUE = 0x1000B
Global Const $BASS_FX_BFX_ECHO3 = "BASS_FX_BFX_ECHO3"
Global Const $BASS_FX_BFX_ECHO3_VALUE = 0x1000C
Global Const $BASS_FX_BFX_CHORUS = "BASS_FX_BFX_CHORUS"
Global Const $BASS_FX_BFX_CHORUS_VALUE = 0x1000D
Global Const $BASS_FX_BFX_APF = "BASS_FX_BFX_APF"
Global Const $BASS_FX_BFX_APF_VALUE = 0x1000E
Global Const $BASS_FX_BFX_COMPRESSOR = "BASS_FX_BFX_COMPRESSOR"
Global Const $BASS_FX_BFX_COMPRESSOR_VALUE = 0x1000F
Global Const $BASS_FX_BFX_DISTORTION = "BASS_FX_BFX_DISTORTION"
Global Const $BASS_FX_BFX_DISTORTION_VALUE = 0x10010
Global Const $BASS_FX_BFX_COMPRESSOR2 = "BASS_FX_BFX_COMPRESSOR2"
Global Const $BASS_FX_BFX_COMPRESSOR2_VALUE = 0x10011

Global Const $BASS_BFX_ECHO = 'float;' & _			;fLevel			[0....1....n] linear
		'Int;' ;lDelay :		[1200..30000]

Global Const $BASS_BFX_FLANGER = 'float;' & _		;fWetDry		[0....1....n] linear
		'float;' & _      							;fSpeed			[0......0.09]
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

Global Const $BASS_BFX_VOLUME = 'Int;' & _			;lChannel		BASS_BFX_CHANxxx flag/s or 0 for global volume control
		'float;' ;fVolume		[0....1....n] linear

Global Const $BASS_BFX_PEAKEQ = 'Int;' & _			;lBand			[0...............n] more bands means more memory & cpu usage
		'float;' & _       							;fBandwidth		[0.1.....4.......n] in octaves - Q is not in use (BW has a priority over Q)
		'float;' & _        						;fQ				[0.......1.......n] the EE kinda definition (linear) (if Bandwidth is not in use)
		'float;' & _    							;fCenter		[1Hz..<info.freq/2] in Hz
		'float;' & _      							;fGain			[-15dB...0...+15dB] in dB
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

Global Const $BASS_BFX_REVERB = 'float;' & _		;fLevel			[0....1....n] linear
		'Int;' ;lDelay			[1200..10000]

Global Const $BASS_BFX_LPF = 'float;' & _			;fResonance		[0.01............10]
		'float;' & _     							;fCutOffFreq	[1Hz....info.freq/2] cutoff frequency
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

Global Const $BASS_BFX_DAMP = 'float;' & _			;fTarget		target volume level                      [0<......1] linear
		'float;' & _        						;fQuiet			quiet  volume level                      [0.......1] linear
		'float;' & _      							;fRate			amp adjustment rate                      [0.......1] linear
		'float;' & _      							;fGain			amplification level                      [0...1...n] linear
		'float;' & _        						;fDelay			delay in seconds before increasing level [0.......n] linear
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

Global Const $BASS_BFX_AUTOWAH = 'float;' & _		;fDryMix		dry (unaffected) signal mix              [-2......2]
		'float;' & _        						;fWetMix		wet (affected) signal mix                [-2......2]
		'float;' & _         						;fFeedback		feedback                                 [-1......1]
		'float;' & _      							;fRate			rate of sweep in cycles per second       [0<....<10]
		'float;' & _       							;fRange			sweep range in octaves                   [0<....<10]
		'float;' & _       							;fFreq			base frequency of sweep Hz               [0<...1000]
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

Global Const $BASS_BFX_ECHO2 = 'float;' & _			;fDryMix		dry (unaffected) signal mix              [-2......2]
		'float;' & _      							;fWetMix		wet (affected) signal mix                [-2......2]
		'float;' & _        						;fFeedback		feedback                                 [-1......1]
		'float;' & _       							;fDelay			delay sec                                [0<......6]
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

Global Const $BASS_BFX_PHASER = 'float;' & _		;fDryMix		dry (unaffected) signal mix              [-2......2]
		'float;' & _       							;fWetMix		wet (affected) signal mix                [-2......2]
		'float;' & _       							;fFeedback		feedback                                 [-1......1]
		'float;' & _        						;fRate			rate of sweep in cycles per second       [0<....<10]
		'float;' & _      							;fRange			sweep range in octaves                   [0<....<10]
		'float;' & _       							;fFreq			base frequency of sweep                  [0<...1000]
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

Global Const $BASS_BFX_ECHO3 = 'float;' & _			;fDryMix		dry (unaffected) signal mix              [-2......2]
		'float;' & _     							;fWetMix		wet (affected) signal mix                [-2......2]
		'float;' & _      							;fDelay			delay sec                                [0<......6]
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

Global Const $BASS_BFX_CHORUS = 'float;' & _		;fDryMix		dry (unaffected) signal mix              [-2......2]
		'float;' & _      							;fWetMix		wet (affected) signal mix                [-2......2]
		'float;' & _      							;fFeedback		feedback                                 [-1......1]
		'float;' & _     							;fMinSweep		minimal delay ms                         [0<..<6000]
		'float;' & _    							;fMaxSweep		maximum delay ms                         [0<..<6000]
		'float;' & _      							;fRate			rate ms/s                                [0<...1000]
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

Global Const $BASS_BFX_APF = 'float;' & _			;fGain			reverberation time                       [-1=<..<=1]
		'float;' & _      							;fDelay			delay sec                                [0<....<=6]
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

Global Const $BASS_BFX_COMPRESSOR = 'float;' & _	;fThreshold		compressor threshold                     [0<=...<=1]
		'float;' & _   								;fAttacktime	attack time ms                           [0<.<=1000]
		'float;' & _    							;fReleasetime	release time ms                          [0<.<=5000]
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

Global Const $BASS_BFX_DISTORTION = 'float;' & _	;fDrive			distortion drive                         [0<=...<=5]
		'float;' & _       							;fDryMix		dry (unaffected) signal mix              [-5<=..<=5]
		'float;' & _      							;fWetMix		wet (affected) signal mix                [-5<=..<=5]
		'float;' & _      							;fFeedback		feedback                                 [-1<=..<=1]
		'float;' & _       							;fVolume		distortion volume                        [0=<...<=2]
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

Global Const $BASS_BFX_COMPRESSOR2 = 'float;' & _	;fGain			output gain of signal after compression  [-60....60] in dB
		'float;' & _      							;fThreshold		point at which compression begins        [-60.....0] in dB
		'float;' & _      							;fRatio			compression ratio                        [1.......n]
		'float;' & _     							;fAttack		attack time in ms                        [0.01.1000]
		'float;' & _      							;fRelease		release time in ms                       [0.01.5000]
		'Int;' ;lChannel		BASS_BFX_CHANxxx flag/s

; ==========================================================================================================================================================
; tempo attributes (BASS_ChannelSet/GetAttribute)
; ==========================================================================================================================================================
Global Const $BASS_ATTRIB_TEMPO = 0x10000;
Global Const $BASS_ATTRIB_TEMPO_PITCH = 0x10001;
Global Const $BASS_ATTRIB_TEMPO_FREQ = 0x10002;

; ==========================================================================================================================================================
; tempo attributes options
; ==========================================================================================================================================================
Global Const $BASS_ATTRIB_TEMPO_OPTION_USE_AA_FILTER = 0x10010;    // TRUE / FALSE
Global Const $BASS_ATTRIB_TEMPO_OPTION_AA_FILTER_LENGTH = 0x10011;    // 32 default (8 .. 128 taps)
Global Const $BASS_ATTRIB_TEMPO_OPTION_USE_QUICKALGO = 0x10012;    // TRUE / FALSE
Global Const $BASS_ATTRIB_TEMPO_OPTION_SEQUENCE_MS = 0x10013;    // 82 default
Global Const $BASS_ATTRIB_TEMPO_OPTION_SEEKWINDOW_MS = 0x10014;    // 14 default
Global Const $BASS_ATTRIB_TEMPO_OPTION_OVERLAP_MS = 0x10015;    // 12 default

; ==========================================================================================================================================================
; reverse attribute (BASS_ChannelSet/GetAttribute)
; ==========================================================================================================================================================
Global Const $BASS_ATTRIB_REVERSE_DIR = 0x11000;

; ==========================================================================================================================================================
; playback directions
; ==========================================================================================================================================================
Global Const $BASS_FX_RVS_REVERSE = -1;
Global Const $BASS_FX_RVS_FORWARD = 1;

; ==========================================================================================================================================================
; bpm flags
; ==========================================================================================================================================================
Global Const $BASS_FX_BPM_BKGRND = 1;   // if in use, then you can do other processing while detection's in progress. (BPM/Beat)
Global Const $BASS_FX_BPM_MULT2 = 2;   // if in use, then will auto multiply bpm by 2 (if BPM < MinBPM*2)

; ==========================================================================================================================================================
; translation options
; ==========================================================================================================================================================
Global Const $BASS_FX_BPM_TRAN_X2 = 0;     // multiply the original BPM value by 2 (may be called only once & will change the original BPM as well!)
Global Const $BASS_FX_BPM_TRAN_2FREQ = 1;     // BPM value to Frequency
Global Const $BASS_FX_BPM_TRAN_FREQ2 = 2;     // Frequency to BPM value
Global Const $BASS_FX_BPM_TRAN_2PERCENT = 3;     // BPM value to Percents
Global Const $BASS_FX_BPM_TRAN_PERCENT2 = 4;     // Percents to BPM value