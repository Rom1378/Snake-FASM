

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
       ; invoke  GetStdHandle,       [STD_OUTP_HNDL]

        mov [consoleOutHdl], rax

        invoke GetStdHandle, [STD_INP_HNDL] ; similiar
        mov [consoleInHdl], rax




  play:

        mov rcx, [consoleOutHdl]   ; Handle
        mov dx, 5                  ; Y = 5
        shl rdx, 16                ; RDX = 0x0000000000050000
        mov dx, 10                 ; X = 10 (RDX = 0x00000000 0005000A)
        call [SetConsoleCursorPosition]

        ;invoke WriteConsoleA,    [consoleOutHdl],    message   ,messageLen, 0, 0


        ;invoke WriteConsoleA,    [consoleOutHdl],    _caption   ,messageLen, 0, 0

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


        MoveRight:
              mov dl, 'R'

              mov [dir], 'R'
                call write_char
              jmp   play
        MoveLeft:
                  mov dl, 'L'
                  mov [dir], 'L'
                call write_char
                  jmp   play
        MoveUp:
                 mov dl, 'U'
                 mov [dir], 'U'
                call write_char
        jmp   play
        MoveDown:
               mov dl, 'D'
               mov [dir], 'D'
                call write_char
                  ;invoke WriteConsoleA,    [consoleOutHdl],    'D'   ,1, 0, 0
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




section '.data' data readable writeable
       cursorPos dw 10    ; X = 10 (16-bit)
                 dw 5     ; Y = 5  (16-bit)


  _caption db 'Win32 assembly program',0
  snakeChar db '@',0

  message db 'Hello World!',0
  messageLen =$-message
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
    ExitProcess, 'ExitProcess'

    import msvcrt,\
    puts,'puts',\
    scanf,'scanf',\
    printf,'printf',\
    exit,'exit'

