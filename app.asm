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
Score dd 0

ClientSizeX dd 100
ClientSizeY dd 200

; Controls
Rotating dd 0
PressingLeft dd 0
PressingRight dd 0

; Line piece type 1
PieceTable db 000h, 000h, 000h, 000h
db 0FFh, 0FFh, 0FFh, 0FFh
db 000h, 000h, 000h, 000h
db 000h, 000h, 000h, 000h
; Line piece type 2
db 000h, 000h, 0FFh, 000h
db 000h, 000h, 0FFh, 000h
db 000h, 000h, 0FFh, 000h
db 000h, 000h, 0FFh, 000h
; Line piece type 3
db 000h, 000h, 000h, 000h
db 000h, 000h, 000h, 000h
db 0FFh, 0FFh, 0FFh, 0FFh
db 000h, 000h, 000h, 000h
; Line piece type 4
db 000h, 0FFh, 000h, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 0FFh, 000h, 000h

; L piece 1 type 1
db 0FFh, 000h, 000h, 000h
db 0FFh, 0FFh, 0FFh, 000h
db 000h, 000h, 000h, 000h
db 000h, 000h, 000h, 000h
; L piece 1 type 2
db 000h, 0FFh, 0FFh, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h
; L piece 1 type 3
db 000h, 000h, 000h, 000h
db 0FFh, 0FFh, 0FFh, 000h
db 000h, 000h, 0FFh, 000h
db 000h, 000h, 000h, 000h
; L piece 1 type 4
db 000h, 0FFh, 000h, 000h
db 000h, 0FFh, 000h, 000h
db 0FFh, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h

; L piece 2 type 1
db 000h, 000h, 0FFh, 000h
db 0FFh, 0FFh, 0FFh, 000h
db 000h, 000h, 000h, 000h
db 000h, 000h, 000h, 000h
; L piece 2 type 2
db 000h, 0FFh, 000h, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 0FFh, 0FFh, 000h
db 000h, 000h, 000h, 000h
; L piece 2 type 3
db 000h, 000h, 000h, 000h
db 0FFh, 0FFh, 0FFh, 000h
db 0FFh, 000h, 000h, 000h
db 000h, 000h, 000h, 000h
; L piece 2 type 4
db 0FFh, 0FFh, 000h, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h

; Block piece type 1
db 0FFh, 0FFh, 000h, 000h
db 0FFh, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h
db 000h, 000h, 000h, 000h
; Block piece type 2
db 0FFh, 0FFh, 000h, 000h
db 0FFh, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h
db 000h, 000h, 000h, 000h
; Block piece type 3
db 0FFh, 0FFh, 000h, 000h
db 0FFh, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h
db 000h, 000h, 000h, 000h
; Block piece type 4
db 0FFh, 0FFh, 000h, 000h
db 0FFh, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h
db 000h, 000h, 000h, 000h

; Z piece 1 type 1
db 000h, 0FFh, 0FFh, 000h
db 0FFh, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h
db 000h, 000h, 000h, 000h
; Z piece 1 type 2
db 000h, 0FFh, 000h, 000h
db 000h, 0FFh, 0FFh, 000h
db 000h, 000h, 0FFh, 000h
db 000h, 000h, 000h, 000h
; Z piece 1 type 3
db 000h, 000h, 000h, 000h
db 000h, 0FFh, 0FFh, 000h
db 0FFh, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h
; Z piece 1 type 4
db 0FFh, 000h, 000h, 000h
db 0FFh, 0FFh, 000h, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h

; T piece type 1
db 000h, 0FFh, 000h, 000h
db 0FFh, 0FFh, 0FFh, 000h
db 000h, 000h, 000h, 000h
db 000h, 000h, 000h, 000h
; T piece type 2
db 000h, 0FFh, 000h, 000h
db 000h, 0FFh, 0FFh, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h
; T piece type 3
db 000h, 000h, 000h, 000h
db 0FFh, 0FFh, 0FFh, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h
; T piece type 4
db 000h, 0FFh, 000h, 000h
db 0FFh, 0FFh, 000h, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h

