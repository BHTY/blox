; WinTris v1.00

.386
.model flat, stdcall
option casemap:none

include include\windows.inc     ; Main windows header file (akin to Windows.h in C)
include include\user32.inc      ; Windows, controls, etc
include include\kernel32.inc        ; Handles, modules, paths, etc
include include\gdi32.inc       ; Drawing into a device context (ie: painting)

; constants
WindowWidth equ 640
WindowHeight equ 480

.DATA
ClassName db "KleesWClass", 0
AppName db "Blox for Microsoft Windows", 0
Seed dd 0
AboutDlgName db "ABOUT", 0
ActivePiece dd 0
PieceColor dd 0
PieceOrientation dd 0
PiecePositionX dd 0
PiecePositionY dd 0

hInstance HINSTANCE ?
CommandLine LPSTR ?
hDC HDC ?

array dword 200 dup(0)

.CODE

;
; Application entry point
; 

WillEntry proc
	push NULL
	call GetModuleHandle
	mov hInstance, eax
	call GetCommandLineA
	mov CommandLine, eax
	push SW_SHOWDEFAULT
	push CommandLine
	push NULL
	push hInstance
	call WinMain
	push eax
	call ExitProcess
WillEntry endp

; 
; WinMain
; 

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	LOCAL tempHDC:HDC
	
	push 080808080h
	call SeedRand
	
	push hInst
	call Init
	mov hwnd, eax
	
	push NULL
	push 0Ah
	push 1
	push hwnd
	call SetTimer
	
	push hwnd
	call GetDC
	mov tempHDC, eax
	push eax
	call CreateCompatibleDC
	mov hDC, eax
	
	push 200
	push 100
	push tempHDC
	call CreateCompatibleBitmap
	push eax
	push hDC
	call SelectObject
	
	push tempHDC
	push hwnd
	call ReleaseDC

MessageLoop:
	push 0
	push 0
	push NULL
	lea eax, msg
	push eax
	call GetMessage ;get a message from the msg queue
	
	cmp eax, 0
	je EndWinMain
	
	lea eax, msg
	push eax
	call TranslateMessage
	lea eax, msg
	push eax
	call DispatchMessageA
	jmp MessageLoop
	
EndWinMain:
	ret
WinMain endp

; 
; Init function
; Registers window class & creates window
; Registers window handle in EAX
; 

Init proc hInst:HINSTANCE
	LOCAL wc:WNDCLASSA
	LOCAL hWnd:HWND
	
	mov wc.style, CS_HREDRAW or CS_VREDRAW
	mov wc.lpfnWndProc, OFFSET WndProc
	mov wc.cbClsExtra, 0 ;no extra data here
	mov wc.cbWndExtra, 0 ;or here
	mov eax, hInst
	mov wc.hInstance, eax
	mov wc.hbrBackground, COLOR_3DSHADOW + 1
	mov wc.lpszMenuName, 1
	mov wc.lpszClassName, OFFSET ClassName
	
	push 3 ;add dedicated icon
	push hInst
	call LoadIcon
	mov wc.hIcon, eax
	
	push IDC_ARROW
	push NULL
	call LoadCursor
	mov wc.hCursor, eax
	
	lea eax, wc
	push eax
	call RegisterClassA
	
; create the wndow
	push NULL ;no extra data
	push hInst
	push NULL ;use default menu handle
	push NULL ;no parent window
	push WindowHeight ;requested height
	push WindowWidth ;requested width
	push CW_USEDEFAULT ;X
	push CW_USEDEFAULT ;Y
	push WS_OVERLAPPEDWINDOW + WS_VISIBLE ;window style
	push OFFSET AppName
	push OFFSET ClassName
	push 0 ;no extended style bits
	call CreateWindowExA
	mov hWnd, eax
	push SW_SHOW
	push eax
	call ShowWindow
	push eax
	call UpdateWindow
	
	mov eax, hWnd
	ret
Init endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL ps:PAINTSTRUCT
	LOCAL hdc:HDC

	cmp uMsg, WM_PAINT
	je WmPaint
	cmp uMsg, WM_TIMER
	je WmTimer
	cmp uMsg, WM_KEYDOWN
	je WmKeydown
	cmp uMsg, WM_DESTROY
	je WmDestroy
	cmp uMsg, WM_COMMAND
	je WmCommand
	jmp done
	
WmDestroy:
	push 0
	call PostQuitMessage
	xor eax, eax
	ret
	
WmTimer:
	push hWnd
	call TickGame
	jmp done
	
WmKeydown:
	jmp done

WmCommand:
	push wParam
	push hWnd
	call HandleCommand
	jmp done
	
