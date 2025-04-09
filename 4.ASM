
; Example of making 32-bit PE program as raw code and data

format PE64 Console 5.0
entry start

include 'win64a.inc'


section '.text' code readable executable

  start:

        invoke       SetConsoleTitleA,       consoleTitle
        test eax, eax ;compare eax with 0 exit if eax == 0
        jz Exit


        invoke  GetStdHandle,       [STD_OUTP_HNDL]
        mov [consoleOutHdl], eax

        invoke GetStdHandle, [STD_INP_HNDL] ; similiar
        mov [consoleInHdl], eax


        invoke WriteConsoleA,    [consoleOutHdl],    message   ,messageLen, 0, 0



        invoke ReadConsoleA, [consoleInHdl], readBuf, 1, 0, 0



Exit:
        invoke        ExitProcess, 0










        ;push    0
        ;push    _caption
        ;push    _message
        ;push    0
        ;call    [MessageBoxA]



        ;push STD_OUTPUT_HANDLE
      ;  call [GetStdHandle]




       ; push      0
       ; push 0
       ; push 12
       ; push _message
       ; push eax
       ; call [WriteConsoleA]

      ;  call [AllocConsole]



       ; mov eax, -1
       ; push eax
       ; call [Sleep]         ; infinit sleep






section '.data' data readable writeable

  _caption db 'Win32 assembly program',0
  message db 'Hello World!',0
  messageLen =$-message
  consoleTitle db "OOOOA",0

  cTLen = $-consoleTitle

  consoleOutHdl dd 0
  consoleInHdl dd 0



  STD_OUTP_HNDL  dd -11
  STD_INP_HNDL dd -10

section '.bss' readable writeable ; statically-allocated variables that are not explicitly initialized to any value
 
  readBuf  db ?


section '.idata' import data readable
 
  library msvcrt,'MSVCRT.DLL',\
          kernel,'KERNEL32.DLL'
 
  import kernel,\
    SetConsoleTitleA, 'SetConsoleTitleA',\
    GetStdHandle, 'GetStdHandle',\
    WriteConsoleA, 'WriteConsoleA',\
    ReadConsoleA, 'ReadConsoleA',\
    ExitProcess, 'ExitProcess'

    import msvcrt,\
    puts,'puts',\
    scanf,'scanf',\
    printf,'printf',\
    exit,'exit'