; Z piece 2 type 1
db 0FFh, 0FFh, 000h, 000h
db 000h, 0FFh, 0FFh, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h
; Z piece 2 type 2
db 000h, 000h, 0FFh, 000h
db 000h, 0FFh, 0FFh, 000h
db 000h, 0FFh, 000h, 000h
db 000h, 000h, 000h, 000h
; Z piece 2 type 3
db 000h, 000h, 000h, 000h
db 0FFh, 0FFh, 000h, 000h
db 000h, 0FFh, 0FFh, 000h
db 000h, 000h, 000h, 000h
; Z piece 2 type 4
db 000h, 0FFh, 000h, 000h
db 0FFh, 0FFh, 000h, 000h
db 0FFh, 000h, 000h, 000h
db 000h, 000h, 000h, 000h

hInstance HINSTANCE ?
CommandLine LPSTR ?
hDC HDC ?

BrushTable HBRUSH 8 dup(0)
array byte 240 dup(0)

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
; InitBrushList
; 

InitBrushList proc
	mov ebx, OFFSET BrushTable
	push 000000000h
	call CreateSolidBrush
	mov [ebx], eax
	
	add ebx, 4
	push 0000000FFh
	call CreateSolidBrush
	mov [ebx], eax
	
	add ebx, 4
	push 00000FF00h
	call CreateSolidBrush
	mov [ebx], eax
	
	add ebx, 4
	push 00000FFFFh
	call CreateSolidBrush
	mov [ebx], eax
	
	add ebx, 4
	push 000FF0000h
	call CreateSolidBrush
	mov [ebx], eax
	
	add ebx, 4
	push 000FF00FFh
	call CreateSolidBrush
	mov [ebx], eax
	
	add ebx, 4
	push 000FFFF00h
	call CreateSolidBrush
	mov [ebx], eax
	
	add ebx, 4
	push 000FFFFFFh
	call CreateSolidBrush
	mov [ebx], eax
	
	ret
	
InitBrushList endp

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
	push 080h
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
	
	call InitBrushList

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
	LOCAL rect:RECT
	
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
	
	mov rect.left, 0
	mov rect.top, 0
	mov eax, ClientSizeX
	mov rect.right, eax
	mov eax, ClientSizeY
	mov rect.bottom, eax
	push 0
	push WS_OVERLAPPEDWINDOW + WS_VISIBLE
	lea eax, rect
	push eax
	call AdjustWindowRect
	
; create the wndow
	push NULL ;no extra data
	push hInst
	push NULL ;use default menu handle
	push NULL ;no parent window
	mov eax, rect.bottom
	sub eax, rect.top
	push eax ;requested height
	mov eax, rect.right
	sub eax, rect.left
	push eax ;requested width
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
	cmp uMsg, WM_KEYUP
	je WmKeyup
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
	cmp wParam, 041h ;a key, move left
	je move_left
	cmp wParam, 053h ;s key, rotate
	je rotate
	cmp wParam, 044h ;d key, move right
	je move_right
	
move_right:
	mov PressingRight, 1
	jmp done

rotate:
	mov Rotating, 1
	jmp done
	
move_left:
	mov PressingLeft, 1
	jmp done

	jmp done

WmKeyup:
	cmp wParam, 041h ;a key, move left
	je stop_move_left
	cmp wParam, 053h ;s key, rotate
	je stop_rotate
	cmp wParam, 044h ;d key, move right
	je stop_move_right
	
stop_move_right:
	mov PressingRight, 0
	jmp done

stop_rotate:
	mov Rotating, 0
	jmp done
	
stop_move_left:
	mov PressingLeft, 0
	jmp done

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
	
	;draw current block
	cmp ActivePiece, 0
	je next
	mov eax, PieceColor
	push [BrushTable+eax*4]
	call DrawShape

next:
	push SRCCOPY
	push 200
	push 100
	push 0
	push 0
	push hDC
	push ClientSizeY
	push ClientSizeX
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

newgame: ;reset everything
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
	xor eax, eax
	mov al, [array+ebx]
	push [BrushTable+eax*4]
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
	mov [ebx], al
	inc ebx
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
; ShapePtr
; returns a pointer to the data for the current shape in EAX
; 

ShapePtr proc
	lea ebx, PieceTable
	mov eax, ActivePiece
	dec eax
	shl eax, 6
	mov ecx, PieceOrientation
	shl ecx, 4
	add eax, ebx
	add eax, ecx
	ret
ShapePtr endp

; 
; DrawShape
; Draws the current shape at its current position/orientation using the desired brush into the compatible DC
; 

DrawShape proc brush:HBRUSH
	local rect:RECT	
	local left:DWORD
	
