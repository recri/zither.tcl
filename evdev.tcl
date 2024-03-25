# -*- mode: Tcl; tab-width: 8; -*-
#
# Copyright (C) 2024 by Roger E Critchlow Jr, Las Cruces, NM, USA
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

package provide ::evdev 1.0

namespace eval ::evdev {
    #
    # event decoding
    #
    variable namevalues [dict create]
    variable events [dict create]
    variable eventnames [dict create]
    
    foreach {event eventvalue codes} {
	EV_SYN 0x00 {
	    SYN_REPORT		0
	    SYN_CONFIG		1
	    SYN_MT_REPORT		2
	    SYN_DROPPED		3
	    SYN_MAX			0xf
	}
	EV_KEY 0x01 {
	    KEY_RESERVED		0
	    KEY_ESC			1
	    KEY_1			2
	    KEY_2			3
	    KEY_3			4
	    KEY_4			5
	    KEY_5			6
	    KEY_6			7
	    KEY_7			8
	    KEY_8			9
	    KEY_9			10
	    KEY_0			11
	    KEY_MINUS		12
	    KEY_EQUAL		13
	    KEY_BACKSPACE		14
	    KEY_TAB			15
	    KEY_Q			16
	    KEY_W			17
	    KEY_E			18
	    KEY_R			19
	    KEY_T			20
	    KEY_Y			21
	    KEY_U			22
	    KEY_I			23
	    KEY_O			24
	    KEY_P			25
	    KEY_LEFTBRACE		26
	    KEY_RIGHTBRACE		27
	    KEY_ENTER		28
	    KEY_LEFTCTRL		29
	    KEY_A			30
	    KEY_S			31
	    KEY_D			32
	    KEY_F			33
	    KEY_G			34
	    KEY_H			35
	    KEY_J			36
	    KEY_K			37
	    KEY_L			38
	    KEY_SEMICOLON		39
	    KEY_APOSTROPHE		40
	    KEY_GRAVE		41
	    KEY_LEFTSHIFT		42
	    KEY_BACKSLASH		43
	    KEY_Z			44
	    KEY_X			45
	    KEY_C			46
	    KEY_V			47
	    KEY_B			48
	    KEY_N			49
	    KEY_M			50
	    KEY_COMMA		51
	    KEY_DOT			52
	    KEY_SLASH		53
	    KEY_RIGHTSHIFT		54
	    KEY_KPASTERISK		55
	    KEY_LEFTALT		56
	    KEY_SPACE		57
	    KEY_CAPSLOCK		58
	    KEY_F1			59
	    KEY_F2			60
	    KEY_F3			61
	    KEY_F4			62
	    KEY_F5			63
	    KEY_F6			64
	    KEY_F7			65
	    KEY_F8			66
	    KEY_F9			67
	    KEY_F10			68
	    KEY_NUMLOCK		69
	    KEY_SCROLLLOCK		70
	    KEY_KP7			71
	    KEY_KP8			72
	    KEY_KP9			73
	    KEY_KPMINUS		74
	    KEY_KP4			75
	    KEY_KP5			76
	    KEY_KP6			77
	    KEY_KPPLUS		78
	    KEY_KP1			79
	    KEY_KP2			80
	    KEY_KP3			81
	    KEY_KP0			82
	    KEY_KPDOT		83
	    
	    KEY_ZENKAKUHANKAKU	85
	    KEY_102ND		86
	    KEY_F11			87
	    KEY_F12			88
	    KEY_RO			89
	    KEY_KATAKANA		90
	    KEY_HIRAGANA		91
	    KEY_HENKAN		92
	    KEY_KATAKANAHIRAGANA	93
	    KEY_MUHENKAN		94
	    KEY_KPJPCOMMA		95
	    KEY_KPENTER		96
	    KEY_RIGHTCTRL		97
	    KEY_KPSLASH		98
	    KEY_SYSRQ		99
	    KEY_RIGHTALT		100
	    KEY_LINEFEED		101
	    KEY_HOME		102
	    KEY_UP			103
	    KEY_PAGEUP		104
	    KEY_LEFT		105
	    KEY_RIGHT		106
	    KEY_END			107
	    KEY_DOWN		108
	    KEY_PAGEDOWN		109
	    KEY_INSERT		110
	    KEY_DELETE		111
	    KEY_MACRO		112
	    KEY_MUTE		113
	    KEY_VOLUMEDOWN		114
	    KEY_VOLUMEUP		115
	    KEY_POWER		116
	    KEY_KPEQUAL		117
	    KEY_KPPLUSMINUS		118
	    KEY_PAUSE		119
	    KEY_SCALE		120
	    KEY_KPCOMMA		121
	    KEY_HANGEUL		122
	    KEY_HANGUEL		122
	    KEY_HANJA		123
	    KEY_YEN			124
	    KEY_LEFTMETA		125
	    KEY_RIGHTMETA		126
	    KEY_COMPOSE		127
	    KEY_STOP		128
	    KEY_AGAIN		129
	    KEY_PROPS		130
	    KEY_UNDO		131
	    KEY_FRONT		132
	    KEY_COPY		133
	    KEY_OPEN		134
	    KEY_PASTE		135
	    KEY_FIND		136
	    KEY_CUT			137
	    KEY_HELP		138
	    KEY_MENU		139
	    KEY_CALC		140
	    KEY_SETUP		141
	    KEY_SLEEP		142
	    KEY_WAKEUP		143
	    KEY_FILE		144
	    KEY_SENDFILE		145
	    KEY_DELETEFILE		146
	    KEY_XFER		147
	    KEY_PROG1		148
	    KEY_PROG2		149
	    KEY_WWW			150
	    KEY_MSDOS		151
	    KEY_COFFEE		152
	    KEY_SCREENLOCK		152
	    KEY_ROTATE_DISPLAY	153
	    KEY_DIRECTION		153
	    KEY_CYCLEWINDOWS	154
	    KEY_MAIL		155
	    KEY_BOOKMARKS		156
	    KEY_COMPUTER		157
	    KEY_BACK		158
	    KEY_FORWARD		159
	    KEY_CLOSECD		160
	    KEY_EJECTCD		161
	    KEY_EJECTCLOSECD	162
	    KEY_NEXTSONG		163
	    KEY_PLAYPAUSE		164
	    KEY_PREVIOUSSONG	165
	    KEY_STOPCD		166
	    KEY_RECORD		167
	    KEY_REWIND		168
	    KEY_PHONE		169
	    KEY_ISO			170
	    KEY_CONFIG		171
	    KEY_HOMEPAGE		172
	    KEY_REFRESH		173
	    KEY_EXIT		174
	    KEY_MOVE		175
	    KEY_EDIT		176
	    KEY_SCROLLUP		177
	    KEY_SCROLLDOWN		178
	    KEY_KPLEFTPAREN		179
	    KEY_KPRIGHTPAREN	180
	    KEY_NEW			181
	    KEY_REDO		182
	    KEY_F13			183
	    KEY_F14			184
	    KEY_F15			185
	    KEY_F16			186
	    KEY_F17			187
	    KEY_F18			188
	    KEY_F19			189
	    KEY_F20			190
	    KEY_F21			191
	    KEY_F22			192
	    KEY_F23			193
	    KEY_F24			194
	    KEY_PLAYCD		200
	    KEY_PAUSECD		201
	    KEY_PROG3		202
	    KEY_PROG4		203
	    KEY_ALL_APPLICATIONS	204
	    KEY_DASHBOARD		204
	    KEY_SUSPEND		205
	    KEY_CLOSE		206
	    KEY_PLAY		207
	    KEY_FASTFORWARD		208
	    KEY_BASSBOOST		209
	    KEY_PRINT		210
	    KEY_HP			211
	    KEY_CAMERA		212
	    KEY_SOUND		213
	    KEY_QUESTION		214
	    KEY_EMAIL		215
	    KEY_CHAT		216
	    KEY_SEARCH		217
	    KEY_CONNECT		218
	    KEY_FINANCE		219
	    KEY_SPORT		220
	    KEY_SHOP		221
	    KEY_ALTERASE		222
	    KEY_CANCEL		223
	    KEY_BRIGHTNESSDOWN	224
	    KEY_BRIGHTNESSUP	225
	    KEY_MEDIA		226
	    KEY_SWITCHVIDEOMODE	227
	    KEY_KBDILLUMTOGGLE	228
	    KEY_KBDILLUMDOWN	229
	    KEY_KBDILLUMUP		230
	    KEY_SEND		231
	    KEY_REPLY		232
	    KEY_FORWARDMAIL		233
	    KEY_SAVE		234
	    KEY_DOCUMENTS		235
	    KEY_BATTERY		236
	    KEY_BLUETOOTH		237
	    KEY_WLAN		238
	    KEY_UWB			239
	    KEY_UNKNOWN		240
	    KEY_VIDEO_NEXT		241
	    KEY_VIDEO_PREV		242
	    KEY_BRIGHTNESS_CYCLE	243
	    KEY_BRIGHTNESS_AUTO	244
	    KEY_BRIGHTNESS_ZERO	244
	    KEY_DISPLAY_OFF		245
	    KEY_WWAN 246
	    KEY_WIMAX 246
	    KEY_RFKILL 247
	    KEY_MICMUTE 248
	    BTN_MISC 0x100
	    BTN_0 0x100
	    BTN_1 0x101
	    BTN_2 0x102
	    BTN_3 0x103
	    BTN_4 0x104
	    BTN_5 0x105
	    BTN_6 0x106
	    BTN_7 0x107
	    BTN_8 0x108
	    BTN_9 0x109
	    BTN_MOUSE 0x110
	    BTN_LEFT 0x110
	    BTN_RIGHT 0x111
	    BTN_MIDDLE 0x112
	    BTN_SIDE 0x113
	    BTN_EXTRA 0x114
	    BTN_FORWARD 0x115
	    BTN_BACK 0x116
	    BTN_TASK 0x117
	    BTN_JOYSTICK 0x120
	    BTN_TRIGGER 0x120
	    BTN_THUMB 0x121
	    BTN_THUMB2 0x122
	    BTN_TOP 0x123
	    BTN_TOP2 0x124
	    BTN_PINKIE 0x125
	    BTN_BASE 0x126
	    BTN_BASE2 0x127
	    BTN_BASE3 0x128
	    BTN_BASE4 0x129
	    BTN_BASE5 0x12a
	    BTN_BASE6 0x12b
	    BTN_DEAD 0x12f
	    BTN_GAMEPAD 0x130
	    BTN_SOUTH 0x130
	    BTN_A 0x130
	    BTN_EAST 0x131
	    BTN_B 0x131
	    BTN_C 0x132
	    BTN_NORTH 0x133
	    BTN_X 0x133
	    BTN_WEST 0x134
	    BTN_Y 0x134
	    BTN_Z 0x135
	    BTN_TL 0x136
	    BTN_TR 0x137
	    BTN_TL2 0x138
	    BTN_TR2 0x139
	    BTN_SELECT 0x13a
	    BTN_START 0x13b
	    BTN_MODE 0x13c
	    BTN_THUMBL 0x13d
	    BTN_THUMBR 0x13e
	    BTN_DIGI 0x140
	    BTN_TOOL_PEN 0x140
	    BTN_TOOL_RUBBER 0x141
	    BTN_TOOL_BRUSH 0x142
	    BTN_TOOL_PENCIL 0x143
	    BTN_TOOL_AIRBRUSH 0x144
	    BTN_TOOL_FINGER 0x145
	    BTN_TOOL_MOUSE 0x146
	    BTN_TOOL_LENS 0x147
	    BTN_TOOL_QUINTTAP 0x148
	    BTN_STYLUS3 0x149
	    BTN_TOUCH 0x14a
	    BTN_STYLUS 0x14b
	    BTN_STYLUS2 0x14c
	    BTN_TOOL_DOUBLETAP 0x14d
	    BTN_TOOL_TRIPLETAP 0x14e
	    BTN_TOOL_QUADTAP 0x14f
	    BTN_WHEEL 0x150
	    BTN_GEAR_DOWN 0x150
	    BTN_GEAR_UP 0x151
	    KEY_OK 0x160
	    KEY_SELECT 0x161
	    KEY_GOTO 0x162
	    KEY_CLEAR 0x163
	    KEY_POWER2 0x164
	    KEY_OPTION 0x165
	    KEY_INFO 0x166
	    KEY_TIME 0x167
	    KEY_VENDOR 0x168
	    KEY_ARCHIVE 0x169
	    KEY_PROGRAM 0x16a
	    KEY_CHANNEL 0x16b
	    KEY_FAVORITES 0x16c
	    KEY_EPG 0x16d
	    KEY_PVR 0x16e
	    KEY_MHP 0x16f
	    KEY_LANGUAGE 0x170
	    KEY_TITLE 0x171
	    KEY_SUBTITLE 0x172
	    KEY_ANGLE 0x173
	    KEY_FULL_SCREEN 0x174
	    KEY_ZOOM 0x174
	    KEY_MODE 0x175
	    KEY_KEYBOARD 0x176
	    KEY_ASPECT_RATIO 0x177
	    KEY_SCREEN 0x177
	    KEY_PC 0x178
	    KEY_TV 0x179
	    KEY_TV2 0x17a
	    KEY_VCR 0x17b
	    KEY_VCR2 0x17c
	    KEY_SAT 0x17d
	    KEY_SAT2 0x17e
	    KEY_CD 0x17f
	    KEY_TAPE 0x180
	    KEY_RADIO 0x181
	    KEY_TUNER 0x182
	    KEY_PLAYER 0x183
	    KEY_TEXT 0x184
	    KEY_DVD 0x185
	    KEY_AUX 0x186
	    KEY_MP3 0x187
	    KEY_AUDIO 0x188
	    KEY_VIDEO 0x189
	    KEY_DIRECTORY 0x18a
	    KEY_LIST 0x18b
	    KEY_MEMO 0x18c
	    KEY_CALENDAR 0x18d
	    KEY_RED 0x18e
	    KEY_GREEN 0x18f
	    KEY_YELLOW 0x190
	    KEY_BLUE 0x191
	    KEY_CHANNELUP 0x192
	    KEY_CHANNELDOWN 0x193
	    KEY_FIRST 0x194
	    KEY_LAST 0x195
	    KEY_AB 0x196
	    KEY_NEXT 0x197
	    KEY_RESTART 0x198
	    KEY_SLOW 0x199
	    KEY_SHUFFLE 0x19a
	    KEY_BREAK 0x19b
	    KEY_PREVIOUS 0x19c
	    KEY_DIGITS 0x19d
	    KEY_TEEN 0x19e
	    KEY_TWEN 0x19f
	    KEY_VIDEOPHONE 0x1a0
	    KEY_GAMES 0x1a1
	    KEY_ZOOMIN 0x1a2
	    KEY_ZOOMOUT 0x1a3
	    KEY_ZOOMRESET 0x1a4
	    KEY_WORDPROCESSOR 0x1a5
	    KEY_EDITOR 0x1a6
	    KEY_SPREADSHEET 0x1a7
	    KEY_GRAPHICSEDITOR 0x1a8
	    KEY_PRESENTATION 0x1a9
	    KEY_DATABASE 0x1aa
	    KEY_NEWS 0x1ab
	    KEY_VOICEMAIL 0x1ac
	    KEY_ADDRESSBOOK 0x1ad
	    KEY_MESSENGER 0x1ae
	    KEY_DISPLAYTOGGLE 0x1af
	    KEY_BRIGHTNESS_TOGGLE 32
	    KEY_SPELLCHECK 0x1b0
	    KEY_LOGOFF 0x1b1
	    KEY_DOLLAR 0x1b2
	    KEY_EURO 0x1b3
	    KEY_FRAMEBACK 0x1b4
	    KEY_FRAMEFORWARD 0x1b5
	    KEY_CONTEXT_MENU 0x1b6
	    KEY_MEDIA_REPEAT 0x1b7
	    KEY_10CHANNELSUP 0x1b8
	    KEY_10CHANNELSDOWN 0x1b9
	    KEY_IMAGES 0x1ba
	    KEY_NOTIFICATION_CENTER 0x1bc
	    KEY_PICKUP_PHONE 0x1bd
	    KEY_HANGUP_PHONE 0x1be
	    KEY_DEL_EOL 0x1c0
	    KEY_DEL_EOS 0x1c1
	    KEY_INS_LINE 0x1c2
	    KEY_DEL_LINE 0x1c3
	    KEY_FN 0x1d0
	    KEY_FN_ESC 0x1d1
	    KEY_FN_F1 0x1d2
	    KEY_FN_F2 0x1d3
	    KEY_FN_F3 0x1d4
	    KEY_FN_F4 0x1d5
	    KEY_FN_F5 0x1d6
	    KEY_FN_F6 0x1d7
	    KEY_FN_F7 0x1d8
	    KEY_FN_F8 0x1d9
	    KEY_FN_F9 0x1da
	    KEY_FN_F10 0x1db
	    KEY_FN_F11 0x1dc
	    KEY_FN_F12 0x1dd
	    KEY_FN_1 0x1de
	    KEY_FN_2 0x1df
	    KEY_FN_D 0x1e0
	    KEY_FN_E 0x1e1
	    KEY_FN_F 0x1e2
	    KEY_FN_S 0x1e3
	    KEY_FN_B 0x1e4
	    KEY_FN_RIGHT_SHIFT 0x1e5
	    KEY_BRL_DOT1 0x1f1
	    KEY_BRL_DOT2 0x1f2
	    KEY_BRL_DOT3 0x1f3
	    KEY_BRL_DOT4 0x1f4
	    KEY_BRL_DOT5 0x1f5
	    KEY_BRL_DOT6 0x1f6
	    KEY_BRL_DOT7 0x1f7
	    KEY_BRL_DOT8 0x1f8
	    KEY_BRL_DOT9 0x1f9
	    KEY_BRL_DOT10 0x1fa
	    KEY_NUMERIC_0 0x200
	    KEY_NUMERIC_1 0x201
	    KEY_NUMERIC_2 0x202
	    KEY_NUMERIC_3 0x203
	    KEY_NUMERIC_4 0x204
	    KEY_NUMERIC_5 0x205
	    KEY_NUMERIC_6 0x206
	    KEY_NUMERIC_7 0x207
	    KEY_NUMERIC_8 0x208
	    KEY_NUMERIC_9 0x209
	    KEY_NUMERIC_STAR 0x20a
	    KEY_NUMERIC_POUND 0x20b
	    KEY_NUMERIC_A 0x20c
	    KEY_NUMERIC_B 0x20d
	    KEY_NUMERIC_C 0x20e
	    KEY_NUMERIC_D 0x20f
	    KEY_CAMERA_FOCUS 0x210
	    KEY_WPS_BUTTON 0x211
	    KEY_TOUCHPAD_TOGGLE 0x212
	    KEY_TOUCHPAD_ON 0x213
	    KEY_TOUCHPAD_OFF 0x214
	    KEY_CAMERA_ZOOMIN 0x215
	    KEY_CAMERA_ZOOMOUT 0x216
	    KEY_CAMERA_UP 0x217
	    KEY_CAMERA_DOWN 0x218
	    KEY_CAMERA_LEFT 0x219
	    KEY_CAMERA_RIGHT 0x21a
	    KEY_ATTENDANT_ON 0x21b
	    KEY_ATTENDANT_OFF 0x21c
	    KEY_ATTENDANT_TOGGLE 0x21d
	    KEY_LIGHTS_TOGGLE 0x21e
	    BTN_DPAD_UP 0x220
	    BTN_DPAD_DOWN 0x221
	    BTN_DPAD_LEFT 0x222
	    BTN_DPAD_RIGHT 0x223
	    KEY_ALS_TOGGLE 0x230
	    KEY_ROTATE_LOCK_TOGGLE 0x231
	    KEY_BUTTONCONFIG 0x240
	    KEY_TASKMANAGER 0x241
	    KEY_JOURNAL 0x242
	    KEY_CONTROLPANEL 0x243
	    KEY_APPSELECT 0x244
	    KEY_SCREENSAVER 0x245
	    KEY_VOICECOMMAND 0x246
	    KEY_ASSISTANT 0x247
	    KEY_KBD_LAYOUT_NEXT 0x248
	    KEY_EMOJI_PICKER 0x249
	    KEY_DICTATE 0x24a
	    KEY_BRIGHTNESS_MIN 0x250
	    KEY_BRIGHTNESS_MAX 0x251
	    KEY_KBDINPUTASSIST_PREV 0x260
	    KEY_KBDINPUTASSIST_NEXT 0x261
	    KEY_KBDINPUTASSIST_PREVGROUP 0x262
	    KEY_KBDINPUTASSIST_NEXTGROUP 0x263
	    KEY_KBDINPUTASSIST_ACCEPT 0x264
	    KEY_KBDINPUTASSIST_CANCEL 0x265
	    KEY_RIGHT_UP 0x266
	    KEY_RIGHT_DOWN 0x267
	    KEY_LEFT_UP 0x268
	    KEY_LEFT_DOWN 0x269
	    KEY_ROOT_MENU 0x26a
	    KEY_MEDIA_TOP_MENU 0x26b
	    KEY_NUMERIC_11 0x26c
	    KEY_NUMERIC_12 0x26d
	    KEY_AUDIO_DESC 0x26e
	    KEY_3D_MODE 0x26f
	    KEY_NEXT_FAVORITE 0x270
	    KEY_STOP_RECORD 0x271
	    KEY_PAUSE_RECORD 0x272
	    KEY_VOD 0x273
	    KEY_UNMUTE 0x274
	    KEY_FASTREVERSE 0x275
	    KEY_SLOWREVERSE 0x276
	    KEY_DATA 0x277
	    KEY_ONSCREEN_KEYBOARD 0x278
	    KEY_PRIVACY_SCREEN_TOGGLE 0x279
	    KEY_SELECTIVE_SCREENSHOT 0x27a
	    KEY_NEXT_ELEMENT 0x27b
	    KEY_PREVIOUS_ELEMENT 0x27c
	    KEY_AUTOPILOT_ENGAGE_TOGGLE 0x27d
	    KEY_MARK_WAYPOINT 0x27e
	    KEY_SOS 0x27f
	    KEY_NAV_CHART 0x280
	    KEY_FISHING_CHART 0x281
	    KEY_SINGLE_RANGE_RADAR 0x282
	    KEY_DUAL_RANGE_RADAR 0x283
	    KEY_RADAR_OVERLAY 0x284
	    KEY_TRADITIONAL_SONAR 0x285
	    KEY_CLEARVU_SONAR 0x286
	    KEY_SIDEVU_SONAR 0x287
	    KEY_NAV_INFO 0x288
	    KEY_BRIGHTNESS_MENU 0x289
	    KEY_MACRO1 0x290
	    KEY_MACRO2 0x291
	    KEY_MACRO3 0x292
	    KEY_MACRO4 0x293
	    KEY_MACRO5 0x294
	    KEY_MACRO6 0x295
	    KEY_MACRO7 0x296
	    KEY_MACRO8 0x297
	    KEY_MACRO9 0x298
	    KEY_MACRO10 0x299
	    KEY_MACRO11 0x29a
	    KEY_MACRO12 0x29b
	    KEY_MACRO13 0x29c
	    KEY_MACRO14 0x29d
	    KEY_MACRO15 0x29e
	    KEY_MACRO16 0x29f
	    KEY_MACRO17 0x2a0
	    KEY_MACRO18 0x2a1
	    KEY_MACRO19 0x2a2
	    KEY_MACRO20 0x2a3
	    KEY_MACRO21 0x2a4
	    KEY_MACRO22 0x2a5
	    KEY_MACRO23 0x2a6
	    KEY_MACRO24 0x2a7
	    KEY_MACRO25 0x2a8
	    KEY_MACRO26 0x2a9
	    KEY_MACRO27 0x2aa
	    KEY_MACRO28 0x2ab
	    KEY_MACRO29 0x2ac
	    KEY_MACRO30 0x2ad
	    KEY_MACRO_RECORD_START 0x2b0
	    KEY_MACRO_RECORD_STOP 0x2b1
	    KEY_MACRO_PRESET_CYCLE 0x2b2
	    KEY_MACRO_PRESET1 0x2b3
	    KEY_MACRO_PRESET2 0x2b4
	    KEY_MACRO_PRESET3 0x2b5
	    KEY_KBD_LCD_MENU1 0x2b8
	    KEY_KBD_LCD_MENU2 0x2b9
	    KEY_KBD_LCD_MENU3 0x2ba
	    KEY_KBD_LCD_MENU4 0x2bb
	    KEY_KBD_LCD_MENU5 0x2bc
	    BTN_TRIGGER_HAPPY 0x2c0
	    BTN_TRIGGER_HAPPY1 0x2c0
	    BTN_TRIGGER_HAPPY2 0x2c1
	    BTN_TRIGGER_HAPPY3 0x2c2
	    BTN_TRIGGER_HAPPY4 0x2c3
	    BTN_TRIGGER_HAPPY5 0x2c4
	    BTN_TRIGGER_HAPPY6 0x2c5
	    BTN_TRIGGER_HAPPY7 0x2c6
	    BTN_TRIGGER_HAPPY8 0x2c7
	    BTN_TRIGGER_HAPPY9 0x2c8
	    BTN_TRIGGER_HAPPY10 0x2c9
	    BTN_TRIGGER_HAPPY11 0x2ca
	    BTN_TRIGGER_HAPPY12 0x2cb
	    BTN_TRIGGER_HAPPY13 0x2cc
	    BTN_TRIGGER_HAPPY14 0x2cd
	    BTN_TRIGGER_HAPPY15 0x2ce
	    BTN_TRIGGER_HAPPY16 0x2cf
	    BTN_TRIGGER_HAPPY17 0x2d0
	    BTN_TRIGGER_HAPPY18 0x2d1
	    BTN_TRIGGER_HAPPY19 0x2d2
	    BTN_TRIGGER_HAPPY20 0x2d3
	    BTN_TRIGGER_HAPPY21 0x2d4
	    BTN_TRIGGER_HAPPY22 0x2d5
	    BTN_TRIGGER_HAPPY23 0x2d6
	    BTN_TRIGGER_HAPPY24 0x2d7
	    BTN_TRIGGER_HAPPY25 0x2d8
	    BTN_TRIGGER_HAPPY26 0x2d9
	    BTN_TRIGGER_HAPPY27 0x2da
	    BTN_TRIGGER_HAPPY28 0x2db
	    BTN_TRIGGER_HAPPY29 0x2dc
	    BTN_TRIGGER_HAPPY30 0x2dd
	    BTN_TRIGGER_HAPPY31 0x2de
	    BTN_TRIGGER_HAPPY32 0x2df
	    BTN_TRIGGER_HAPPY33 0x2e0
	    BTN_TRIGGER_HAPPY34 0x2e1
	    BTN_TRIGGER_HAPPY35 0x2e2
	    BTN_TRIGGER_HAPPY36 0x2e3
	    BTN_TRIGGER_HAPPY37 0x2e4
	    BTN_TRIGGER_HAPPY38 0x2e5
	    BTN_TRIGGER_HAPPY39 0x2e6
	    BTN_TRIGGER_HAPPY40 0x2e7
	    KEY_MAX 0x2ff
	}
	EV_REL 0x02 {
	    REL_X			0x00
	    REL_Y			0x01
	    REL_Z			0x02
	    REL_RX			0x03
	    REL_RY			0x04
	    REL_RZ			0x05
	    REL_HWHEEL		0x06
	    REL_DIAL		0x07
	    REL_WHEEL		0x08
	    REL_MISC		0x09
	    REL_RESERVED		0x0a
	    REL_WHEEL_HI_RES	0x0b
	    REL_HWHEEL_HI_RES	0x0c
	    REL_MAX			0x0f
	}
	EV_ABS 0x03 {
	    ABS_X			0x00
	    ABS_Y			0x01
	    ABS_Z			0x02
	    ABS_RX			0x03
	    ABS_RY			0x04
	    ABS_RZ			0x05
	    ABS_THROTTLE		0x06
	    ABS_RUDDER		0x07
	    ABS_WHEEL		0x08
	    ABS_GAS			0x09
	    ABS_BRAKE		0x0a
	    ABS_HAT0X		0x10
	    ABS_HAT0Y		0x11
	    ABS_HAT1X		0x12
	    ABS_HAT1Y		0x13
	    ABS_HAT2X		0x14
	    ABS_HAT2Y		0x15
	    ABS_HAT3X		0x16
	    ABS_HAT3Y		0x17
	    ABS_PRESSURE		0x18
	    ABS_DISTANCE		0x19
	    ABS_TILT_X		0x1a
	    ABS_TILT_Y		0x1b
	    ABS_TOOL_WIDTH		0x1c
	    ABS_VOLUME		0x20
	    ABS_PROFILE		0x21
	    ABS_MISC		0x28
	    ABS_RESERVED		0x2e
	    ABS_MT_SLOT		0x2f
	    ABS_MT_TOUCH_MAJOR	0x30
	    ABS_MT_TOUCH_MINOR	0x31
	    ABS_MT_WIDTH_MAJOR	0x32
	    ABS_MT_WIDTH_MINOR	0x33
	    ABS_MT_ORIENTATION	0x34
	    ABS_MT_POSITION_X	0x35
	    ABS_MT_POSITION_Y	0x36
	    ABS_MT_TOOL_TYPE	0x37
	    ABS_MT_BLOB_ID		0x38
	    ABS_MT_TRACKING_ID	0x39
	    ABS_MT_PRESSURE		0x3a
	    ABS_MT_DISTANCE		0x3b
	    ABS_MT_TOOL_X		0x3c
	    ABS_MT_TOOL_Y		0x3d
	    ABS_MAX			0x3f
	}
	EV_MSC 0x04 {
	    MSC_SERIAL		0x00
	    MSC_PULSELED		0x01
	    MSC_GESTURE		0x02
	    MSC_RAW			0x03
	    MSC_SCAN		0x04
	    MSC_TIMESTAMP		0x05
	    MSC_MAX			0x07
	}
	EV_SW  0x05 {
	    SW_LID			0x00
	    SW_TABLET_MODE		0x01
	    SW_HEADPHONE_INSERT	0x02
	    SW_RFKILL_ALL		0x03
	    SW_MICROPHONE_INSERT	0x04
	    SW_DOCK			0x05
	    SW_LINEOUT_INSERT	0x06
	    SW_JACK_PHYSICAL_INSERT 0x07
	    SW_VIDEOOUT_INSERT	0x08
	    SW_CAMERA_LENS_COVER	0x09
	    SW_KEYPAD_SLIDE		0x0a
	    SW_FRONT_PROXIMITY	0x0b
	    SW_ROTATE_LOCK		0x0c
	    SW_LINEIN_INSERT	0x0d
	    SW_MUTE_DEVICE		0x0e
	    SW_PEN_INSERTED		0x0f
	    SW_MACHINE_COVER	0x10
	    SW_MAX			0x10
	}
	EV_LED 0x11 {
	    LED_NUML		0x00
	    LED_CAPSL		0x01
	    LED_SCROLLL		0x02
	    LED_COMPOSE		0x03
	    LED_KANA		0x04
	    LED_SLEEP		0x05
	    LED_SUSPEND		0x06
	    LED_MUTE		0x07
	    LED_MISC		0x08
	    LED_MAIL		0x09
	    LED_CHARGING		0x0a
	    LED_MAX			0x0f
	}
	EV_SND 0x12 {
	    SND_CLICK		0x00
	    SND_BELL		0x01
	    SND_TONE		0x02
	    SND_MAX			0x07
	}
	EV_REP 0x14 {
	    REP_DELAY		0x00
	    REP_PERIOD		0x01
	    REP_MAX			0x01
	}
	EV_FF  0x15 {
	}
	EV_PWR 0x16 {
	}
	EV_FF_STATUS 0x17 {
	}
	EV_MAX 0x1f {
	}
    } {
	set eventvalue [expr {0+$eventvalue}]
	dict set namevalues $event $eventvalue
	dict set eventnames $eventvalue $event
	foreach {code codevalue} $codes {
	    if {[catch {expr {0+$codevalue}} result]} {
		error "handling {$code} and {$codevalue} computed \"$result\""
	    }
	    dict set namevalues $code $codevalue
	    dict set events $eventvalue $result [list $event $code]
	}
    }
    
