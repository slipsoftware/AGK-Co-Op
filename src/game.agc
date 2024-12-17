// File: game.agc
// Created: 24-12-12

global Game_isHost as integer

function Game()
	local IP$ as string
	local ReceivePort as integer
	local TransmitPort as integer
	local Result as integer
	local PlayerName$ as string
	local LocalIP$ as string
	local MyObjectID as integer
	local MyClientID as integer
	local FrameTime# as float
	
	//TODO: Read this from Settings File
	ReceivePort=26001
	TransmitPort=26002
	//local IP for udp to listen on
	//agk doesn't always retrieve the correct ip connected to the internet so we need an external application for that
	LocalIP$=GetDeviceIP()
	
	MP_Init(8,0.015,4)
	
	if Game_isHost=1
		Result=MP_CreateHost("",PlayerName$,ReceivePort,TransmitPort,LocalIP$)
	else
		IP$=Core_RequestString(LocalIP$,50,9)
		PlayerName$="Anonymous"+str(random(1,100))
		Result=MP_CreateClient("",PlayerName$,IP$,TransmitPort,ReceivePort,LocalIP$,4)
	endif
	
	//TODO: put this in functions
	global ChatEditboxID
	ChatEditboxID=CreateEditBox()
	SetEditBoxPosition(ChatEditboxID,GetScreenBoundsLeft(),GetScreenBoundsTop())
	SetEditBoxSize(ChatEditboxID,20,2)
	SetEditBoxBorderSize(ChatEditboxID,0.2)
	SetEditBoxBackgroundColor(ChatEditboxID,255,255,255,64)
	SetEditBoxBorderColor(ChatEditboxID,255,255,255,64)
	FixEditBoxToScreen(ChatEditboxID,1)
	
	local WorldObjectID as integer
	WorldObjectID=CreateObjectPlane(10,10)
	RotateObjectLocalX(WorldObjectID,90)
	
	Cam_Init()
	
	do
		FrameTime#=GetFrameTime()
		MyObjectID=Client[MP.MyClientID].ObjectID
		
		Cam_Update(FrameTime#)
		MP_UpdateClientData(MP.MyClientID,Camera.Position.X#,Camera.Position.Y#,Camera.Position.Z#,Camera.Angle.X#,Camera.Angle.Y#)	
		Game_UpdateAllPlayers()
		
		if GetRawKeyState(KEY_F1)
			MP_Info()
		elseif GetRawKeyReleased(KEY_F1)
			MP_DeleteInfo()
		endif
		
		if GetEditBoxChanged(ChatEditboxID)=1 and GetEditBoxHasFocus(ChatEditboxID)=0
			Game_SendMessage(GetEditBoxText(ChatEditboxID))
			SetEditBoxText(ChatEditboxID,"")
		endif
		MP_MessagesUpdate(10)
		
		if GetRawKeyReleased(KEY_ESCAPE) then exit
		if MP_TCPIsConnected()=0 or MP_UDPIsConnected()=0
			Message("Connection Lost !")
			exit
		endif
		
		MP_Update()
		
	    Sync()
	loop
	//TODO: Put this into functions
	DeleteObject(WorldObjectID)
	DeleteEditBox(ChatEditboxID)
	Game_DeleteAllPlayer()
	
	MP_ClientDisconnect()
endfunction STATE_MAIN_MENU

function Game_CreatePlayer()
	local ObjectID as integer
	ObjectID=CreateObjectCone(1.5,1,12)
	RotateObjectLocalX(ObjectID,90)
	FixObjectPivot(ObjectID)
endfunction ObjectID

function Game_DeletePlayer(Client ref as ClientData)
	DeleteObject(Client.ObjectID)
	DeleteText(Client.TextID)
endfunction

function Game_DeleteAllPlayer()
	local ClientID as integer
	for ClientID=0 to Client.length
		Game_DeletePlayer(Client[ClientID])
	next ClientID
endfunction

function Game_UpdatePlayer(ClientID)
	SetObjectPosition(Client[ClientID].ObjectID,Client[ClientID].Pos.X#,Client[ClientID].Pos.Y#,Client[ClientID].Pos.Z#)
	SetObjectRotation(Client[ClientID].ObjectID,Client[ClientID].Angle.X#,Client[ClientID].Angle.Y#,Client[ClientID].Angle.Z#)
endfunction

function Game_UpdateAllPlayers()
	local ClientID as integer
	for ClientID=0 to Client.length
		if Client[ClientID].Life<=0
			Client[ClientID].Pos=Game_GetSpawnPoint()
			Client[ClientID].OldPos=Client[ClientID].Pos
			Client[ClientID].Life=100
			
			if MP.Host=1
				MP_HostTransmitSpawn(ClientID, ClientID)
				
				MP_AddMessage(Client[ClientID].Name$,"has Died",GetUnixTime())
			endif
		endif
		
		Game_UpdatePlayer(ClientID)
		Game_UpdateTextPosition(ClientID)
	next ClientID
endfunction

function Game_UpdateTextPosition(ClientID)
	local PosX# as float
	local PosY# as float
	local PosZ# as float
	local TextX# as float
	local TextY# as float
	
	PosX#=GetObjectX(Client[ClientID].ObjectID)
	PosY#=GetObjectY(Client[ClientID].ObjectID)
	PosZ#=GetObjectZ(Client[ClientID].ObjectID)
	TextX#=GetScreenXFrom3D(PosX#,PosY#,PosZ#)
	TextY#=GetScreenYFrom3D(PosX#,PosY#,PosZ#)
	
	SetTextPosition(Client[ClientID].TextID,TextX#,TextY#)
endfunction

function Game_SendMessage(Message$)
	if MP.Host=1
		MP_HostTransmitMessage(Message$)
	else
		MP_ClientTransmitMessage(Message$)
	endif
endfunction

function Game_GetSpawnPoint()
	local Spawn as Core_Vec3Data
	Spawn.X#=0
	Spawn.Y#=0
	Spawn.Z#=0
endfunction Spawn