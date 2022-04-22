; asmMain.asm header

includelib	"C:\Program Files (x86)\Windows Kits\10\Lib\10.0.18362.0\um\x86\kernel32.Lib"
includelib  "C:\irvine\Irvine32.lib"

.486
.model flat,stdcall
.stack 4096

;-------------------- Myproc ----------------------

findStr proto,source:ptr byte,strSize:dword,target:word
myReadFile proto ,fileHandleR:DWORD,bufR:ptr byte,bytesR:dword	
myWirteFile proto ,fileHandleW:DWORD,bufW:ptr byte,bytesW:dword	
myROR	proto ,bufROR:ptr byte,	bufSize:dword


;-------------------- win32 api ----------------------

AreFileApisANSI proto
ExitProcess proto, dwExitCode: dword
GetFileSize proto, handle:dword ,filesize:ptr dword
FormatMessageA proto,dwFlags:dword ,lpSource:ptr dword ,dwMessageId:dword ,dwLanguageId:dword ,lpBuffer:ptr dword ,nSize:dword ,Arguments:ptr dword 
CreateFileA proto, lpFilename:PTR BYTE,	dwDesiredAccess:DWORD,	dwShareMode:DWORD,	lpSecurityAttributes:DWORD,  dwCreationDisposition:DWORD,	dwFlagsAndAttributes:DWORD,	hTemplateFile:DWORD		
WriteFile proto ,hFile:dword,lpBuffer:dword,nNumberOfBytesToWrite:dword,lpNumberOfBytesWritten:dword,lpOverlapped:dword
ReadFile proto ,hFile:dword,lpBuffer:dword,nNumberOfBytesToRead:dword,lpNumberOfBytesRead:dword,lpOverlapped:dword
setStr proto,source:ptr byte,endword:dword
SetFilePointer proto,hFile:dword,lDistanceToMove:dword,lpDistanceToMoveHigh:dword,dwMoveMethod:dword
CloseHandle PROTO ,hObject:dword

;--------- my own constants --------------
DO_NOT_SHARE = 0
NULL = 0
TRUE = 1
FALSE = 0
TAB = 9		; ASCII code for Horiz Tab
;-----------------------------------------

HANDLE TEXTEQU <DWORD>		; used in Win32 API documentation

;  Input Mode flags (used by GetConsoleMode & SetConsoleMode):
ENABLE_PROCESSED_INPUT = 1
ENABLE_LINE_INPUT      = 2
ENABLE_ECHO_INPUT      = 4
ENABLE_WINDOW_INPUT    = 8
ENABLE_MOUSE_INPUT     = 16

; Event constants
KEY_EVENT       =  1
MOUSE_EVENT     =  2
WINDOW_BUFFER_SIZE_EVENT = 4          ; window change event record
MENU_EVENT      = 8                   ; menu event record
FOCUS_EVENT     = 16                  ; focus change

; ControlKeyState constants (used by ReadKey)
KEY_MASKS  = 00011111b		; Mask if any Shift/Ctrl/Alt flag is set
ALT_MASK   = 00000011b		; Left and right Alt key flags
CTRL_MASK  = 00001100b		; Left and right Alt key flags
SHIFT_MASK = 00010000b		; Left or right Shift key flag

KBDOWN_FLAG = 00000001h		; Bit set for press, clear for release

;  Output mode flags  (used by GetConsoleMode & SetConsoleMode):
ENABLE_PROCESSED_OUTPUT    = 1
ENABLE_WRAP_AT_EOL_OUTPUT  = 2

; Constants found in WINNT.H
FILE_SHARE_READ                 = 1
FILE_SHARE_WRITE                = 2
FILE_SHARE_DELETE               = 4

FILE_ATTRIBUTE_READONLY         = 1
FILE_ATTRIBUTE_HIDDEN           = 2
FILE_ATTRIBUTE_SYSTEM           = 4
FILE_ATTRIBUTE_DIRECTORY        = 10h
FILE_ATTRIBUTE_ARCHIVE          = 20h
FILE_ATTRIBUTE_DEVICE           = 40h
FILE_ATTRIBUTE_NORMAL           = 80h
FILE_ATTRIBUTE_TEMPORARY        = 100h
FILE_ATTRIBUTE_SPARSE_FILE      = 200h
FILE_ATTRIBUTE_REPARSE_POINT    = 400h
FILE_ATTRIBUTE_COMPRESSED       = 800h
FILE_ATTRIBUTE_OFFLINE          =    1000h
FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = 2000h
FILE_ATTRIBUTE_ENCRYPTED           = 4000h

FILE_READ_DATA = 1
FILE_WRITE_DATA = 2
FILE_APPEND_DATA = 4
FILE_DELETE_CHILD = 40h

GENERIC_READ     = 80000000h
GENERIC_WRITE    = 40000000h
GENERIC_EXECUTE  = 20000000h
GENERIC_ALL      = 10000000h

; Memory allocation constants
HEAP_NO_SERIALIZE              = 00000001h
HEAP_GROWABLE                  = 00000002h
HEAP_GENERATE_EXCEPTIONS       = 00000004h
HEAP_ZERO_MEMORY               = 00000008h
HEAP_REALLOC_IN_PLACE_ONLY     = 00000010h

; Error Handler Variables
FORMAT_MESSAGE_ALLOCATE_BUFFER     = 100h
FORMAT_MESSAGE_FROM_SYSTEM         = 1000h

;------------- Message Box Constants ---------------

; Icons:
MB_ICONHAND            = 10h
MB_ICONQUESTION        = 20h
MB_ICONEXCLAMATION     = 30h
MB_ICONASTERISK        = 40h
MB_USERICON            = 80h
MB_ICONWARNING         = MB_ICONEXCLAMATION
MB_ICONERROR           = MB_ICONHAND
MB_ICONINFORMATION     = MB_ICONASTERISK
MB_ICONSTOP            = MB_ICONHAND

