#macro MAX_NET_PLAYERS INPUT_MAX_PLAYERS

#macro SEND_HOST -1
#macro SEND_ALL -2
#macro SEND_OTHERS -3

#macro SYNC_INTERVAL 8

enum NetHeaders {
	// Internal
	HOST_CHECK_IP,
	ACK,
	
	// Handshake
	CLIENT_CONNECT,
	HOST_CHECK_CLIENT,
	CLIENT_VERIFY,
	HOST_ALLOW_CLIENT,
	HOST_BLOCK_CLIENT,
	CLIENT_SEND_INFO,
	HOST_ADD_CLIENT,
	
	// Joining
	PLAYER_JOINED,
	HOST_DISCONNECT,
	CLIENT_DISCONNECT,
	PLAYER_LEFT,
	
	// Connection
	HOST_PING,
	CLIENT_PONG,
	
	// Interaction
	CHAT,
	INPUT,
	
	// Gameplay
	HOST_FLAG,
	HOST_RESET_FLAGS,
	HOST_LEVEL,
	HOST_AREA,
	HOST_THING,
	HOST_DESTROY_THING,
	HOST_PLAYER_STATE,
	HOST_RESET_PLAYER_STATES,
	
	__SIZE,
}

enum NetDataTypes {
	UNDEFINED,
	REAL,
	STRING,
	ARRAY,
	BOOL,
	INT32,
	STRUCT,
}

global.netgame = undefined