

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


mov dword [snake_length], 3  ; Start with 3 segments
mov dword [snake_head], 2
mov dword [snake_tail], 0

; Initial snake position (middle of screen)
mov word [snake_x], 30
mov word [snake_y], 10
mov word [snake_x+2], 29
mov word [snake_y+2], 10
mov word [snake_x+4], 28
mov word [snake_y+4], 10

mov byte [dir], 'R'  ; Start moving right





  play:


;DRAW THE SNAKE

        ;mov rcx, [consoleOutHdl]
        ;mov ebx, [snake_head]
  ; Current head X
        ;mov dx, [snake_y + ebx*2]  ; Current head Y
        ;shl rdx, 16                                        ;move cursor to snake head
        ;mov dx, [snake_x + ebx*2]
        ;call [SetConsoleCursorPosition]
        ;mov rdx, '$'
        ;call write_char

mov ecx, [snake_length]  ; Load segment count
mov esi, [snake_tail]    ; Start from tail
.render_snake_loop:
      ; Get position
    movzx eax, word [snake_x + esi*2]
    movzx ebx, word [snake_y + esi*2]
    
    ; Set cursor position (COORD: x=low word, y=high word)
    mov edx, ebx
    shl edx, 16
    or edx, eax
    
    ; Draw segment
    push rcx
    push rsi
    mov rcx, [consoleOutHdl]
    call [SetConsoleCursorPosition]
    mov dl, byte [snakeChar]
    call write_char
    pop rsi
    pop rcx
    
    ; Move to next segment
    inc esi
    cmp esi, MAX_SNAKE_LENGTH
    jb .no_wrap
    xor esi, esi
.no_wrap:
    dec ecx
    jnz .render_snake_loop










        invoke Sleep, 200                                   ;give cpu some rest to let the jiqì breath
;START SCREEN CLEAR

        ;clear map
clear_map:
        xor rbx, rbx          ; Use rbx as line counter
        
clear_line:
        ; Set cursor position to (0, line number)
        mov rcx, [consoleOutHdl]
        mov rdx, rbx          ; Y coordinate
        shl rdx, 16           ; Shift to high word
        mov dx, 0             ; X coordinate = 0
        call [SetConsoleCursorPosition]
        
        ; Write WIDTH characters
        mov cx, [WIDTH]
        
loop_width:
        push rcx
        invoke WriteConsoleA, [consoleOutHdl], ' ', 1, 0, 0   ;just learned invoke can overwrite registers...
        pop  rcx
        dec cx
        jnz loop_width        ; Continue until cx = 0
        
        ; Move to next line
        inc rbx
        cmp bx, [HEIGHT]
        jl clear_line         ; Continue until all lines are processed



;END SCREEN CLEAR

;CHECKING USER INPUT

        invoke GetAsyncKeyState, VK_LEFT
        cmp eax, 0
        jne DirLeft

        invoke GetAsyncKeyState, VK_RIGHT
        test eax, eax
        jnz DirRight

        invoke GetAsyncKeyState, VK_UP
        test eax, eax
        jnz DirUp

        invoke GetAsyncKeyState, VK_DOWN
        test eax, eax
        jnz DirDown

        jmp update_snake

;END CHECKING USER INPUT


;UPDATED SNAKE DIR BASED ON INPUT
        DirRight:

              ;inc [headX]
              mov [dir], 'R'
              ;call write_char



              jmp   update_snake
        DirLeft:
               ; dec [headX]

                  mov [dir], 'L'
               ; call write_char
                  jmp   update_snake
        DirUp:

                 mov [dir], 'U'
                ;call write_char
        jmp   update_snake
        DirDown:
               mov [dir], 'D'

;END UPDATED SNAKE DIR BASED ON INPUT
                jmp   update_snake



update_snake:

; 1. Remove tail (move tail pointer forward)
mov eax, [snake_tail]
inc eax
cmp eax, MAX_SNAKE_LENGTH
jb .no_wrap_tail
xor eax, eax  ; Wrap around
.no_wrap_tail:
mov [snake_tail], eax


mov ebx, [snake_head]
mov cx, [snake_x + ebx*2]  ; Current head X
mov dx, [snake_y + ebx*2]  ; Current head Y


        cmp [dir], 'R'
        jne mvLeft
        inc cx
        jmp end_update_snake
mvLeft:
        cmp [dir], 'L'
        jne mvDown
        dec cx
        jmp end_update_snake
mvDown:
        cmp [dir], 'D'
        jne mvUp
        inc dx
        jmp end_update_snake
mvUp:
        dec dx
        jmp end_update_snake

end_update_snake:

; 3. Store new head position
inc ebx
cmp ebx, MAX_SNAKE_LENGTH
jb .no_wrap_head
xor ebx, eax  ; Wrap around
.no_wrap_head:
mov [snake_head], ebx
mov [snake_x + ebx*2], cx
mov [snake_y + ebx*2], dx



onEat:
inc ebx
cmp ebx, MAX_SNAKE_LENGTH
jb .no_wrap_head
xor ebx, eax  ; Wrap around
.no_wrap_head:
mov [snake_head], ebx
mov [snake_x + ebx*2], cx
mov [snake_y + ebx*2], dx








        invoke GetAsyncKeyState, [escKeyCode]   ;Exit if presse ESC
        cmp rax, 0
        jz play
        jmp Exit

write_char:  ;put the char in rdx
    mov [charRoom], dl
    invoke WriteConsoleA,    [consoleOutHdl],  charRoom   ,1, 0, 0
    ret


Exit:
        invoke        ExitProcess, 0


section '.const' data readable
        WIDTH    dw 60
        HEIGHT   dw 20


section '.data' data readable writeable
       cursorPos db 10    ; X = 10 (16-bit)
                 db 5     ; Y = 5  (16-bit)



  snakeChar db 'X',0


  consoleTitle db "OOOOA",0

  cTLen = $-consoleTitle

  consoleOutHdl dq 0
  consoleInHdl dq 0


        escKeyCode dd 0x1B

        ;snake direction, 'R' 'L' 'U' 'D'
        dir db 'R'


  MAX_SNAKE_LENGTH = 100
    snake_x: times MAX_SNAKE_LENGTH dw 0  ; X coordinates
    snake_y: times MAX_SNAKE_LENGTH dw 0  ; Y coordinates
    snake_head dd 0  ; Index of head (0-99)
    snake_tail dd 0  ; Index of tail (0-99)
    snake_length dd 1

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