    proc read-event {fp} { read $fp }
    
    proc is-read-event {binary} { expr {[string length $binary] > 0 && ([string length $binary] % 24) == 0} }
    
    proc decode-event {binary} {
	# puts "decoding [expr {[string length $binary]/24.0}] events"
	set decoded {}
	for {set x 16} {$x < [string length $binary]} {incr x 24} {
	    set n [binary scan $binary x${x}ttn type code value]
	    if {$n == 3} {
		lappend decoded $type $code $value
	    }
	    # puts "decode-event [string length $binary] bytes, scan found $n objects"
	}
	return $decoded
    }
    
    proc print-event {event} {
	# puts "printing [expr {[llength $event]/3.0}] events"
	variable events
	variable eventnames
	foreach {type code value} $event {
	    if {[dict exists $events $type $code]} {
		puts [dict get $::evdev::events $type $code]
	    } elseif {[dict exists $eventnames $type]} {
		puts "[dict get $::evdev::eventnames $type] $code $value"
	    } else {
		puts "$type $code $value"
	    }
	}
    }
    
    # read eval print loop over events
    proc eventrepl {fp handler} {
	# puts "eventrepl $fp $handler"
	while {1} {
	    set binary [read-event $fp]
	    if {[is-read-event $binary]} { 
		{*}$handler [decode-event $binary]
	    } else {
		break
	    }
	}
	if {[eof $fp]} {
	    puts "eof"
	    close $fp
	}
    }
    
