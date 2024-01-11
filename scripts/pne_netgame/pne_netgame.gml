#macro MAX_NET_PLAYERS INPUT_MAX_PLAYERS
#macro MAX_CHAT_LINES 5
#macro CHAT_LINE_DURATION 300

#macro SEND_HOST -1
#macro SEND_ALL -2
#macro SEND_OTHERS -3

#macro SYNC_INTERVAL 10

enum NetHeaders {
	// Internal
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
	HOST_DAMAGE_THING,
	HOST_HOLD_THING,
	HOST_UNHOLD_THING,
	HOST_INTERACT_THING,
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
global.chat = ds_list_create()
global.chat_typing = false
global.chat_input_previous = ""
global.chat_line_times = array_create(MAX_CHAT_LINES)