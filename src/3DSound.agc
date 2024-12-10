
#include "Util.agc"

#constant SOUND3D_SCALE		 			1.0
#constant SOUND3D_DOPPLER	 			1
#constant SOUND3D_DOPPLER_INTENSITY		0.1

global Sound3d as Sound3d_def[]

type Sound3d_def
	leftsnd as integer
	rightsnd as integer
	leftinsnum as integer
	rightinsnum as integer
	X# as float
	Y# as float
	Z# as float
	lastdis# as float
	play as integer
	initvol# as float
	nearmul# as float
	rate# as float
	doppler as integer
endtype

// 3d Sound Library
// ================
function Create3dSound(snd,X#,Y#,Z#,initvol#,nearmul#,playing,rate#,doppler)

	if Sound3d.length=-1
		dim Sound3d[] as Sound3d_def
	endif

	Sound3d.length=Sound3d.length+1
	pos = Sound3d.length
	
	SplitAudio(pos,snd)
	
	leftIns = PlaySound(Sound3d[pos].leftsnd,0.0,playing)
	rightIns = PlaySound(Sound3d[pos].rightsnd,0.0,playing)
	SetSoundInstanceRate(leftIns,rate#)
	SetSoundInstanceRate(rightIns,rate#)

	Sound3d[pos].leftinsnum = leftIns
	Sound3d[pos].rightinsnum = rightIns
	
	Sound3d[pos].X# = X#
	Sound3d[pos].Y# = Y#
	Sound3d[pos].Z# = Z#
	Sound3d[pos].play = playing	
	Sound3d[pos].initvol# = initvol#
	Sound3d[pos].nearmul# = nearmul#
	Sound3d[pos].rate# = rate#
	Sound3d[pos].doppler = doppler
	
endfunction pos

function Set3dSoundPosition(pos,X#,Y#,Z#)
	Sound3d[pos].X# = X#
	Sound3d[pos].Y# = Y#
	Sound3d[pos].Z# = Z#

endfunction

function Set3dSoundVolume(pos,initvol#,nearmul#)
	Sound3d[pos].initvol# = initvol#
	Sound3d[pos].nearmul# = nearmul#
endfunction

function Set3dSoundRate(pos,rate#)
	Sound3d[pos].rate# = rate#
endfunction

function Play3dSound(pos,playing)
	Sound3d[pos].play = playing	
	lsnd = Sound3d[pos].leftsnd
	rsnd = Sound3d[pos].rightsnd
	rate# = Sound3d[pos].rate#
	lins = PlaySound(lsnd,10.0,playing)
	rins = PlaySound(rsnd,10.0,playing)
	SetSoundInstanceRate( lins, rate# ) 
	SetSoundInstanceRate( rins, rate# ) 
	Sound3d[pos].leftinsnum = lins
	Sound3d[pos].rightinsnum = rins
	
endfunction

function Stop3dSound(pos)
	StopSoundInstance(Sound3d[pos].leftinsnum)
	StopSoundInstance(Sound3d[pos].rightinsnum)
	
	DeleteSound(Sound3d[pos].leftsnd)
	DeleteSound(Sound3d[pos].rightsnd)
	
	Sound3d.remove(pos)
endfunction

function Update3dSound()

	CamX# = GetCameraX(1)
	CamY# = GetCameraY(1)
	CamZ# = GetCameraZ(1)


	for pos =0 to Sound3d.length
		
		leftIns = Sound3d[pos].leftinsnum
		rightIns = Sound3d[pos].rightinsnum
		
	
		if GetSoundInstancePlaying(leftIns)=1 and GetSoundInstancePlaying(rightIns)=1 
			X# = Sound3d[pos].X#
			Y# = Sound3d[pos].Y#
			Z# = Sound3d[pos].Z#			
			dis# = Get3dDistance(CamX#,CamY#,CamZ#,X#,Y#,Z#)
			initvol# = Sound3d[pos].initvol#
			nearmul# = Sound3d[pos].nearmul#
			
			vol# = initvol#-(((dis#/10.0)/SOUND3D_SCALE)^2)*(1/nearmul#)
			if vol#>0.0
						
				bal# = sin(atan2(CamX#-X#,CamZ#-Z#)-GetCameraAngleY(1)+180.0)
				Print("Balance: "+str(bal#)+" Volume: "+str(vol#))
				SetSoundInstanceVolume(leftIns,vol#*(abs(bal#-1.0)/2)) 
				SetSoundInstanceVolume(rightIns,vol#*((bal#+1.0)/2))
				
				if SOUND3D_DOPPLER = 1 and Sound3d[pos].doppler = 1
					
					absrate# = ((dis#-Sound3d[pos].lastdis#)*SOUND3D_DOPPLER_INTENSITY)
					if absrate#<-SOUND3D_DOPPLER_INTENSITY then absrate#=-SOUND3D_DOPPLER_INTENSITY
					if absrate#>SOUND3D_DOPPLER_INTENSITY then absrate#=SOUND3D_DOPPLER_INTENSITY
					rate# = Sound3d[pos].rate#-absrate#		
					SetSoundInstanceRate(leftIns,(rate#+GetSoundInstanceRate(leftIns))/2)
					SetSoundInstanceRate(rightIns,(rate#+GetSoundInstanceRate(rightIns))/2)
					
				else	
					rate# = Sound3d[pos].rate#		
					SetSoundInstanceRate(leftIns,rate#)
					SetSoundInstanceRate(rightIns,rate#)
				endif
				
			else
				SetSoundInstanceVolume(leftIns,0.0)
				SetSoundInstanceVolume(rightIns,0.0)
			endif
			
			Sound3d[pos].lastdis# = dis#
			
		else
			Sound3d.remove(pos)
		endif


	next pos

endfunction

function SplitAudio(pos, soundId)
	soundMemblock = CreatememblockFromSound(soundId)
	
	numChannel = GetMemblockByte(soundMemblock, 0)                                                //Number of Channels (1 or 2)
	bitsPerSample = GetMemblockByte(soundMemblock, 2)                                             //Bit Depth (example: 16bit)
	samplesPerSecond = GetMemblockInt(soundMemblock, 4)                                   //Sample Rate (example: 44100)
	numFrames = GetMemblockInt(soundMemblock, 8)                                                  //Number of frames in the sound data
	
	bytesPerSample = bitsPerSample/8                                             

	//Check for bitdepth limit
	if bitsPerSample>16
		exitfunction
	endif

	//If we start with a mono sound then return failure
	if numChannel<=1
		exitfunction
	endif
	
	dataOffset = 12
	dataSize = dataOffset + numFrames*bytesPerSample*numChannel
	
	leftChannelMemblock = CreateMemblock(dataSize)
	rightChannelMemblock = CreateMemblock(dataSize)
	
	//Sound info header
	SetMemblockByte(leftChannelMemblock, 0, 2)
	SetMemblockByte(leftChannelMemblock, 2, bitsPerSample)
	SetMemblockInt (leftChannelMemblock, 4, samplesPerSecond)
	SetMemblockInt (leftChannelMemblock, 8, numFrames)
	
	//Sound info header
	SetMemblockByte(rightChannelMemblock, 0, 2)
	SetMemblockByte(rightChannelMemblock, 2, bitsPerSample)
	SetMemblockInt (rightChannelMemblock, 4, samplesPerSecond)
	SetMemblockInt (rightChannelMemblock, 8, numFrames)
	
	//Copy audio data
	for i=0 to numFrames-1
		for b=0 to bytesPerSample-1
			SetMemblockByte(leftChannelMemblock,dataOffset+(i*bytesPerSample*2)+b,GetMemblockByte(soundMemblock,dataOffset+(i*bytesPerSample*2)+b))
			SetMemblockByte(rightChannelMemblock,dataOffset+((i*2+1)*bytesPerSample)+b,GetMemblockByte(soundMemblock,dataOffset+((i*2+1)*bytesPerSample)+b))
		next b
	next i
	
	Sound3d[pos].leftsnd = CreateSoundFromMemblock(leftChannelMemblock)
	Sound3d[pos].rightsnd = CreateSoundFromMemblock(rightChannelMemblock)
	
	DeleteMemblock(rightChannelMemblock)
	DeleteMemblock(leftChannelMemblock)
	DeleteMemblock(soundMemblock)
endfunction