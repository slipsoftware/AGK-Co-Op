#constant Sound3D_SCALE		 			1.0
#constant Sound3D_Doppler	 			1
#constant Sound3D_Doppler_INTENSITY		0.1

type Sound3DData
	LeftSoundID as integer
	RightSoundID as integer
	LeftInstanceID as integer
	RightInstanceID as integer
	X# as float
	Y# as float
	Z# as float
	LastDist# as float
	Looping as integer
	InitVolume# as float
	NearMul# as float
	Rate# as float
	Doppler as integer
endtype

global Sound3D as Sound3DData[]

// 3D Sound Library
// ================
function Sound3D_Create(SoundID, X#, Y#, Z#, InitVolume#, NearMul#, Looping, Rate#, Doppler)
	local TempSound3D as Sound3DData
	local LeftInstanceID as integer
	local RightInstanceID as integer

	TempSound3D.X# = X#
	TempSound3D.Y# = Y#
	TempSound3D.Z# = Z#
	TempSound3D.Looping = Looping
	TempSound3D.InitVolume# = InitVolume#
	TempSound3D.NearMul# = NearMul#
	TempSound3D.Rate# = Rate#
	TempSound3D.Doppler = Doppler
	
	Sound3D_SplitAudio(TempSound3D, SoundID)

	LeftInstanceID = PlaySound(TempSound3D.LeftSoundID, 0.0, Looping)
	RightInstanceID = PlaySound(TempSound3D.RightSoundID, 0.0, Looping)
	SetSoundInstanceRate(LeftInstanceID, Rate#)
	SetSoundInstanceRate(RightInstanceID, Rate#)
	
	TempSound3D.LeftInstanceID = LeftInstanceID
	TempSound3D.RightInstanceID = RightInstanceID

	Sound3D.insert(TempSound3D)
endfunction Sound3D.length

function Sound3D_SetPosition(ID,X#,Y#,Z#)
	Sound3D[ID].X# = X#
	Sound3D[ID].Y# = Y#
	Sound3D[ID].Z# = Z#
endfunction

function Sound3D_SetVolume(ID, InitVolume#, NearMul#)
	Sound3D[ID].InitVolume# = InitVolume#
	Sound3D[ID].NearMul# = NearMul#
endfunction

function Sound3D_SetRate(ID,Rate#)
	Sound3D[ID].Rate# = Rate#
endfunction

function Sound3D_Play(ID, Looping)
	local LeftInstanceID as integer
	local RightInstanceID as integer

	LeftInstanceID = PlaySound(Sound3D[ID].LeftSoundID, 0.0, Looping)
	RightInstanceID = PlaySound(Sound3D[ID].RightSoundID, 0.0, Looping)
	SetSoundInstanceRate( LeftInstanceID, Sound3D[ID].Rate# )
	SetSoundInstanceRate( RightInstanceID, Sound3D[ID].Rate# )

	Sound3D[ID].Looping = Looping
	Sound3D[ID].LeftInstanceID = LeftInstanceID
	Sound3D[ID].RightInstanceID = RightInstanceID
endfunction

function Sound3D_Stop(ID)
	StopSoundInstance(Sound3D[ID].LeftInstanceID)
	StopSoundInstance(Sound3D[ID].RightInstanceID)
endfunction

function Sound3D_Delete(ID)
	StopSoundInstance(Sound3D[ID].LeftInstanceID)
	StopSoundInstance(Sound3D[ID].RightInstanceID)

	DeleteSound(Sound3D[ID].LeftSoundID)
	DeleteSound(Sound3D[ID].RightSoundID)
	
	Sound3D.remove(ID)
endfunction

function Sound3D_Update()
	local ID as integer
	local LeftInstanceID as integer
	local RightInstanceID as integer
	local CameraX# as float
	local CameraY# as float
	local CameraZ# as float
	local InitVolume# as float
	local NearMul# as float
	local Volume# as float
	local Balance# as float
	local AbsRate# as float
	local Dist# as float
	local Rate# as float
	local X# as float
	local Y# as float
	local Z# as float

	CameraX# = GetCameraX(1)
	CameraY# = GetCameraY(1)
	CameraZ# = GetCameraZ(1)

	for ID = 0 to Sound3D.length
		LeftInstanceID = Sound3D[ID].LeftInstanceID
		RightInstanceID = Sound3D[ID].RightInstanceID
		
		if GetSoundInstancePlaying(LeftInstanceID)=1 and GetSoundInstancePlaying(RightInstanceID)=1 
			X# = Sound3D[ID].X#
			Y# = Sound3D[ID].Y#
			Z# = Sound3D[ID].Z#

			Dist# = Core_Distance3D(CameraX#, CameraY#, CameraZ#, X#, Y#, Z#)
			InitVolume# = Sound3D[ID].InitVolume#
			NearMul# = Sound3D[ID].NearMul#
			
			Volume# = InitVolume# - (((Dist# / 10.0) / Sound3D_SCALE) ^ 2) * (1 / NearMul#)
			if Volume# > 0.0
				Balance# = sin(atan2(CameraX# - X#, CameraZ# - Z#) - GetCameraAngleY(1) + 180.0)
				SetSoundInstanceVolume(LeftInstanceID, Volume# * (abs(Balance# - 1.0) / 2)) 
				SetSoundInstanceVolume(RightInstanceID, Volume# * ((Balance# + 1.0) / 2))

				Print("Balance: " + str(Balance#)+" Volume: " + str(Volume#))
				
				if Sound3D_Doppler = 1 and Sound3D[ID].Doppler = 1
					AbsRate# = ((Dist# - Sound3D[ID].LastDist#) * Sound3D_Doppler_INTENSITY)
					AbsRate# = Core_Clamp(AbsRate#, -Sound3D_Doppler_INTENSITY, Sound3D_Doppler_INTENSITY)
					Rate# = Sound3D[ID].Rate# - AbsRate#
					SetSoundInstanceRate(LeftInstanceID, (Rate# + GetSoundInstanceRate(LeftInstanceID)) / 2)
					SetSoundInstanceRate(RightInstanceID, (Rate# + GetSoundInstanceRate(RightInstanceID)) / 2)
				else
					Rate# = Sound3D[ID].Rate#
					SetSoundInstanceRate(LeftInstanceID, Rate#)
					SetSoundInstanceRate(RightInstanceID, Rate#)
				endif
			else
				SetSoundInstanceVolume(LeftInstanceID, 0.0)
				SetSoundInstanceVolume(RightInstanceID, 0.0)
			endif
			
			Sound3D[ID].LastDist# = Dist#
		//else // Removed: when instances stop playing they are removed automatically but the inital sound still exists and can be reused
		//	Sound3D.remove(ID)
		endif
	next ID
endfunction

function Sound3D_SplitAudio(Sound3DRef ref as Sound3DData, SoundID as integer)
	local SoundMemblockID as integer
	local NumChannel as integer
	local BitsPerSample as integer
	local SamplesPerSecond as integer
	local NumFrames as integer
	local BytesPerSample as integer
	local Offset as integer
	local MemblockSize as integer
	local LeftChannelMemblockID as integer
	local RightChannelMemblockID as integer
	local i as integer
	local b as integer

	SoundMemblockID = CreatememblockFromSound(SoundID)
	NumChannel = GetMemblockByte(SoundMemblockID, 0)		//Number of Channels (1 or 2)
	BitsPerSample = GetMemblockByte(SoundMemblockID, 2)		//Bit Depth (example: 16bit)
	SamplesPerSecond = GetMemblockInt(SoundMemblockID, 4)	//Sample Rate (example: 44100)
	NumFrames = GetMemblockInt(SoundMemblockID, 8)			//Number of frames in the sound data
	
	//Check for bitdepth limit or If we start with a mono sound then Delete Memblock and return failure
	if BitsPerSample>16 or NumChannel<=1
		DeleteMemblock(SoundMemblockID)
		exitfunction -1
	endif

	BytesPerSample = BitsPerSample/8
	
	Offset = 12
	MemblockSize = Offset + NumFrames * BytesPerSample * NumChannel
	
	LeftChannelMemblockID = CreateMemblock(MemblockSize)
	RightChannelMemblockID = CreateMemblock(MemblockSize)
	
	//Sound info header
	SetMemblockByte(LeftChannelMemblockID, 0, 2)
	SetMemblockByte(LeftChannelMemblockID, 2, BitsPerSample)
	SetMemblockInt (LeftChannelMemblockID, 4, SamplesPerSecond)
	SetMemblockInt (LeftChannelMemblockID, 8, NumFrames)
	
	//Sound info header
	SetMemblockByte(RightChannelMemblockID, 0, 2)
	SetMemblockByte(RightChannelMemblockID, 2, BitsPerSample)
	SetMemblockInt (RightChannelMemblockID, 4, SamplesPerSecond)
	SetMemblockInt (RightChannelMemblockID, 8, NumFrames)
	
	//Copy audio data
	for i=0 to NumFrames-1
		for b=0 to BytesPerSample-1
			SetMemblockByte(LeftChannelMemblockID,Offset+(i * BytesPerSample * 2) + b,GetMemblockByte(SoundMemblockID,Offset + (i * BytesPerSample * 2) + b))
			SetMemblockByte(RightChannelMemblockID,Offset+((i * 2 + 1)*BytesPerSample) + b,GetMemblockByte(SoundMemblockID,Offset + ((i * 2 + 1) * BytesPerSample) + b))
		next b
	next i
	
	Sound3DRef.LeftSoundID = CreateSoundFromMemblock(LeftChannelMemblockID)
	Sound3DRef.RightSoundID = CreateSoundFromMemblock(RightChannelMemblockID)
	
	DeleteMemblock(RightChannelMemblockID)
	DeleteMemblock(LeftChannelMemblockID)
	DeleteMemblock(SoundMemblockID)
endfunction 1