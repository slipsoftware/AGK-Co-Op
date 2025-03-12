// File: Network.agc
// Created: 24-11-28

#constant MP_MasterServerUrl$	"OurMasterServer"

#constant NET_JOIN			1
#constant NET_DISCONNECT		2
#constant NET_MESSAGE		3
#constant NET_MOVE			4
#constant NET_SHOT			5
#constant NET_HITWALL		6
#constant NET_HITPLAYER		7
#constant NET_DEATH			8
#constant NET_ENTITY			9
#constant NET_WEAPON			10

type ConnectionData
	NetworkID as integer
	ReceivePort as integer
	TransmitPort as integer
endtype

type NetworkData
	Host as integer
	GameName$ as string
	MyNetID as integer
	MyClientID as integer
	HostNetID as integer
	HostIP$ as string
	UpdateTime# as float
	Latency# as float
	RegisterTimeout# as float
	MaxClients as integer
	TCP as ConnectionData
	UDP as ConnectionData
endtype

type BroadcastData
	GlobalIP$ as string
	LocalIP$ as string
	ReceivePort as integer
	TransmitPort as integer
	Name$ as string
	Player as integer
	MaxPlayer as integer
	Timestamp$ as string
	UpdateTime$ as string
	Time$ as string
	String$ as string
endtype

type ClientData
	NetID as integer
	IP$ as string
	ReceivePort as integer
	Name$ as string
	TextID as integer
	OldPos as Core_Vec3Data
	Pos as Core_Vec3Data
	Velocity as Core_Vec3Data
	Angle as Core_Vec3Data
	Life as integer
	Ping# as float
	
	ObjectID as integer
endtype

type MessageData
	TextID as integer
	Name$ as string
	Message$ as string
	Timestamp as integer
endtype

type EntityData
	ObjectID as integer
	Pos as Core_Vec3Data
	Angle as Core_Vec3Data
endtype

type LocalIPData
	LocalIP$ as string
endtype

global Messages as MessageData[]
global Client as ClientData[]
global MP as NetworkData

