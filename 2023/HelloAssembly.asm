; This code is taken from https://youtu.be/b0zxIfJJLAY?list=TLPQMDYwNzIwMjNIKfNwGat_dQ
;  and is not my own. It is for learning only

;----------------------------------------------------------------------------------------------------------------------
; Hello, Windows! in x86 ASM - (c) Dave's Garage - Use at your own risk, no warrenty!
;----------------------------------------------------------------------------------------------------------------------

; Compiler directive and includes

.386                                    ; Full 80386 instruction set and mode
.model flat, stdcall                    ; All 32-bit and later apps are flat. Used to include "tiny, ect"
option casemap:none                     ; Preserve the case of system identifiers but not our own, more or less

; Include files - headers and libs that we need for calling the system dlls like user32, gdi32, kernel32, ect

include \masm32\include\windows.inc     ; Main windows header file (akin to Windows.h in C)
include \masm32\include\user32.inc      ; Windows, controls, ect
include \masm32\include\kernel32.inc    ; Handles, modules, paths, ect       
include \masm32\include\gdi32.inc       ; Drawing into a device context (ie: painting)

; Libs -information needed to link our binary to the system DLL calls

includelib \masm32\lib\user32.inc      ; User32.dll
includelib \masm32\lib\kernel32.inc    ; Kernel32.dll   
includelib \masm32\lib\gdi32.inc       ; GDI32.dll

; Forward declarations - Our main entry point will call forward to WinMain, so we need to define it here, ect

; This sets up command line call with 4 arguments
WinMain proto :DWORD, :DWORD, :DWORD, :DWORD    ; Forward decl for MainEntry

; Constants and Data

; equ is a constant
WindowWidth     equ 640                ; How big we'd like our main window
WindowHeight    equ 480

.DATA

; db or BYTE: size 1
; dd or DWORD double: size 4
; df or FWORD: size 6
; DQ or QWORD: 8
; DT or TBYTE: 10
; DW or WORD: 16

; below he is creating string constants, a series of bytes that end in 0
ClassName       db "MyWinClass", 0      ; The name of our Windows class
AppName         db "Dave's Tiny App", 0 ; The name of our main window

.DATA?                                  ; Uninitialized data - Basically just reserved address space

hInstance       HINSTANCE ?             ; Instance handle (like the process id) of our application
CommandLine     LPSTR     ?             ; Pointer to the command line text we were launched with

;----------------------------------------------------------------------------------------------------------------------
.CODE                                   ; Here is where the program lives
;----------------------------------------------------------------------------------------------------------------------

MainEntry:

        push    NULL                    ; Get the instance handle of our app (NULL means ourselves)
        call    GetModuleHandle         ; GetModuleHandle will return instance handle in EAX
        mov     hInstance, eax          ; Cache it in our global varible

        call    GetCommandLine          ; Get the command line text ptr in EAX to pass on to main
        mov     CommandLine, eax

        ; Call our WinMain and then exit the process with whatever comes back

        push    SW_SHOWDEFAULT
        lea     eax, CommandLine
        push    eax
        push    NULL
        push    hInstance
        call    WinMain

        push    eax
        call    ExitProcess

;
; WinMain - The traditional signature for the main entry point of a Windows program
;

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    
        LOCAL   wc:WNDCLASSEX         ; Create these vars on the stack, hence LOCAL
        LOCAL   msg:MSG
        LOCAL   hwnd:HWND    

        mov     wc.cbSize, SIZEOF WNDCLASSEX            ; Fill in the values in the members of our windowclass
        mov     wc.styles, CS_HRDRAW or CS_VREDRAW      ; Redraw if resized in either dimension
        mov     wc.lpfnWndProc, OFFSET WndProc          ; Our callback function to handle window messages
        mov     wc.cbClsExtra, 0                        ; No extra class data
        mov     wc.cbWndExtra, 0                        ; No extra window data
        mov     eax, hInstance
        mov     wc.hInstance, eac                       ; Our instance handle
        mov     wc.hbrBackground, COLOR_3DSHADOW+1      ; Default brush colors are color plus 1
        mov     wc.lpszMenuName, NULL                   ; No app menu
        mov     wc.lpszClassName, OFFSET ClassName      ; The window's class name

        push    IDI_APPLICATION                         ; Use the default application icon
        push    NULL
        call    LoadIcon
        mov     wc.hIcon, eax
        mov     wc.hIconSm, eax

        push    IDC_ARROW
        push    NULL
        call    LocaCursor
        mov     wc.hCursor, eax

        lea     eax, wc
        push    eax
        call    RegisterClassEx

        push    NULL
        push    hInstance
        push    NULL
        push    NULL
        push    WindowHeight
        push    WindowWidth
        push    CW_USEDEFAULT
        push    CW_USEDEFAULT
        push    WS_OVERLAPPEDWINDOW + WS_VISIBLE
        push    OFFSET AppName
        push    OFFSET ClassName
        push    0
        call    CreateWindowExA                     ;12 parameters?!? YIKES
        cmp     eax, NULL

        je      WinMainRet                          ; Fail and bail
        mov     hwnd, eax