    #
    # touch decoded events
    #
    # touch events are bracketed by {EV_SYN SYN_REPORT 0} which gives the true time for all
    # events received after the previous {EV_SYN SYN_REPORT 0}.
    #
    # when no touches are active, the current slot is implicitly 0
    #
    # {EV_ABS ABS_MT_TRACKING_ID id} is a unique touch identifier assigned when the touch
    # begins, associated with the current slot, set to -1 when the touch ends.
    #
    # the coordinates on the pi touchscreen are upside down because of whatever.  The fix
    # suggested on the pi forums, whatever it was, does not fix the coodinates in input 
    # events.
    #
    
    #
    # s seconds - not used
    # u microseconds - not used
    # 
    # t touch_number
    # x absolute_x 
    # y absolute_y
    # i touch_identifer
    # k touch_on/off
    #
    variable touchcodes

    foreach {type code translation} {
	EV_SYN SYN_REPORT *
	EV_ABS ABS_MT_SLOT t
	EV_ABS ABS_MT_POSITION_X x
	EV_ABS ABS_MT_POSITION_Y y
	EV_ABS ABS_MT_TRACKING_ID i
	EV_ABS ABS_MT_TOUCH_MAJOR {}
	EV_ABS ABS_MT_TOUCH_MINOR {}
	EV_ABS ABS_MT_WIDTH_MAJOR {}
	EV_ABS ABS_MT_WIDTH_MINOR {}
	EV_ABS ABS_MT_ORIENTATION {}
	EV_ABS ABS_MT_TOOL_TYPE {}
	EV_ABS ABS_MT_BLOB_ID {}
	EV_ABS ABS_MT_PRESSURE {}
	EV_ABS ABS_MT_DISTANCE {}
	EV_ABS ABS_MT_TOOL_X {}
	EV_ABS ABS_MT_TOOL_Y {}
	EV_ABS ABS_X {}
	EV_ABS ABS_Y {}
	EV_KEY BTN_TOUCH {}
    } {
	set type [expr {0+[dict get $namevalues $type]}]
	set code [expr {0+[dict get $namevalues $code]}]
	dict set touchcodes $type $code $translation
    }
    