function MP_Init(MaxClients as integer,  Latency# as float,  RegisterTimeout# as float)
	MP.MaxClients = MaxClients
	MP.Latency# = Latency#
	MP.RegisterTimeout# = RegisterTimeout#
endfunction

function MP_WriteLocalIP(SettingPath$)
	if GetDeviceBaseName()="windows"
		local AppID as integer
		local SettingDirectory$ as string

		SettingPath$=SimplifyPath(SettingPath$)
		SettingDirectory$=Core_GetDirectoriesFromPath(SettingPath$)

		AppID=RunApp("raw:"+SettingDirectory$+"WriteLocalIP.exe",chr(34)+SettingPath$+chr(34)+" localip$")
		repeat
		until GetAppRunning(AppID)=0
	endif
Endfunction

function MP_ReadLocalIP(SettingPath$)
	local LocalIP as LocalIPData
	local Json$ as string

	Json$=Core_FileLoad("raw:"+SettingPath$)
	LocalIP.fromJSON(Json$)
Endfunction LocalIP.LocalIP$

function MP_CreateHost(GameName$, PlayerName$, ReceivePort, TransmitPort, LocalIP$)
	local NetworkName$ as string
	local Spawn as Core_Vec3Data
	local ClientID as integer
	
	if GameName$ = "" then GameName$ = GetAppName()
	if PlayerName$ = "" then PlayerName$ = "Host"
	if LocalIP$ = "" then LocalIP$ = GetDeviceIP()
	
	NetworkName$ = str(ReceivePort) + ";" + str(TransmitPort) + ";" + GameName$ + ";" + str(1) + ";" + str(MP.MaxClients) + ";" + GetCurrentDate() + " " + GetCurrentTime()
	MP.GameName$ = GameName$
	
	MP.Host = 1
	MP.TCP.ReceivePort = ReceivePort
	MP.TCP.NetworkID = HostNetwork(NetworkName$, PlayerName$, ReceivePort)
	if IsNetworkActive(MP.TCP.NetworkID) = 0
		Message("Creating TCP Failed !")
		exitfunction 0
	endif
	
	MP.HostIP$ = LocalIP$
	MP.HostNetID = GetNetworkServerID(MP.TCP.NetworkID)
	
	Spawn = Game_GetSpawnPoint()
	
	Client.length =  -1
	MP.MyNetID = GetNetworkMyClientID(MP.TCP.NetworkID)
	ClientID = MP_AddPlayer(MP.HostNetID, LocalIP$, ReceivePort, Spawn.X#, Spawn.Y#, Spawn.Z#)
	SetNetworkClientUserData(MP.TCP.NetworkID, MP.MyNetID, 0, 1)
	
	MP.MyClientID = MP_GetClientIDFromNetID(MP.MyNetID)
	MP.HostNetID = MP.MyNetID
	
	MP.UDP.TransmitPort = TransmitPort
	MP.UDP.ReceivePort = ReceivePort
	MP.UDP.NetworkID = CreateUDPListener(LocalIP$, ReceivePort)
	if IsNetworkActive(MP.UDP.NetworkID) = 0
		Message("Creating UDP Listener failed !")
		exitfunction 0
	endif
endfunction 1

function MP_CreateClient(NetworkName$, PlayerName$, ServerIP$, ReceivePort, TransmitPort, LocalIP$, Timeout#)
	local ConnectTime# as float
	local MessageID as integer
	
	if PlayerName$ = "" then PlayerName$ = "Client" + str(random(1, 99))

	MP.Host = 0
	MP.TCP.TransmitPort = TransmitPort
	MP.TCP.ReceivePort = TransmitPort
	if len(NetworkName$)>0
		MP.GameName$ = NetworkName$
		MP.TCP.NetworkID = JoinNetwork(NetworkName$, PlayerName$)
	else
		MP.TCP.NetworkID = JoinNetwork(ServerIP$, TransmitPort, PlayerName$)
	endif

	ConnectTime# = Timer()
	repeat
		if Timer() - ConnectTime#>Timeout# or IsNetworkActive(MP.TCP.NetworkID) = 0
			CloseNetwork(MP.TCP.NetworkID)
			message("Joining TCP failed!")
			exitfunction 0
		endif
	until GetNetworkNumClients(MP.TCP.NetworkID)>1
	
	// Add Host Player: Receive port of host is clients Transmit port
	MP.HostNetID = GetNetworkServerID(MP.TCP.NetworkID)
	MP.HostIP$ = GetNetworkServerIP(MP.TCP.NetworkID)
	
	MessageID = CreateNetworkMessage()
	AddNetworkMessageByte(MessageID, NET_JOIN)
	AddNetworkMessageString(MessageID, LocalIP$)
	//additional data here
	SendNetworkMessage(MP.TCP.NetworkID, MP.HostNetID, MessageID)
	
	MP.MyNetID = GetNetworkMyClientID(MP.TCP.NetworkID)
	ReceivePort = MP_ClientWaitForServerAnswer()
	
	MP.UDP.TransmitPort = TransmitPort
	MP.UDP.ReceivePort = ReceivePort
	MP.UDP.NetworkID = CreateUDPListener(LocalIP$, ReceivePort)
	if IsNetworkActive(MP.UDP.NetworkID) = 0
		Message("Creating UDP Listener failed !")
		exitfunction 0
	endif
endfunction 1

function MP_IsConnected()
	if MP.TCP.NetworkID>0 then exitfunction IsNetworkActive(MP.TCP.NetworkID)
endfunction 0

function MP_ClientWaitForServerAnswer()
	local MessageID as integer
	local Option as integer
	local NetID as integer
	local IP$ as string
	local ReceivePort as integer
	local PosX# as float
	local PosY# as float
	local PosZ# as float
	local ClientID as integer
	
	Client.length =  -1
	
	repeat
		MessageID = GetNetworkMessage(MP.TCP.NetworkID)
		while MessageID<>0
			Option = GetNetworkMessageByte(MessageID)
			if Option = NET_JOIN
				NetID = GetNetworkMessageByte(MessageID)
				IP$ = GetNetworkMessageString(MessageID)
				ReceivePort = GetNetworkMessageInteger(MessageID)
				PosX# = GetNetworkMessageFloat(MessageID)
				PosY# = GetNetworkMessageFloat(MessageID)
				PosZ# = GetNetworkMessageFloat(MessageID)
				DeleteNetworkMessage(MessageID)
				
				ClientID = MP_AddPlayer(NetID, IP$, ReceivePort, PosX#, PosY#, PosZ#)
				
				SetNetworkClientUserData(MP.TCP.NetworkID, NetID, 0, 1)
			else
				DeleteNetworkMessage(MessageID)
			endif
			MessageID = GetNetworkMessage(MP.TCP.NetworkID)
		endwhile
	until GetNetworkClientUserData(MP.TCP.NetworkID, MP.MyNetID, 0)
	MP.MyClientID = MP_GetClientIDFromNetID(MP.MyNetID)
endfunction Client[MP.MyClientID].ReceivePort

function MP_FindFreePortForNetwork(IP$)
    local UsedPorts as integer[ -1]
    local FreePort as integer
    local ID as integer
    local ClientID as integer

    // Collect all used ports for the given IP
    for ClientID = 0 to Client.length
        if IP$ = Client[ClientID].IP$
        	UsedPorts.insertsorted(Client[ClientID].ReceivePort)
        endif
    next ClientID

    // Find the first available port starting from MP.UDP.TransmitPort
    FreePort = MP.UDP.ReceivePort
    for ID = 0 to UsedPorts.length
        if UsedPorts[ID] = FreePort
            FreePort = FreePort + 1 // Port is in use
        else
        	exit // Found a gap
        endif
    next ID
endfunction FreePort

function MP_TCPIsConnected()
	local resut as integer
	resut = IsNetworkActive(MP.TCP.NetworkID)
endfunction resut

function MP_UDPIsConnected()
	local resut as integer
	resut = IsNetworkActive(MP.UDP.NetworkID)
endfunction resut

function MP_KickClient(NetID)
	KickNetworkClient(MP.TCP.NetworkID, NetID)
	KickNetworkClient(MP.UDP.NetworkID, NetID)
endfunction

function MP_GetClientIDFromNetID(NetID as integer)
	local ClientID as integer
	ClientID = Client.find(NetID)
	if ClientID =  -1 then ClientID = Client.length
	if ClientID<0 then ClientID = 0
endfunction ClientID

function MP_GetClientObjectID(NetID as integer)
	local ClientID as integer
	local ObjectID as integer
	ClientID = MP_GetClientIDFromNetID(NetID)
	ObjectID = Client[ClientID].ObjectID
endfunction ObjectID

function MP_Update()
	local Time# as float
	
	if MP.Host = 1
		MP_HostReceiveTCP()
		MP_HostReceiveUDP()
	else
		MP_ClientReceiveTCP()
		MP_ClientReceiveUDP()
	endif

	Time# = Timer()
	if Time#>MP.UpdateTime#
		MP.UpdateTime# = Time# + MP.Latency#
		if MP.Host = 1
			MP_HostTransmitMove()
		else
			MP_ClientTransmitMove()
		endif
	endif
endfunction

function MP_UpdateClientData(ClientID, PosX#, PosY#, PosZ#, AngleX#, AngleY#)
	Client[ClientID].Pos.X# = PosX#
	Client[ClientID].Pos.Y# = PosY#
	Client[ClientID].Pos.Z# = PosZ#
	
	Client[ClientID].Angle.X# = AngleX#
	Client[ClientID].Angle.Y# = AngleY#
//~	Client[ClientID].Angle.Z# = AngleZ#
endfunction

function MP_HostReceiveTCP()
	local NetID as integer
	local ClientID as integer
	local MessageID as integer
	local Option as integer
	local LocalIP$ as string
	local GlobalIP$ as string
	local ReceivePort as integer
	local ID as integer
	local ProjectileID as integer
	local EntityID as integer
	local Message$ as string
	local Timestamp as integer
	
	NetID = GetNetworkFirstClient(MP.TCP.NetworkID)
	while NetID<>0
		if NetID<>MP.MyNetID
			ClientID = MP_GetClientIDFromNetID(NetID)
			Client[ClientID].Ping# = GetNetworkClientPing(MP.TCP.NetworkID, NetID)
			
			if GetNetworkClientDisconnected(MP.TCP.NetworkID, NetID) = 1 or GetNetworkClientDisconnected(MP.UDP.NetworkID, NetID) = 1
				if GetNetworkClientUserData(MP.TCP.NetworkID, NetID, 0) = 1
					ClientID = MP_GetClientIDFromNetID(NetID)
					MP_RemovePlayer(ClientID)
					
					DeleteNetworkClient(MP.UDP.NetworkID, NetID)
					DeleteNetworkClient(MP.TCP.NetworkID, NetID)
					
					MessageID = CreateNetworkMessage()
					AddNetworkMessageByte(MessageID, NET_DISCONNECT)
					AddNetworkMessageByte(MessageID, NetID)
					SendNetworkMessage(MP.TCP.NetworkID, 0, MessageID)
					
					if GetNetworkNumClients(MP.TCP.NetworkID) <= MP.MaxClients
						SetNetworkAllowClients(MP.UDP.NetworkID)
						SetNetworkAllowClients(MP.TCP.NetworkID)
					endif
					SetNetworkClientUserData(MP.TCP.NetworkID, NetID, 0, 0)
					
					//update master server here
				endif
			endif
		endif
		NetID = GetNetworkNextClient(MP.TCP.NetworkID)
	endwhile

	MessageID = GetNetworkMessage(MP.TCP.NetworkID)
	while MessageID<>0
		NetID = GetNetworkMessageFromClient(MessageID)
		Option = GetNetworkMessageByte(MessageID)
		select Option
			case NET_JOIN:
				LocalIP$ = GetNetworkMessageString(MessageID)
				//Additional data here
				DeleteNetworkMessage(MessageID)
				
				local Spawn as Core_Vec3Data
				Spawn = Game_GetSpawnPoint()
				GlobalIP$ = GetNetworkClientIP(MP.TCP.NetworkID, NetID)
				ReceivePort = MP_FindFreePortForNetwork(GlobalIP$)
				ClientID = MP_AddPlayer(NetID, GlobalIP$, ReceivePort, Spawn.X#, Spawn.Y#, Spawn.Z#)
				
				//TODO: batch the existing player data in one message NET_BATCH_JOIN
				for ID = 0 to Client.length -1
					if GetNetworkClientUserData(MP.TCP.NetworkID, Client[ID].NetID, 0) = 1
						MessageID = CreateNetworkMessage()
						AddNetworkMessageByte(MessageID, NET_JOIN)
						AddNetworkMessageByte(MessageID, Client[ID].NetID)
						AddNetworkMessageString(MessageID, Client[ID].IP$)
						AddNetworkMessageInteger(MessageID, Client[ID].ReceivePort)
						AddNetworkMessageFloat(MessageID, Client[ID].Pos.X#)
						AddNetworkMessageFloat(MessageID, Client[ID].Pos.Y#)
						AddNetworkMessageFloat(MessageID, Client[ID].Pos.Z#)
						// Additional data here
						SendNetworkMessage(MP.TCP.NetworkID, NetID, MessageID)
					endif
				next ID
				
				MessageID = CreateNetworkMessage()
				AddNetworkMessageByte(MessageID, NET_JOIN)
				AddNetworkMessageByte(MessageID, NetID)
				AddNetworkMessageString(MessageID, GlobalIP$)
				AddNetworkMessageInteger(MessageID, ReceivePort)
				// Additional data here
				AddNetworkMessageFloat(MessageID, Spawn.X#)
				AddNetworkMessageFloat(MessageID, Spawn.Y#)
				AddNetworkMessageFloat(MessageID, Spawn.Z#)
				SendNetworkMessage(MP.TCP.NetworkID, 0, MessageID)
				
				if GetNetworkNumClients(MP.TCP.NetworkID) >= MP.MaxClients
					SetNetworkNoMoreClients(MP.TCP.NetworkID)
					SetNetworkNoMoreClients(MP.UDP.NetworkID)
				endif
				
				SetNetworkClientUserData(MP.TCP.NetworkID, NetID, 0, 1)
				
				//update master server here
			endcase
			case NET_SHOT:
				ClientID = MP_GetClientIDFromNetID(NetID)				
				Client[ClientID].OldPos = Client[ClientID].Pos
				Client[ClientID].Pos.X# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Pos.Y# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Pos.Z# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Angle.X# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Angle.Y# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Angle.Z# = GetNetworkMessageFloat(MessageID)
				DeleteNetworkMessage(MessageID)
				
				local RayDir as Core_Vec3Data
				local HitObjectID as integer
				RayDir=Game_GetDirFromAngle(Client[ClientID].Angle.X#,Client[ClientID].Angle.Y#)
				HitObjectID=Game_GetRayCast(RayDir,Client[ClientID].Pos)
				
				for ID = 0 to Client.length
					if HitObjectID=Client[ID].ObjectID
						MP_HostTransmitMessage("Player: "+Client[ID].Name$+" was hit by "+Client[ClientID].Name$)
						MP_HostTransmitHitPlayer(ID, ClientID)
					endif
				next ID
				
				for ID = 1 to Client.length					
					MessageID = CreateNetworkMessage()
					AddNetworkMessageByte(MessageID, NET_SHOT)
					AddNetworkMessageByte(MessageID, Client[ClientID].NetID)
					AddNetworkMessageFloat(MessageID, Client[ClientID].Pos.X#)
					AddNetworkMessageFloat(MessageID, Client[ClientID].Pos.Y#)
					AddNetworkMessageFloat(MessageID, Client[ClientID].Pos.Z#)
					AddNetworkMessageFloat(MessageID, Client[ClientID].Angle.X#)
					AddNetworkMessageFloat(MessageID, Client[ClientID].Angle.Y#)
					AddNetworkMessageFloat(MessageID, Client[ClientID].Angle.Z#)
					SendNetworkMessage(MP.TCP.NetworkID, Client[ID].NetID, MessageID)
				next ID
			endcase
			case NET_WEAPON:
				ClientID = MP_GetClientIDFromNetID(NetID)
				EntityID = GetNetworkMessageInteger(MessageID)
				DeleteNetworkMessage(MessageID)
				
				for ID = 1 to Client.length
//~					if ID<>ClientID
						MessageID = CreateNetworkMessage()
						AddNetworkMessageByte(MessageID, NET_WEAPON)
						AddNetworkMessageByte(MessageID, Client[ClientID].NetID)
						AddNetworkMessageInteger(MessageID, EntityID)
						SendNetworkMessage(MP.TCP.NetworkID, Client[ID].NetID, MessageID)
//~					endif
				next ID
				
				MP_SwitchWeapon(ClientID,  EntityID)
			endcase
			case NET_MESSAGE:
				ClientID = MP_GetClientIDFromNetID(NetID)
				Message$ = GetNetworkMessageString(MessageID)
				Timestamp = GetUnixTime()
				DeleteNetworkMessage(MessageID)
				
				for ID = 1 to Client.length
					if ID<>ClientID
						MessageID = CreateNetworkMessage()
						AddNetworkMessageByte(MessageID, NET_MESSAGE)
						AddNetworkMessageByte(MessageID, Client[ClientID].NetID)
						AddNetworkMessageString(MessageID, Message$)
						AddNetworkMessageInteger(MessageID, Timestamp)
						SendNetworkMessage(MP.TCP.NetworkID, Client[ID].NetID, MessageID)
					endif
				next ID
				
				MP_AddMessage(Client[ClientID].Name$, Message$, Timestamp)
			endcase
			case default:
				DeleteNetworkMessage(MessageID)
			endcase
		endselect
		MessageID = GetNetworkMessage(MP.TCP.NetworkID)
	endwhile
endfunction

function MP_HostReceiveUDP()
	local NetID as integer
	local ClientID as integer
	local MessageID as integer
	local Option as integer
	local LocalIP$ as string
	local GlobalIP$ as string
	local ReceivePort as integer
	local ID as integer
	local ProjectileID as integer
	local EntityID as integer
	
	MessageID = GetUDPNetworkMessage(MP.UDP.NetworkID)
	while MessageID<>0
		Option = GetNetworkMessageByte(MessageID)
		select Option
			case NET_MOVE:
				NetID = GetNetworkMessageByte(MessageID)
				if NetID<>MP.MyNetID
					if GetNetworkClientUserData(MP.TCP.NetworkID, NetID, 0) = 1
						ClientID = MP_GetClientIDFromNetID(NetID)
						Client[ClientID].OldPos = Client[ClientID].Pos
						Client[ClientID].Pos.X# = GetNetworkMessageFloat(MessageID)
						Client[ClientID].Pos.Y# = GetNetworkMessageFloat(MessageID)
						Client[ClientID].Pos.Z# = GetNetworkMessageFloat(MessageID)
						Client[ClientID].Velocity.X# = GetNetworkMessageFloat(MessageID)
						Client[ClientID].Velocity.Y# = GetNetworkMessageFloat(MessageID)
						Client[ClientID].Velocity.Z# = GetNetworkMessageFloat(MessageID)
						Client[ClientID].Angle.X# = GetNetworkMessageFloat(MessageID)
						Client[ClientID].Angle.Y# = GetNetworkMessageFloat(MessageID)
						Client[ClientID].Angle.Z# = GetNetworkMessageFloat(MessageID)
						ReceivePort = GetNetworkMessageFromPort(MessageID)
						DeleteNetworkMessage(MessageID)
						
						for ID = 1 to Client.length
							if GetNetworkClientUserData(MP.TCP.NetworkID, Client[ID].NetID, 0) = 1 and ID<>ClientID
								MessageID = CreateNetworkMessage()
								AddNetworkMessageByte(MessageID, NET_MOVE)
								AddNetworkMessageByte(MessageID, NetID)
								AddNetworkMessageFloat(MessageID, Client[ClientID].Pos.X#)
								AddNetworkMessageFloat(MessageID, Client[ClientID].Pos.Y#)
								AddNetworkMessageFloat(MessageID, Client[ClientID].Pos.Z#)
								AddNetworkMessageFloat(MessageID, Client[ClientID].Velocity.X#)
								AddNetworkMessageFloat(MessageID, Client[ClientID].Velocity.Y#)
								AddNetworkMessageFloat(MessageID, Client[ClientID].Velocity.Z#)
								AddNetworkMessageFloat(MessageID, Client[ClientID].Angle.X#)
								AddNetworkMessageFloat(MessageID, Client[ClientID].Angle.Y#)
								AddNetworkMessageFloat(MessageID, Client[ClientID].Angle.Z#)
								SendUDPNetworkMessage(MP.UDP.NetworkID, MessageID, Client[ID].IP$, Client[ID].ReceivePort)
							endif
						next ID
					endif
				endif
			endcase
			case default:
				DeleteNetworkMessage(MessageID)
			endcase
		endselect
		MessageID = GetUDPNetworkMessage(MP.UDP.NetworkID)
	endwhile
endfunction

function MP_HostTransmitMove()	
	local MessageID as integer
	local ID as integer
	
	for ID = 1 to Client.length
		MessageID = CreateNetworkMessage()
		AddNetworkMessageByte(MessageID, NET_MOVE)
		AddNetworkMessageByte(MessageID, MP.MyNetID)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Pos.X#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Pos.Y#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Pos.Z#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Velocity.X#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Velocity.Y#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Velocity.Z#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Angle.X#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Angle.Y#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Angle.Z#)
		SendUDPNetworkMessage(MP.UDP.NetworkID, MessageID, Client[ID].IP$, Client[ID].ReceivePort)
	next ID
endfunction

function MP_HostTransmitHitWall(PosX#, PosY#, PosZ#)
	local MessageID as integer
	
	MessageID = CreateNetworkMessage()
	AddNetworkMessageByte(MessageID, NET_HITWALL)
	AddNetworkMessageFloat(MessageID, PosX#)
	AddNetworkMessageFloat(MessageID, PosY#)
	AddNetworkMessageFloat(MessageID, PosZ#)
	SendNetworkMessage(MP.TCP.NetworkID, 0, MessageID)
endfunction

function MP_HostTransmitHitPlayer(ClientID, SourceClientID)
	local MessageID as integer
	
	MessageID = CreateNetworkMessage()
	AddNetworkMessageByte(MessageID, NET_HITPLAYER)
	AddNetworkMessageByte(MessageID, Client[ClientID].NetID)
	AddNetworkMessageByte(MessageID, Client[SourceClientID].NetID)
	AddNetworkMessageInteger(MessageID, Client[ClientID].Life)
	SendNetworkMessage(MP.TCP.NetworkID, 0, MessageID)
endfunction

function MP_HostSwitchWeapon(EntityID)
	local MessageID as integer
	
	MessageID = CreateNetworkMessage()
	AddNetworkMessageByte(MessageID, NET_WEAPON)
	AddNetworkMessageByte(MessageID, MP.MyNetID)
	AddNetworkMessageInteger(MessageID, EntityID)
	SendNetworkMessage(MP.TCP.NetworkID, 0, MessageID)
endfunction

function MP_HostTransmitShot()
	local MessageID as integer
	
	MessageID = CreateNetworkMessage()
	AddNetworkMessageByte(MessageID, NET_SHOT)
	AddNetworkMessageByte(MessageID, MP.MyNetID)
	AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Pos.X#)
	AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Pos.Y#)
	AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Pos.Z#)
	AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Angle.X#)
	AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Angle.Y#)
	AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Angle.Z#)
	SendNetworkMessage(MP.TCP.NetworkID, 0, MessageID)
endfunction

function MP_HostTransmitMessage(Message$)
	local MessageID as integer
	
	MessageID = CreateNetworkMessage()
	AddNetworkMessageByte(MessageID, NET_MESSAGE)
	AddNetworkMessageByte(MessageID, MP.MyNetID)
	AddNetworkMessageString(MessageID, Message$)
	SendNetworkMessage(MP.TCP.NetworkID, 0, MessageID)
	
	MP_AddMessage(Client[MP.MyClientID].Name$, Message$, GetUnixTime())
endfunction

function MP_HostTransmitProjectile(ProjectileID, SourceClientID, PosX#, PosY#, PosZ#, VelocityX#, VelocityY#, VelocityZ#)
	local MessageID as integer
	local ID as integer
	
	for ID = 1 to Client.length
		MessageID = CreateNetworkMessage()
		AddNetworkMessageByte(MessageID, NET_PROJECTILE)
		AddNetworkMessageByte(MessageID, Client[SourceClientID].NetID)
		AddNetworkMessageByte(MessageID, ProjectileID)
		AddNetworkMessageFloat(MessageID, PosX#)
		AddNetworkMessageFloat(MessageID, PosY#)
		AddNetworkMessageFloat(MessageID, PosZ#)
		AddNetworkMessageFloat(MessageID, VelocityX#)
		AddNetworkMessageFloat(MessageID, VelocityY#)
		AddNetworkMessageFloat(MessageID, VelocityZ#)
		SendUDPNetworkMessage(MP.UDP.NetworkID, MessageID, Client[ID].IP$, Client[ID].ReceivePort)
	next ID
endfunction

function MP_HostTransmitSpawn(ClientID, SourceClientID)
	local MessageID as integer
		
	MessageID = CreateNetworkMessage()
	AddNetworkMessageByte(MessageID, NET_DEATH)
	AddNetworkMessageByte(MessageID, Client[ClientID].NetID)
	AddNetworkMessageByte(MessageID, Client[SourceClientID].NetID)
	AddNetworkMessageFloat(MessageID, Client[ClientID].Pos.X#)
	AddNetworkMessageFloat(MessageID, Client[ClientID].Pos.Y#)
	AddNetworkMessageFloat(MessageID, Client[ClientID].Pos.Z#)
	AddNetworkMessageInteger(MessageID, Client[ClientID].Life)
	SendNetworkMessage(MP.TCP.NetworkID, 0, MessageID)
endfunction

function MP_HostTransmitEntitys(EntityID, PosX#, PosY#, PosZ#, AngleX#, AngleY#, AngleZ#, VelocityX#, VelocityY#, VelocityZ#)
	local MessageID as integer
	local ID as integer
	
	//TODO: Batch send entity data
	for ID = 1 to Client.length
		MessageID = CreateNetworkMessage()
		AddNetworkMessageByte(MessageID, NET_ENTITY)
		AddNetworkMessageByte(MessageID, EntityID)
		AddNetworkMessageFloat(MessageID, PosX#)
		AddNetworkMessageFloat(MessageID, PosY#)
		AddNetworkMessageFloat(MessageID, PosZ#)
		AddNetworkMessageFloat(MessageID, AngleX#)
		AddNetworkMessageFloat(MessageID, AngleY#)
		AddNetworkMessageFloat(MessageID, AngleZ#)
		AddNetworkMessageFloat(MessageID, VelocityX#)
		AddNetworkMessageFloat(MessageID, VelocityY#)
		AddNetworkMessageFloat(MessageID, VelocityZ#)
		SendUDPNetworkMessage(MP.UDP.NetworkID, MessageID, Client[ID].IP$, Client[ID].ReceivePort)
	next ID
endfunction

function MP_ClientReceiveTCP()
	local NetID as integer
	local ClientID as integer
	local MessageID as integer
	local Option as integer
	
	local IP$ as string
	local ReceivePort as integer
	local PosX# as float
	local PosY# as float
	local PosZ# as float
	
	local ProjectileID as integer
	local ClientPosX# as float
	local ClientPosY# as float
	local ClientPosZ# as float
	
	local Message$ as string
	local Timestamp as integer
	
	local SourceNetID as integer
	
	local EntityID as integer
	
	NetID = GetNetworkFirstClient(MP.TCP.NetworkID)
	while NetID<>0
		if NetID<>MP.MyNetID
			if GetNetworkClientDisconnected(MP.TCP.NetworkID, NetID) = 1
				if GetNetworkClientUserData(MP.TCP.NetworkID, NetID, 0) = 1
					DeleteNetworkClient(MP.TCP.NetworkID, NetID)
					
					SetNetworkClientUserData(MP.TCP.NetworkID, NetID, 0, 0)
					
					ClientID = MP_GetClientIDFromNetID(NetID)
					MP_RemovePlayer(ClientID)
					
					MP.MyClientID = MP_GetClientIDFromNetID(MP.MyNetID)
				endif
			endif
		endif
		NetID = GetNetworkNextClient(MP.TCP.NetworkID)
	endwhile

	MessageID = GetNetworkMessage(MP.TCP.NetworkID)
	while MessageID<>0
		Option = GetNetworkMessageByte(MessageID)
		select Option
			case NET_JOIN:
				NetID = GetNetworkMessageByte(MessageID)
				IP$ = GetNetworkMessageString(MessageID)
				ReceivePort = GetNetworkMessageInteger(MessageID)
				PosX# = GetNetworkMessageFloat(MessageID)
				PosY# = GetNetworkMessageFloat(MessageID)
				PosZ# = GetNetworkMessageFloat(MessageID)
				//Additional Data Here
				DeleteNetworkMessage(MessageID)

				ClientID = MP_AddPlayer(NetID, IP$, ReceivePort, PosX#, PosY#, PosZ#)
				
				MP.MyClientID = MP_GetClientIDFromNetID(MP.MyNetID)
				
				SetNetworkClientUserData(MP.TCP.NetworkID, NetID, 0, 1)
			endcase
			case NET_SHOT:
				NetID = GetNetworkMessageByte(MessageID)
				ClientID = MP_GetClientIDFromNetID(NetID)
				Client[ClientID].OldPos = Client[ClientID].Pos
				ClientPosX# = GetNetworkMessageFloat(MessageID)
				ClientPosY# = GetNetworkMessageFloat(MessageID)
				ClientPosZ# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Angle.X# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Angle.Y# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Angle.Z# = GetNetworkMessageFloat(MessageID)
				DeleteNetworkMessage(MessageID)
				
				if NetID<>MP.MyNetID
					Client[ClientID].Pos.X# = ClientPosX#
					Client[ClientID].Pos.Y# = ClientPosY#
					Client[ClientID].Pos.Z# = ClientPosZ#
				endif
				
				MP_Shot(ProjectileID,  ClientID)
			endcase
			case NET_MESSAGE:
				NetID = GetNetworkMessageByte(MessageID)
				ClientID = MP_GetClientIDFromNetID(NetID)
				Message$ = GetNetworkMessageString(MessageID)
				Timestamp = GetNetworkMessageInteger(MessageID)
				DeleteNetworkMessage(MessageID)
				
				MP_AddMessage(Client[ClientID].Name$, Message$, Timestamp)
			endcase
			case NET_HITWALL:
				ClientID = MP_GetClientIDFromNetID(NetID)
				ProjectileID = GetNetworkMessageByte(MessageID)
				PosX# = GetNetworkMessageFloat(MessageID)
				PosY# = GetNetworkMessageFloat(MessageID)
				PosZ# = GetNetworkMessageFloat(MessageID)
				DeleteNetworkMessage(MessageID)
				
				MP_DeleteProjectile(ProjectileID, PosX#, PosY#, PosZ#)
			endcase
			case NET_HITPLAYER:
				NetID = GetNetworkMessageByte(MessageID)
				SourceNetID = GetNetworkMessageByte(MessageID)
				ClientID = MP_GetClientIDFromNetID(NetID)
				Client[ClientID].Life = GetNetworkMessageInteger(MessageID)
				DeleteNetworkMessage(MessageID)
			endcase
			case NET_DEATH:
				NetID = GetNetworkMessageByte(MessageID)
				SourceNetID = GetNetworkMessageByte(MessageID)
				ClientID = MP_GetClientIDFromNetID(NetID)
				Client[ClientID].Pos.X# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Pos.Y# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Pos.Z# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Life = GetNetworkMessageInteger(MessageID)
				Client[ClientID].OldPos = Client[ClientID].Pos
				DeleteNetworkMessage(MessageID)
				
				//Update Player object here
				
				MP_AddMessage(Client[ClientID].Name$, "has Died", GetUnixTime())
			endcase
			case NET_WEAPON:
				NetID = GetNetworkMessageByte(MessageID)
				ClientID = MP_GetClientIDFromNetID(NetID)
				EntityID = GetNetworkMessageInteger(MessageID)
				DeleteNetworkMessage(MessageID)
				
				MP_SwitchWeapon(ClientID,  EntityID)
			endcase
			case default:
				DeleteNetworkMessage(MessageID)
			endcase
		endselect
		MessageID = GetNetworkMessage(MP.TCP.NetworkID)
	endwhile
endfunction

function MP_ClientReceiveUDP()
	local NetID as integer
	local ClientID as integer
	local MessageID as integer
	local Option as integer
	
	local SourceClientID as integer
	local ProjectileID as float
	local PosX# as float
	local PosY# as float
	local PosZ# as float
	local AngleX# as float
	local AngleY# as float
	local AngleZ# as float
	local VelocityX# as float
	local VelocityY# as float
	local VelocityZ# as float
	
	local EntityID as integer
	
	MessageID = GetUDPNetworkMessage(MP.UDP.NetworkID)
	while MessageID<>0
		Option = GetNetworkMessageByte(MessageID)	
		select Option
			case NET_MOVE:
				NetID = GetNetworkMessageByte(MessageID)
				ClientID = MP_GetClientIDFromNetID(NetID)
				Client[ClientID].OldPos = Client[ClientID].Pos
				Client[ClientID].Pos.X# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Pos.Y# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Pos.Z# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Velocity.X# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Velocity.Y# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Velocity.Z# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Angle.X# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Angle.Y# = GetNetworkMessageFloat(MessageID)
				Client[ClientID].Angle.Z# = GetNetworkMessageFloat(MessageID)
				DeleteNetworkMessage(MessageID)
			endcase
			case NET_PROJECTILE:
				NetID = GetNetworkMessageByte(MessageID)
				SourceClientID = MP_GetClientIDFromNetID(NetID)
				ProjectileID = GetNetworkMessageByte(MessageID)
				PosX# = GetNetworkMessageFloat(MessageID)
				PosY# = GetNetworkMessageFloat(MessageID)
				PosZ# = GetNetworkMessageFloat(MessageID)
				VelocityX# = GetNetworkMessageFloat(MessageID)
				VelocityY# = GetNetworkMessageFloat(MessageID)
				VelocityZ# = GetNetworkMessageFloat(MessageID)
				DeleteNetworkMessage(MessageID)
				
				MP_UpdateProjectile(ProjectileID, PosX#, PosY#, VelocityX#, VelocityY#, VelocityZ#)
			endcase
			case NET_ENTITY:
				EntityID = GetNetworkMessageByte(MessageID)
				PosX# = GetNetworkMessageFloat(MessageID)
				PosY# = GetNetworkMessageFloat(MessageID)
				PosZ# = GetNetworkMessageFloat(MessageID)
				AngleX# = GetNetworkMessageFloat(MessageID)
				AngleY# = GetNetworkMessageFloat(MessageID)
				AngleZ# = GetNetworkMessageFloat(MessageID)
				VelocityX# = GetNetworkMessageFloat(MessageID)
				VelocityY# = GetNetworkMessageFloat(MessageID)
				VelocityZ# = GetNetworkMessageFloat(MessageID)
				DeleteNetworkMessage(MessageID)
				
				//Update Entity here
			endcase
			case default:
				DeleteNetworkMessage(MessageID)
			endcase
		endselect
		MessageID = GetUDPNetworkMessage(MP.UDP.NetworkID)
	endwhile
endfunction

function MP_ClientTransmitMove()
	local MessageID as integer
	
	if GetNetworkClientUserData(MP.TCP.NetworkID, MP.MyNetID, 0) = 1		
		MessageID = CreateNetworkMessage()
		AddNetworkMessageByte(MessageID, NET_MOVE)
		AddNetworkMessageByte(MessageID, MP.MyNetID)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Pos.X#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Pos.Y#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Pos.Z#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Velocity.X#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Velocity.Y#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Velocity.Z#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Angle.X#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Angle.Y#)
		AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Angle.Z#)
		SendUDPNetworkMessage(MP.UDP.NetworkID, MessageID, MP.HostIP$, MP.UDP.TransmitPort)
	endif
endfunction

function MP_ClientSwitchWeapon(EntityID)
	local MessageID as integer
	
	MessageID = CreateNetworkMessage()
	AddNetworkMessageByte(MessageID, NET_WEAPON)
	AddNetworkMessageInteger(MessageID, EntityID)
	SendNetworkMessage(MP.TCP.NetworkID, MP.HostNetID, MessageID)
endfunction

function MP_ClientTransmitShot()	
	local MessageID as integer
	
	MessageID = CreateNetworkMessage()
	AddNetworkMessageByte(MessageID, NET_SHOT)
	AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Pos.X#)
	AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Pos.Y#)
	AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Pos.Z#)
	AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Angle.X#)
	AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Angle.Y#)
	AddNetworkMessageFloat(MessageID, Client[MP.MyClientID].Angle.Z#)
	SendNetworkMessage(MP.TCP.NetworkID, MP.HostNetID, MessageID)
endfunction

function MP_ClientTransmitMessage(Message$)
	local MessageID as integer
	
	MessageID = CreateNetworkMessage()
	AddNetworkMessageByte(MessageID, NET_MESSAGE)
	AddNetworkMessageString(MessageID, Message$)
	SendNetworkMessage(MP.TCP.NetworkID, MP.HostNetID, MessageID)
	
	MP_AddMessage(Client[MP.MyClientID].Name$, Message$, GetUnixTime())
endfunction

function MP_Disconnect()
	MP_RemoveAllMessages()
	
	DeleteUDPListener(MP.UDP.NetworkID)
	if GetNetworkExists(MP.UDP.NetworkID) then CloseNetwork(MP.UDP.NetworkID)
	if GetNetworkExists(MP.TCP.NetworkID) then CloseNetwork(MP.TCP.NetworkID)
	Client.length =  -1
endfunction

// #########################################################
// ##########      Add Game Functions Here       ###########
// #########################################################

function MP_AddMessage(Name$, Message$, Timestamp)
	local TempMessages as MessageData
	TempMessages.TextID = CreateText(Name$ + ": " + Message$)
	SetTextSize(TempMessages.TextID, 2)
	FixTextToScreen(TempMessages.TextID, 1)
	TempMessages.Name$ = Name$
	TempMessages.Message$ = Message$
	TempMessages.Timestamp = Timestamp
	Messages.insert(TempMessages)
endfunction Messages.length

function MP_RemoveAllMessages()
	local MessageID as integer
	
	for MessageID = 0 to Messages.length
		DeleteText(Messages[MessageID].TextID)
	next MessageID
	Messages.length = -1
endfunction

function MP_MessagesUpdate(MaxMessages)
	local MessageCounter as integer
	local MinMessageID as integer
	local MessageID as integer
	local TextHeight as integer
	local HideMessageID as integer
	
	MinMessageID = Core_Max(Messages.length - MaxMessages, 0)
	for MessageID = MinMessageID to Messages.length
		if GetTextExists(Messages[MessageID].TextID)
			TextHeight = GetTextTotalHeight(Messages[MessageID].TextID)
			SetTextPosition(Messages[MessageID].TextID, GetScreenBoundsLeft(), TextHeight + MessageCounter * TextHeight)
			SetTextVisible(Messages[MessageID].TextID, 1)
			inc MessageCounter
		endif
	next MessageID
	
	if MinMessageID>0
		HideMessageID = Core_Max(MinMessageID -1, 0)
		if GetTextExists(Messages[HideMessageID].TextID) then SetTextVisible(Messages[HideMessageID].TextID, 0)
	endif
endfunction

function MP_Shot(ProjectileID,  ClientID)

endfunction ProjectileID

function MP_DeleteProjectile(ProjectileID, PosX#, PosY#, PosZ#)

endfunction

function MP_UpdateProjectile(ProjectileID, PosX#, PosY#, VelocityX#, VelocityY#, VelocityZ#)
	
endfunction

function MP_UpdateEntity(EntityID, PosX#, PosY#, Angle#, VelocityX#, VelocityY#, AngularVelocity#)
endfunction

function MP_SwitchWeapon(ClientID,  EntityID)

endfunction

function MP_AddPlayer(NetID,  IP$,  ReceivingPort,  SpawnX#,  SpawnY#,  SpawnZ#)
	local ClientID as integer
	local Name$ as string
	local TextID as integer
	
	ClientID = Client.length + 1
	Name$ = GetNetworkClientName(MP.TCP.NetworkID, NetID)
	TextID = CreateText(Name$)
	SetTextColor(TextID, 255, 255, 255, 128)
	SetTextAlignment(TextID, 1)
	SetTextTransparency(TextID, 1)
	SetTextDepth(TextID, 7)
	
	TempClient as ClientData
	TempClient.NetID = NetID
	TempClient.Name$ = Name$
	TempClient.ObjectID = Game_CreatePlayer()
	TempClient.TextID = TextID
	TempClient.Life = 100
	TempClient.IP$ = IP$
	TempClient.ReceivePort = ReceivingPort
	TempClient.Pos.X# = SpawnX#
	TempClient.Pos.Y# = SpawnY#
	TempClient.Pos.Z# = SpawnZ#
		
	Client.insertsorted(TempClient)
	
	MP_AddMessage("Game", Client[Client.length].Name$ + " joined with IP: " + IP$ + " and Port: " + str(ReceivingPort), GetUnixTime())
endfunction Client.length

function MP_RemovePlayer(ClientID)
	MP_AddMessage("Game", Client[ClientID].Name$ + " disconnected", GetUnixTime())
	
	Game_DeletePlayer(Client[ClientID])
	
	Client.remove(ClientID)
endfunction

function MP_Info()
	global GeneralTextID
	
	local Text$ as string
	local NetID as integer
	local ClientID as integer
	
	Text$ = "Host: " + str(MP.Host) + chr(10)
	Text$ = Text$ + "NumClients: " + str(GetNetworkNumClients(MP.TCP.NetworkID)) + chr(10)
	Text$ = Text$ + "Client length: " + str(Client.length) + chr(10)
	Text$ = Text$ + "Receive Port: " + str(MP.UDP.ReceivePort) + chr(10)
	Text$ = Text$ + "Transmit Port: " + str(MP.UDP.TransmitPort) + chr(10)
	Text$ = Text$ + "MP_MyClientID: " + str(MP_GetClientIDFromNetID(MP.MyNetID)) + chr(10)
	Text$ = Text$ + "MP.HostClientID: " + str(MP_GetClientIDFromNetID(MP.HostNetID)) + chr(10)
	Text$ = Text$ + "MP.MyClientID: " + str(MP.MyClientID) + chr(10)
	if GetTextExists(GeneralTextID)
		SetTextString(GeneralTextID, Text$)
	else
		GeneralTextID = CreateText(Text$)
		SetTextColor(GeneralTextID, 0, 0, 0, 255)
		FixTextToScreen(GeneralTextID, 1)
		SetTextPosition(GeneralTextID, GetScreenBoundsLeft(), 0)
	endif

	NetID = GetNetworkFirstClient(MP.TCP.NetworkID)
	while NetID<>0
		ClientID = MP_GetClientIDFromNetID(NetID)
		if ClientID >= 0 and ClientID <= Client.length
			Text$ = "Name: " + Client[ClientID].Name$ + chr(10)
			Text$ = Text$ + "ClientID: " + str(ClientID) + chr(10)
			Text$ = Text$ + "NetID: " + str(NetID) + " | " + str(Client[ClientID].NetID) + chr(10)
			Text$ = Text$ + "IP: " + Client[ClientID].IP$ + chr(10)
			Text$ = Text$ + "Receive Port: " + str(Client[ClientID].ReceivePort) + chr(10)
			Text$ = Text$ + "ObjectID: " + str(Client[ClientID].ObjectID) + chr(10)
			Text$ = Text$ + "Pos: " + str(Client[ClientID].Pos.X#) + ", " + str(Client[ClientID].Pos.Y#) + ", " + str(Client[ClientID].Pos.Z#) + chr(10)
			Text$ = Text$ + "Angle: " + str(Client[ClientID].Angle.X#) + ", " + str(Client[ClientID].Angle.Y#) + ", " + str(Client[ClientID].Angle.Z#) + chr(10)
			if GetTextExists(Client[ClientID].TextID)
				SetTextString(Client[ClientID].TextID, Text$)
				SetTextPosition(Client[ClientID].TextID, GetScreenBoundsLeft(), 25 + 20 * ClientID)
				SetTextColor(Client[ClientID].TextID, 0, 0, 0, 255)
				Game_UpdateTextPosition(ClientID)
			endif
		endif
		NetID = GetNetworkNextClient(MP.TCP.NetworkID)
	endwhile
endfunction

function MP_DeleteInfo()
	local NetID as integer
	local ClientID as integer
	
	if GetTextExists(GeneralTextID) then DeleteText(GeneralTextID)
	
	NetID = GetNetworkFirstClient(MP.TCP.NetworkID)
	while NetID<>0
		ClientID = MP_GetClientIDFromNetID(NetID)
		if ClientID >= 0 and ClientID <= Client.length
			if GetTextExists(Client[ClientID].TextID)
				SetTextString(Client[ClientID].TextID, Client[ClientID].Name$)
				SetTextColor(Client[ClientID].TextID, 255, 255, 255, 128)
			endif
		endif
		NetID = GetNetworkNextClient(MP.TCP.NetworkID)
	endwhile
endfunction