; EAX holds the pointer to the current block
; ECX holds the current row counter
; EDX holds the current column counter
	
	mov ebx, 10
	mov eax, PiecePositionX
	mul ebx
	mov left, eax
	mov rect.left, eax
	add eax, 10
	mov rect.right, eax
	
	mov eax, PiecePositionY
	mul ebx
	mov rect.top, eax
	add eax, 10
	mov rect.bottom, eax
	
	call ShapePtr
	
	xor ecx, ecx
	xor edx, edx

drawloop:
	mov bl, [eax]
	cmp bl, 000h
	je next
	push eax
	push ecx
	push edx
	push brush
	lea ebx, rect
	push ebx
	push hDC
	call FillRect
	pop edx
	pop ecx
	pop eax
next:
	inc eax
	inc edx
	add rect.left, 10
	add rect.right, 10
	cmp edx, 4
	jne drawloop
	mov ebx, left
	mov rect.left, ebx
	add ebx, 10
	mov rect.right, ebx
	add rect.bottom, 10
	add rect.top, 10
	xor edx, edx
	inc ecx
	cmp ecx, 4
	jne drawloop

	ret
DrawShape endp


; 
; HittingFloor
; Returns in ZF whether the current piece is hitting the floor or not
;

HittingFloor proc
	call ShapePtr
	
	cmp PiecePositionY, 19
	je Check19
	cmp PiecePositionY, 18
	je Check18
	cmp PiecePositionY, 17
	je Check17
	cmp PiecePositionY, 16
	je Check16
	cmp eax, eax
	ret
	
Check16:
	mov eax, [eax]
	cmp eax, 0
	ret

Check17:
	mov eax, [eax+4]
	cmp eax, 0
	ret

Check18:
	mov eax, [eax+8]
	cmp eax, 0
	ret

Check19:
	mov eax, [eax+12]
	cmp eax, 0
	ret
	
HittingFloor endp

; 
; MergePiece
; Takes the current piece and merges it into the playfield with its current position and color
; Resets ActivePiece to 0
; ESI holds the pointer to the current shape element while EBX holds the pointer to the playfield
; ECX holds a copy that's used every time we go to a new line
; EDX holds a counter (on every multiple of four, we roll over, on the sixteenth, we're done)
; EAX holds temp values (the color is ANDed with the current shape value)

MergePiece proc
	mov ActivePiece, 0
	ret
MergePiece endp


; 
; Draw into the compatible DC but then use some clipping magic to only update the important bits in the real HDC
; The WndProc handles the actual input translation and sets appropriate state variables
; Actually USING the input to control the game is inside of TickGame
; 

TickGame proc hwnd:HWND
	local dc:HDC, rect:RECT
	
	push hwnd
	call GetDC
	mov dc, eax
	
	; check for any row clears

	cmp ActivePiece, 0
	jne TickPiece
; generate a new piece
	call GetRand
	mov ActivePiece, eax
	call GetRand
	mov PieceColor, eax
	mov PiecePositionY, -2
	mov PiecePositionX, 0 ;this should be random

TickPiece:
	; erase the piece at its old position
	push [BrushTable+0]
	call DrawShape
	
	; move it, collision detection, input, the works
	inc PiecePositionY
	
	;first, check if the piece has hit the floor
	call HittingFloor
	jne HitFloor
	
	;or if it's hit another piece (if it's also on the top, then GAME OVER!!!)
	
	cmp Rotating, 1
	je rotate_piece
	cmp PressingLeft, 1
	je move_left
	cmp PressingRight, 1
	je move_right

	jmp redraw

move_right: ;prevent it from going offscreen
	inc PiecePositionX
	jmp redraw

move_left: ;prevent it from going offscreen
	dec PiecePositionX
	jmp redraw

rotate_piece:
	inc PieceOrientation
	and PieceOrientation, 3
	jmp redraw
	
HitFloor: ;make it part of the playfield & set ActivePiece to 0
	push 0
	push OFFSET AppName
	push OFFSET ClassName
	push 0
	call MessageBoxA
	call MergePiece
	ret
	
redraw:
	; redraw it
	mov eax, PieceColor
	push [BrushTable+eax*4]
	call DrawShape
	
	; update the new region
	push 0
	push 0
	push hwnd
	call InvalidateRect
			
	push dc
	push hwnd
	call ReleaseDC
		
	ret
TickGame endp

END WillEntry