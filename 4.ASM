

format PE64 Console 5.0
entry start

include 'win64a.inc'


section '.text' code readable executable

  start:

        invoke       SetConsoleTitleA,       consoleTitle
        test eax, eax ;compare eax with 0 exit if eax == 0
        jz Exit

        mov ecx, [STD_OUTP_HNDL]
        call [GetStdHandle]
        mov [consoleOutHdl], rax                      ; getting console handles
        invoke GetStdHandle, [STD_INP_HNDL]
        mov [consoleInHdl], rax


  play:

        mov rcx, [consoleOutHdl]
        mov dx, [headY]
        shl rdx, 16                                        ;move cursor to snake head
        mov dx, [headX]
        call [SetConsoleCursorPosition]


        invoke Sleep, 20                                   ;give cpu some rest to let the Jiqì breath



;START SCREEN CLEAR

        ;clear map
        xor rdx, rdx
        xor rcx, rcx

        mov rcx, [consoleOutHdl]   ; Handle                                             ;using call instead of invoke just because I wanted to
        mov dx, [HEIGHT]
        shl rdx, 16                ; RDX = 0x0000000000050000
        call [SetConsoleCursorPosition]      ;set cursor to (0, HEIGHT)



        clearing_screen:
        mov bx, [WIDTH]
            loop_width:

                invoke WriteConsoleA, [consoleOutHdl], '#a', 2,0,0
                dec bx
                cmp bx,0
                je loop_width

        dec dx
        call [SetConsoleCursorPosition]
        cmp edx,0
        jne clearing_screen

;END SCREEN CLEAR

;CHECKING USER INPUT

        invoke GetAsyncKeyState, VK_LEFT
        cmp eax, 0
        jne MoveLeft

        invoke GetAsyncKeyState, VK_RIGHT
        test eax, eax
        jnz MoveRight

        invoke GetAsyncKeyState, VK_UP
        test eax, eax
        jnz MoveUp

        invoke GetAsyncKeyState, VK_DOWN
        test eax, eax
        jnz MoveDown

        jmp play

;END CHECKING USER INPUT


;UPDATED SNAKE DIR BASED ON INPUT
        MoveRight:
              mov dl, 'R'
              inc [headX]
              mov [dir], 'R'
                call write_char
              jmp   play
        MoveLeft:
                dec [headX]
                  mov dl, 'L'
                  mov [dir], 'L'
                call write_char
                  jmp   play
        MoveUp:
                dec [headY]
                 mov dl, 'U'
                 mov [dir], 'U'
                call write_char
        jmp   play
        MoveDown:
                inc [headY]
               mov dl, 'D'
               mov [dir], 'D'
                call write_char
;END UPDATED SNAKE DIR BASED ON INPUT
                jmp   play




        invoke GetAsyncKeyState, [escKeyCode]   ;Exit if presse ESC
        cmp rax, 0
        jz play
        jmp Exit

write_char:  ;put the char in rdx
    ; Save character to stack
    mov [charRoom], dl

    invoke WriteConsoleA,    [consoleOutHdl],  charRoom   ,1, 0, 0

    ret


Exit:
        invoke        ExitProcess, 0


section '.const' data readable
        WIDTH    dw 20
        HEIGHT   dw 20


section '.data' data readable writeable
       cursorPos db 10    ; X = 10 (16-bit)
                 db 5     ; Y = 5  (16-bit)

        headX dw 3
        headY dw 7



  _caption db 'Win32 assembly program',0
  snakeChar db '@',0

  message db 'Hello World!',0
  messageLen =$-message

  clear_screen_sequence db '\x1b[2J',0
  clear_screen_sequence_len = $-clear_screen_sequence
  consoleTitle db "OOOOA",0

  cTLen = $-consoleTitle

  consoleOutHdl dq 0
  consoleInHdl dq 0



        escKeyCode dd 0x1B

        ;snake direction, 'R' 'L' 'U' 'D'
        dir db 'R'



  STD_OUTP_HNDL  dd -11
  STD_INP_HNDL dd -10

section '.bss' readable writeable ; statically-allocated variables that are not explicitly initialized to any value
 
  readBuf  db ?
  charRoom db ?


section '.idata' import data readable
 
  library msvcrt,'MSVCRT.DLL',\
          kernel,'KERNEL32.DLL',\
          user, 'User32.DLL'
  import user,\
    GetAsyncKeyState, 'GetAsyncKeyState'
 
  import kernel,\
    SetConsoleTitleA, 'SetConsoleTitleA',\
    GetStdHandle, 'GetStdHandle',\
    WriteConsoleA, 'WriteConsoleA',\
    ReadConsoleA, 'ReadConsoleA',\
    SetConsoleCursorPosition, 'SetConsoleCursorPosition',\
    Sleep, 'Sleep',\
    FillConsoleOutputCharacterA, 'FillConsoleOutputCharacterA',\
    ExitProcess, 'ExitProcess'

    import msvcrt,\
    puts,'puts',\
    scanf,'scanf',\
    printf,'printf',\
    exit,'exit'