    proc decode-touch {binary} {
	variable touchcodes
	set touchq {}
	for {set x 16} {$x < [string length $binary]} {incr x 24} {
	    if {[binary scan $binary x${x}ttn type code value] == 3} {
		if { ! [dict exists $touchcodes $type $code]} {
		    puts "unknown $type $code $value in touch stream"
		    continue
		}
		set tcode [dict get $touchcodes $type $code]
		if {$tcode eq {} || $tcode eq {*}}  { continue }
		lappend touchq $tcode $value
	    }
	}
	return $touchq
    }
    
    # read eval print loop over touch events
    proc touchrepl {fp handler} {
	while {1} {
	    set binary [read-event $fp]
	    if { ! [is-read-event $binary]} {
		break
	    }
	    set decode [decode-touch $binary]
	    if {$decode ne {}} { {*}$handler $decode }
	}
	if {[eof $fp]} { close $fp }
    }
    
    #
    # mouse events
    #
    proc read-mouse {fp} { read $fp 3 }
    
    proc is-read-mouse {binary} { expr {[string length $binary] == 3} }
    
    proc decode-mouse {binary} {
	set n [binary scan $binary cucucu byte1 byte2 byte3]
	if {$n == 3} {
	    return [list $byte1 $byte2 $byte3]
	}
	return [list]
    }
    
    # read from mouse device, decode, and print until done
    proc mouserepl {fp handler} {
	while {1} {
	    set binary [read-mouse $fp]
	    if {[is-read-mouse $binary]} {
		{*}${handler} [decode-mouse $binary]
	    } else {
		break
	    }
	}
	if {[eof $fp]} { close $fp }
    }
}

proc ::evdev::repl {repl input handler} {
    set fp [open $input r]
    fconfigure $fp -encoding binary -buffering none -blocking 0
    fileevent $fp readable [list $repl $fp $handler]
    puts "filevent {$input} readable {$repl $fp $handler}"
}
    
proc ::evdev::mouse {input {handler {puts}}} {
    ::evdev::repl ::evdev::mouserepl $input $handler
}

proc ::evdev::event {input {handler {::evdev::print-event}}} {
    ::evdev::repl ::evdev::eventrepl $input $handler
}

proc ::evdev::touch {input {handler {puts}}} {
    ::evdev::repl ::evdev::touchrepl $input $handler
}