; Buttons:
MB_OK         = 0
MB_OKCANCEL   = 1
MB_ABORTRETRYIGNORE = 2
MB_YESNOCANCEL = 3
MB_YESNO       = 4
MB_RETRYCANCEL = 5
MB_CANCELTRYCONTINUE = 6
MB_HELP        =  4000h          ; does not close the window

; Select the default button:
MB_DEFBUTTON1 = 0
MB_DEFBUTTON2 = 100h
MB_DEFBUTTON3 = 200h
MB_DEFBUTTON4 = 300h

; Modal control buttons:
MB_APPLMODAL     =  0
MB_SYSTEMMODAL   =  1000h	; dialog floats above all windows
MB_TASKMODAL     =  2000h

; Return values:
IDOK               = 1
IDCANCEL           = 2
IDABORT            = 3
IDRETRY            = 4
IDIGNORE           = 5
IDYES              = 6
IDNO               = 7
IDCLOSE            = 8
IDHELP             = 9
IDTRYAGAIN         = 10
IDCONTINUE         = 11
IDTIMEOUT          = 32000

;------------------ From winbase.h ----------------------------
CREATE_NEW         = 1
CREATE_ALWAYS      = 2
OPEN_EXISTING      = 3
OPEN_ALWAYS        = 4
TRUNCATE_EXISTING  = 5

FILE_BEGIN         =  0
FILE_CURRENT       =  1
FILE_END           =  2

INVALID_HANDLE_VALUE = -1

;--------------------From wincon.h ---------------------------

; ControlKeyState flags

RIGHT_ALT_PRESSED    = 0001h      ; the right alt key is pressed.
LEFT_ALT_PRESSED     = 0002h      ; the left alt key is pressed.
RIGHT_CTRL_PRESSED   = 0004h      ; the right ctrl key is pressed.
LEFT_CTRL_PRESSED    = 0008h      ; the left ctrl key is pressed.
SHIFT_PRESSED        = 0010h      ; the shift key is pressed.
NUMLOCK_ON           = 0020h      ; the numlock light is on.
SCROLLLOCK_ON        = 0040h      ; the scrolllock light is on.
CAPSLOCK_ON          = 0080h      ; the capslock light is on.
ENHANCED_KEY         = 0100h      ; the key is enhanced.

;---------------------- from WinUser.h -------------------------

VK_NUMLOCK  =   90h
VK_SCROLL   =   91h
VK_LSHIFT   =   0A0h
VK_RSHIFT   =   0A1h
VK_LCONTROL =   0A2h
VK_RCONTROL =   0A3h
VK_LMENU    =   0A4h
VK_RMENU    =   0A5h

;------------------- Irvine32.inc------------------------------
CloseFile PROTO		; close a file handle
Clrscr PROTO		; clear the screen
CreateOutputFile PROTO		; create file for writing
Crlf PROTO		; output carriage-return / linefeed
Delay PROTO		; delay for n milliseconds
DumpMem PROTO		; display memory dump
DumpRegs PROTO		; display register dump
GetCommandTail PROTO		; get command-line string
GetDateTime PROTO,		; get system date and time
  startTime:PTR QWORD
GetMaxXY PROTO		; get console rows and columns
GetMseconds PROTO		; get milliseconds past midnight
GetTextColor PROTO		; Get the console window's color attributes. 
Gotoxy PROTO		; set the cursor position
IsDigit PROTO		; return ZF=1 if AL is a decimal digit
MsgBox PROTO		; display popup message box
MsgBoxAsk PROTO		; display popup yes/no question box
OpenInputFile PROTO		; open file in input mode
ParseDecimal32 PROTO		; convert unsigned decimal string to 32-bit binary
ParseInteger32 PROTO		; convert signed decimal string to 32-bit binary
Randomize PROTO		; reseed random number generator
RandomRange PROTO		; generate random integer in specified range
Random32 PROTO		; generate 32-bit random integer
ReadInt PROTO		; read signed decimal integer from console
ReadChar PROTO		; reach single character from console
ReadDec PROTO		; read unsigned decimal integer from console
ReadFloat PROTO		; read floating-point value from keyboard
ReadFromFile PROTO   		; read buffer from input file
ReadHex PROTO		; read hexadecimal integer from console
ReadKey PROTO		; Reads keyboard input if available (4/6/03)
ReadKeyFlush PROTO		; Flush ReadKey buffer and repeat counter (4/6/03)
ReadString PROTO		; read string from console
SetTextColor PROTO		; set console text color
ShowFPUStack PROTO		; write floating-point stack to console window
StrLength PROTO		; returns the length of a string
WaitMsg PROTO		; display wait message, wait for Enter key
WriteBin PROTO		; write integer to output in binary format
WriteBinB PROTO		; write binary integer in byte, word,or doubleword format
WriteChar PROTO		; write single character to output
WriteDec PROTO		; write unsigned decimal integer to output
WriteFloat PROTO		; write ST(0) to console in floating-point format
WriteHex PROTO		; write hexadecimal integer to output
WriteHexB PROTO		; write hexadecimal integer in word or doubleword format
WriteInt PROTO		; write signed integer to output
;WriteStackFrame		; write stack frame data (James Brink--see proto later in this file)
;WriteStackFrameName		; write stack frame data with proc name (James Brink)
WriteString PROTO		; write null-terminated string to output
WriteToFile PROTO		; write a buffer to an output file
WriteWindowsMsg PROTO		; write last error message generated by MS-Windows
GetLastError PROTO
FormatMessage   	EQU <FormatMessageA>