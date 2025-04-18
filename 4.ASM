

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

        call generate_fruit


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
    mov rax ,MAX_SNAKE_LENGTH
    cmp esi, eax
    jb .no_wrap
    xor esi, esi

.no_wrap:
    dec ecx
    jnz .render_snake_loop


;draw fruit
    cmp byte [fruit_active], 1
    jne .no_fruit
    
    movzx eax, word [fruit_x]
    movzx ebx, word [fruit_y]
    mov edx, ebx
    shl edx, 16
    or edx, eax
    mov rcx, [consoleOutHdl]
    call [SetConsoleCursorPosition]
    
    mov dl, byte [fruit_char]
    call write_char
    
.no_fruit:


        invoke Sleep, 24                                   ;give cpu some rest to let the jiqì breath
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
              mov [dir], 'R'
              jmp   update_snake
        DirLeft:
              mov [dir], 'L'
              jmp   update_snake
        DirUp:
              mov [dir], 'U'
              jmp   update_snake
        DirDown:
              mov [dir], 'D'
;END UPDATED SNAKE DIR BASED ON INPUT
              jmp   update_snake



update_snake:

; 1. Remove tail (move tail pointer forward)
    mov eax, [snake_tail]
    inc eax

    mov rbx, MAX_SNAKE_LENGTH
    cmp rax, rbx
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
    mov rax,  MAX_SNAKE_LENGTH
    cmp rbx, rax
    jb .no_wrap_head
    xor ebx, ebx  ; Wrap around
.no_wrap_head:
    mov [snake_head], ebx
    mov [snake_x + ebx*2], cx
    mov [snake_y + ebx*2], dx


   ; inc ebx
    ;
    ;mov rax,  MAX_SNAKE_LENGTH
    ;cmp rbx, rax
    ;jb .no_wrap_headd
    ;xor ebx, ebx  ; Wrap around
;.no_wrap_headd:
   ; mov [snake_head], ebx
    ;mov [snake_x + ebx*2], cx
    ;mov [snake_y + ebx*2], dx
    ;mov eax, [snake_length]
    ;inc eax
    ;mov [snake_length], eax




        invoke GetAsyncKeyState, [escKeyCode]   ;Exit if presse ESC
        cmp rax, 0
        jz play
        jmp Exit

write_char:  ;put the char in rdx
    mov [charRoom], dl
    invoke WriteConsoleA,    [consoleOutHdl],  charRoom   ,1, 0, 0
    ret

generate_fruit:
    cmp byte [fruit_active], 1
    je .done
    
    ; Get random X position
    invoke GetTickCount
    xor edx, edx
    movzx ecx, word [WIDTH]  ; Use movzx to zero-extend to ecx
    dec ecx                  ; Don't place on right border
    div ecx
    inc edx                  ; Avoid 0 position
    mov [fruit_x], dx
    
    ; Get random Y position
    invoke GetTickCount
    xor edx, edx
    movzx ecx, word [HEIGHT] ; Use movzx to zero-extend to ecx
    dec ecx                  ; Don't place on bottom border
    div ecx
    inc edx                  ; Avoid 0 position
    mov [fruit_y], dx

    ; Check if position is on snake
    mov ecx, [snake_length]
    mov esi, [snake_tail]
    
.check_collision_loop:
    movzx eax, word [snake_x + esi*2]
    movzx ebx, word [snake_y + esi*2]
    cmp ax, [fruit_x]
    jne .next_segment
    cmp bx, [fruit_y]
    je generate_fruit  ; Try again if on snake
    
.next_segment:
    inc esi
    cmp esi, MAX_SNAKE_LENGTH
    jb .no_wrap_check
    xor esi, esi
    
.no_wrap_check:
    dec ecx
    jnz .check_collision_loop

    mov byte [fruit_active], 1
    
.done:
    ret

Exit:
        invoke        ExitProcess, 0



       ; WIDTH    equ 60    ; Use equ instead of dw
       ; HEIGHT   equ 20    ; Use equ instead of dw

section '.data' data readable writeable
       cursorPos db 10    ; X = 10 (16-bit)
                 db 5     ; Y = 5  (16-bit)

  WIDTH           dw 60
HEIGHT          dw 20
MAX_SNAKE_LENGTH dw 1200


  snakeChar db 'X',0


  consoleTitle db "OOOOA",0

  cTLen = $-consoleTitle

  consoleOutHdl dq 0
  consoleInHdl dq 0


        escKeyCode dd 0x1B

        ;snake direction, 'R' 'L' 'U' 'D'
        dir db 'R'



    snake_x: times MAX_SNAKE_LENGTH dw 0  ; X coordinates
    snake_y: times MAX_SNAKE_LENGTH dw 0  ; Y coordinates
    snake_head dd 0  ; Index of head (0-99)
    snake_tail dd 0  ; Index of tail (0-99)
    snake_length dd 1

        fruit_x dw 0
fruit_y dw 0
fruit_char db 'O',0
fruit_active db 0
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
    GetTickCount, 'GetTickCount',\
    ExitProcess, 'ExitProcess'

    import msvcrt,\
    puts,'puts',\
    scanf,'scanf',\
    printf,'printf',\
    exit,'exit'

