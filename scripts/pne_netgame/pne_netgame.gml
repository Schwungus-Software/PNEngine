#macro DEFAULT_PORT 7788

#macro SEND_HOST -1
#macro SEND_ALL -2
#macro SEND_OTHERS -3

enum NetHeaders {
	// Internal
	ACK,
	
	// Handshake
	CLIENT_CONNECT,
	HOST_CHECK_CLIENT,
	CLIENT_VERIFY,
	HOST_BLOCK_CLIENT,
	HOST_ALLOW_CLIENT,
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
	
	// Game
	HOST_LEVEL,
	CLIENT_LEVEL_READY,
	HOST_LEVEL_READY,
	HOST_FLAG,
	HOST_STATE,
	
	__SIZE,
}

global.netgame = undefined
global.net_tick_queue = ds_queue_create()