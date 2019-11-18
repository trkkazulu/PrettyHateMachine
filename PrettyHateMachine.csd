; PrettyHateMachine.csd
; Written by Jair-Rohm Parker Wells 2019

<Cabbage>
form caption("Pretty Hate Machine"), size(700, 100), pluginid("phm1"), style("legacy"), bundle("brushed metal background 1305.jpg")

image colour(165, 42, 42, 255), outlinethickness(4), bounds(0, 0, 700, 100), corners(5), file("brushed metal background 1305.jpg")

vmeter   bounds(20, 10, 15, 80) channel("Meter") value(0) outlinecolour("black"), overlaycolour(20, 3, 3,255) metercolour:0(255,100,100,255) metercolour:1(255,150,155, 255) metercolour:2(255,255,123, 255) outlinethickness(3) 
rslider bounds(40, 10, 75, 75) channel("sens") colour(255, 100, 100, 255) range(0, 1, 0.65, 1, 0.001) text("Guilt") textcolour(255, 255, 200, 255) trackercolour(255, 255, 150, 255)
rslider bounds(40, 10, 75, 75), text("Guilt"), channel("sens"),  range(0, 1, 0.65, 1, 0.001),                   colour(255, 100, 100, 255), textcolour(0, 0, 0, 255), trackercolour(255, 255, 150, 255) value(0.65)
rslider bounds(110, 6, 45, 45), text("Att."),        channel("att"),   range(0.001, 0.5, 0.01, 0.5, 0.001), colour(255, 200, 100, 255), textcolour(0, 0, 0, 255), trackercolour(255, 255, 150, 255) value(0.01)
rslider bounds(110, 50, 45, 45), text("Dec."),        channel("rel"),   range(0.001, 0.5, 0.2, 0.5, 0.001),  colour(255, 200, 100, 255), textcolour(0, 0, 0, 255), trackercolour(255, 255, 150, 255) value(0.2)
rslider bounds(150, 10, 75, 75), text("Debasement"),   channel("freq"),  range(10, 10000, 1000, 0.5, 0.001),colour(255, 100, 100, 255), textcolour(0, 0, 0, 255), trackercolour(255, 255, 150, 255) value(1000)
;label    bounds(225, 15, 85, 14), text("Type"), fontcolour(255,255,200)
;combobox bounds(225, 30, 85, 20), text("lpf18","tone"), value("1"), channel("type")
rslider bounds(420, 10, 75, 75), text("Praise"),channel("res"),   range(0, 1, 0.75, 1, 0.001),colour(255, 100, 100, 255), textcolour(255, 255, 200, 255), trackercolour(255, 255, 150, 255), identchannel("resID")

rslider bounds(490, 10, 75, 75), text("Hate"),  channel("dist"),  range(0, 0.2, 0, 1, 0.001),colour(255, 100, 100, 255), textcolour(255, 255, 200, 255), trackercolour(255, 255, 150, 255), identchannel("distID")
rslider bounds(560, 10, 75, 75), text("Output"), channel("level"), range(0, 10, 0, 1, 0.001), colour(255, 200, 100, 255), textcolour(255, 255, 200, 255), trackercolour(255, 255, 150, 255)

checkbox bounds(324, 28, 78, 31) text("Out"),channel("oct"), radiogroup("99") colour:1(255, 0, 0, 255)
checkbox bounds(324, 60, 78, 32) text("In"),channel("oct"), radiogroup("99")value(1)  
label bounds(324, 10, 78, 17) text("Octave")
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-d -n
</CsOptions>
<CsInstruments>

;sr is set by the host
ksmps = 64
nchnls = 2
0dbfs = 1


;- Region: UDOs
opcode	EnvelopeFollower,a,akkkkkkk
	ain,ksens,katt,krel,kfreq,ktype,kres,kdist	xin	
	setksmps	4
	;				     ATTCK.REL.  -  ADJUST THE RESPONSE OF THE ENVELOPE FOLLOWER HERE
	aFollow		follow2		ain, katt, krel			; AMPLITUDE FOLLOWING AUDIO SIGNAL
	kFollow		downsamp	aFollow				; DOWNSAMPLE TO K-RATE
	kFollow		expcurve	kFollow/0dbfs,0.5		; ADJUSTMENT OF THE RESPONSE OF DYNAMICS TO FILTER FREQUENCY MODULATION
	kFrq		=		kfreq + (kFollow*ksens*10000)	; CREATE A LEFT CHANNEL MODULATING FREQUENCY BASE ON THE STATIC VALUE CREATED BY kfreq AND THE AMOUNT OF DYNAMIC ENVELOPE FOLLOWING GOVERNED BY ksens
	kFrq		limit		kFrq, 20,sr/2			; LIMIT FREQUENCY RANGE TO PREVENT OUT OF RANGE FREQUENCIES  
	if ktype==1 then
	 aout		lpf18		ain, kFrq, kres, kdist		; pass sig to 3 pole low pass filter
	elseif ktype==2 then