WmPaint:
	lea eax, ps
	push eax
	push hWnd
	call BeginPaint
	mov hdc, eax

	push hDC
	call DrawBoard
	
	push SRCCOPY
	push 200
	push 100
	push 0
	push 0
	push hDC
	push 200
	push 100
	push 0
	push 0
	push hdc
	call StretchBlt
	
	lea eax, ps
	push eax
	push hWnd
	call EndPaint

done:
	push lParam
	push wParam
	push uMsg
	push hWnd
	call DefWindowProcA
	
	ret
WndProc endp

; 
; HandleCommand
; 

HandleCommand proc hWnd:HWND, wParam:WPARAM
	cmp wParam, 40005
	je about
	cmp wParam, 40001
	je newgame
	cmp wParam, 40003
	je controls
	cmp wParam, 108
	je difficulty
	cmp wParam, 106
	je exit
	cmp wParam, 104
	je custom
	jmp done

newgame:
	jmp done

custom:
	push 0
	push AboutDlgProc
	push hWnd
	push 101
	push hInstance
	call DialogBoxParamA
	jmp done
	
controls:
	push 0
	push AboutDlgProc
	push hWnd
	push 102
	push hInstance
	call DialogBoxParamA
	jmp done	

difficulty:
	push 0
	push AboutDlgProc
	push hWnd
	push 105
	push hInstance
	call DialogBoxParamA
	jmp done

about:
	push 0
	push AboutDlgProc
	push hWnd
	push 8
	push hInstance
	call DialogBoxParamA
	jmp done

exit:
	push 0
	call PostQuitMessage
	jmp done
	
done:
	ret
HandleCommand endp

; 
; DrawBoard
; (when a fresh redraw of the entire board is required)
; 

DrawBoard proc dc:HDC
	local rect:RECT
	
	;initialize our rect and our counters
	xor eax, eax
	mov ebx, eax ;EBX will hold the index into the array of pieces
	mov rect.left, eax
	mov rect.top, eax
	mov rect.right, 10
	mov rect.bottom, 10

nextBlock:	
	push [array + ebx*4]
	call CreateSolidBrush
	push eax
	lea eax, rect
	push eax
	push dc
	call FillRect
	inc ebx
	add rect.right, 10
	add rect.left, 10
	cmp rect.right, 100
	jne nextBlock
	mov rect.right, 10
	mov rect.left, 0
	add rect.top, 10
	add rect.bottom, 10
	cmp rect.bottom, 200
	jne nextBlock

	ret
DrawBoard endp

; 
; SeedRand
;

SeedRand proc seed:DWORD
	mov eax, seed
	mov [OFFSET Seed], eax
	ret
SeedRand endp

; 
; GetRand (returns random number in EAX)
; 

GetRand proc
	mov eax, 01h
	ret
GetRand endp

; 
; FillBoard (fills board with random values)
; 

FillBoard proc
	mov ebx, OFFSET array
	mov ecx, 200
	
fill_loop:
	call GetRand
	mov [ebx], eax
	add ebx, 4
	dec ecx
	jne fill_loop
	
	ret
FillBoard endp

; Dialog procedure for ABOUT

AboutDlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	cmp uMsg, WM_COMMAND
	je WmCmd
	cmp uMsg, WM_INITDIALOG
	je WmInitDialog
	mov eax, 0
	ret
	
WmCmd:
	push 1
	push hWnd
	call EndDialog
	mov eax, 1
	ret

WmInitDialog:
	mov eax, 1
	ret

AboutDlgProc endp

; 
; Draw into the compatible DC but then use some clipping magic to only update the important bits
; 

TickGame proc hwnd:HWND
	local dc:HDC, rect:RECT
	push hwnd
	call GetDC
	mov dc, eax

	cmp ActivePiece, 0
	jne TickPiece
; generate a new piece
	call GetRand
	mov ActivePiece, eax

TickPiece:
	;erase the piece at its old position
	mov eax, PiecePositionY
	mov rect.top, eax
	add eax, 10
	mov rect.bottom, eax
	mov eax, PiecePositionX
	mov rect.left, eax
	add eax, 10
	mov rect.right, eax
	
	push 00h
	call CreateSolidBrush
	push eax
	lea eax, rect
	push eax
	push dc
	call FillRect
	
	;move the piece (both down and left/right - answer input) & do collision detection
	inc PiecePositionY
	
	;redraw at new position
	mov eax, PiecePositionY
	mov rect.top, eax
	add eax, 10
	mov rect.bottom, eax
	mov eax, PiecePositionX
	mov rect.left, eax
	add eax, 10
	mov rect.right, eax
	
	push 0FF00h
	call CreateSolidBrush
	push eax
	lea eax, rect
	push eax
	push dc
	call FillRect
		
	push dc
	push hwnd
	call ReleaseDC
		
	ret
TickGame endp

END WillEntry