;	 aout		moogladder	ain, kFrq, kres			; REDEFINE AUDIO SIGNAL AS FILTERED VERSION OF ITSELF
	elseif ktype==3 then
	 aFrq	interp	kFrq
;	 aout		butlp		ain, aFrq			; REDEFINE AUDIO SIGNAL AS FILTERED VERSION OF ITSELF
	elseif ktype==4 then
	 aout		tone		ain, kFrq			; REDEFINE AUDIO SIGNAL AS FILTERED VERSION OF ITSELF
	endif
			xout		aout				; SEND AUDIO BACK TO CALLER INSTRUMENT
endop

opcode	SwitchPort, k, kii
	kin,iupport,idnport	xin
	kold			init	0
	kporttime		=	(kin<kold?idnport:iupport)
	kout			portk	kin, kporttime
	kold			=	kout
				xout	kout
endop

opcode	OctaveDivider,a,akkk
	ain,kdivider,kInputFilt,kToneFilt	xin
	krms	rms		ain
		setksmps	1		;SET kr=sr, ksmps=1 (sample)
	kcount	init		0		;COUNTER USED TO COUNT ZERO CROSSINGS
	kout	init		-1		;INITIAL DISPOSITION OF OUTPUT SIGNAL
	ain	butlp		ain,kInputFilt	;LOWPASS FILTER THE INPUT SIGNAL (TO REMOVE SOME HF OVERTONE MATERIAL)
	ain	butlp		ain,kInputFilt	;LOWPASS FILTER THE INPUT SIGNAL (TO REMOVE SOME HF OVERTONE MATERIAL)
	ain	butlp		ain,kInputFilt	;LOWPASS FILTER THE INPUT SIGNAL (TO REMOVE SOME HF OVERTONE MATERIAL)
	ksig	downsamp	ain		;CREATE A K-RATE VERSION OF THE INPUT AUDIO SIGNAL
	ktrig	trigger		ksig,0,2	;IF THE INPUT AUDIO SIGNAL (K-RATE VERSION) CROSSES ZERO IN EITHER DIRECTION, GENERATE A TRIGGER
	if ktrig==1 then			;IF A TRIGGER HAS BEEN GENERATED...
	 kcount	wrap	kcount+1,0,kdivider	;INCREMENT COUNTER BUT WRAPAROUND ACCORDING TO THE NUMBER OF FREQUENCY DIVISIONS REQUIRED
	 if kcount=0 then			;IF WE HAVE COMPLETED A DIVISION BLOCK (I.E. COUNTER HAS JUST WRAPPED AROUND)...
	  kout =	(kout=-1?1:-1)		;FLIP THE OUTPUT SIGNAL BETWEEN -1 AND 1 (THIS WILL CREATE A SQUARE WAVE)
	 endif
	endif
	aout	upsamp		kout		;CREATE A-RATE SIGNAL FROM K-RATE SIGNAL
	aout	butlp		aout,kToneFilt	;FILTER THE OUTPUT TONE
		xout		aout*krms	;SEND AUDIO BACK TO CALLER INSTRUMENT, SCALE ACCORDING TO THE ENVELOPE FOLLOW OF THE INPUT SIGNAL
endop

kratio = 1
iNIter = 0.5
kDelay = 0.5
kSmooth = 0.5
imaxdelay = 0.5
iwfn = 1
iCount = 0


instr 1
ksens chnget "sens"
katt chnget "att"
krel chnget "rel"
kfreq chnget "freq"
;ktype chnget "type"
ktype	init	1
kres chnget "res"
kdist chnget "dist"
klevel chnget "level"
kOct chnget "oct"



if changed:k(ktype)==1 then
 if ktype==1 then
  chnset	"visible(1)","distID"
  chnset	"visible(1)","resID"
 elseif ktype==2 then
  chnset	"visible(0)","distID"
  chnset	"visible(1)","resID"
 else
  chnset	"visible(0)","distID"
  chnset	"visible(0)","resID"
 endif
endif


;- Region: Input Section

a1 inch 1
a2 inch 2
;a1,a2	diskin2 "bassCR.wav", 1,1,1	

/*level meter*/
amix	sum	a1,a2
krms	rms	amix*0.5
krms	pow	krms,0.75
krms	SwitchPort	krms,0.01,0.05
		chnset	krms,"Meter"

a1	EnvelopeFollower	a1,ksens,katt,krel,kfreq,ktype,kres*0.95,kdist*100

a2	EnvelopeFollower	a2,ksens,katt,krel,kfreq,ktype,kres*0.95,kdist*100

a1	=	a1 * klevel * (1 - ((kdist*0.3)^0.02))	;scale amplitude according to distortion level so that it doesn't blow up
a2	=	a2 * klevel * (1 - ((kdist*0.3)^0.02))
	outs	a1*klevel, a2*klevel
endin

</CsInstruments>
<CsScore>
i 1 0 [60*60*24*7]
</CsScore>
</CsoundSynthesizer>