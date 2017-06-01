; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

    ; __UNICODE__ equ 1           ; uncomment to enable UNICODE build

    ; UNICODE_EDIT equ 1          ; uncomment for UNICODE edit control

    .686p                       ; create 32 bit code
    .mmx                        ; enable MMX instructions
    .xmm                        ; enable SSE instructions
    .model flat, stdcall        ; 32 bit memory model
    option casemap :none        ; case sensitive

  ; -------------------------------------------------------------
  ; equates for controlling the toolbar button size and placement
  ; -------------------------------------------------------------
    rbht     equ <36>           ; rebar height in pixels
    tbbW     equ <24>           ; toolbar button width in pixels
    tbbH     equ <24>           ; toolbar button height in pixels
    vpad     equ <12>           ; vertical button padding in pixels
    hpad     equ <12>           ; horizontal button padding in pixels
    lind     equ  <5>           ; left side initial indent in pixels

    bColor   equ  <00999999h>   ; client area brush colour

    include project.inc         ; local includes for this file

.code

start:

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

  ; ------------------
  ; set global values
  ; ------------------
    ; rv means get the return values from a procedure.
    mov hInstance,   rv(GetModuleHandle, NULL)
    mov CommandLine, rv(GetCommandLine)
    mov hIcon,       rv(LoadIcon,hInstance,500)
    mov hCursor,     rv(LoadCursor,NULL,IDC_ARROW)
    mov sWid,        rv(GetSystemMetrics,SM_CXSCREEN)
    mov sHgt,        rv(GetSystemMetrics,SM_CYSCREEN)

  ; -------------------------------------------------
  ; load the toolbar button strip at its default size
  ; -------------------------------------------------
    invoke LoadImage,hInstance,700,IMAGE_BITMAP,0,0, \
           LR_DEFAULTSIZE or LR_LOADTRANSPARENT or LR_LOADMAP3DCOLORS
    mov hBitmap, eax

  ; ----------------------------------------------------------------
  ; load the rebar background tile stretching it to the rebar height
  ; ----------------------------------------------------------------
    mov tbTile, rv(LoadImage,hInstance,800,IMAGE_BITMAP,sWid,rbht,LR_DEFAULTCOLOR)

    call Main

    invoke ExitProcess,eax

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD,mWid:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL icce:INITCOMMONCONTROLSEX

  ; --------------------------------------
  ; comment out the styles you don't need.
  ; --------------------------------------
    mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX            ; set the structure size
    xor eax, eax                                            ; set EAX to zero
    or eax, ICC_WIN95_CLASSES
    or eax, ICC_BAR_CLASSES                                 ; comment out the rest
    ; or eax, ICC_TREEVIEW_CLASSES
    ; or eax, ICC_LISTVIEW_CLASSES
    ; or eax, ICC_COOL_CLASSES
    ; or eax, ICC_DATE_CLASSES
    ; or eax, ICC_PROGRESS_CLASS
    ; or eax, ICC_TAB_CLASSES
    ; or eax, ICC_HOTKEY_CLASS
    ; or eax, ICC_INTERNET_CLASSES
    ; or eax, ICC_PAGESCROLLER_CLASS
    ; or eax, ICC_UPDOWN_CLASS
    ; or eax, ICC_ANIMATE_CLASS                               ; OR as many styles as you need to it
    ; or eax, ICC_USEREX_CLASSES
    mov icce.dwICC, eax
    invoke InitCommonControlsEx,ADDR icce                   ; initialise the common control library
  ; --------------------------------------

    STRING szClassName,   "Application_Class"
    

  ; ---------------------------------------------------
  ; set window class attributes in WNDCLASSEX structure
  ; ---------------------------------------------------
    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW
    m2m wc.lpfnWndProc,    OFFSET WndProc
    mov wc.cbClsExtra,     NULL
    mov wc.cbWndExtra,     NULL
    m2m wc.hInstance,      hInstance
    m2m wc.hbrBackground,  NULL                             ; client area is covered by the client window
    mov wc.lpszMenuName,   NULL
    mov wc.lpszClassName,  OFFSET szClassName
    m2m wc.hIcon,          hIcon
    m2m wc.hCursor,        hCursor
    m2m wc.hIconSm,        hIcon

  ; ------------------------------------
  ; register class with these attributes
  ; ------------------------------------
    invoke RegisterClassEx, ADDR wc

  ; ---------------------------------------------
  ; set width and height as percentages of screen
  ; ---------------------------------------------
    invoke GetPercent,sWid,70
    mov Wwd, eax
    invoke GetPercent,sHgt,70
    mov Wht, eax

  ; ----------------------
  ; set aspect ratio limit
  ; ----------------------
    FLOAT4 aspect_ratio, 1.4    ; set the maximum startup aspect ratio

    fild Wht                    ; load source
    fld aspect_ratio            ; load multiplier
    fmul                        ; multiply source by multiplier
    fistp mWid                  ; store result in variable

    mov eax, Wwd
    .if eax > mWid              ; if the default window width is > aspect ratio
      m2m Wwd, mWid             ; set the width to the maximum aspect ratio
    .endif

  ; ------------------------------------------------
  ; Top X and Y co-ordinates for the centered window
  ; ------------------------------------------------
    mov eax, sWid
    sub eax, Wwd                ; sub window width from screen width
    shr eax, 1                  ; divide it by 2
    mov Wtx, eax                ; copy it to variable

    mov eax, sHgt
    sub eax, Wht                ; sub window height from screen height
    shr eax, 1                  ; divide it by 2
    mov Wty, eax                ; copy it to variable

  ; -----------------------------------------------------------------
  ; create the main window with the size and attributes defined above
  ; -----------------------------------------------------------------
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES,
                          ADDR szClassName,
                          ADDR szDisplayName,
                          WS_OVERLAPPEDWINDOW,
                          Wtx,Wty,Wwd,Wht,
                          NULL,NULL,
                          hInstance,NULL
    mov hWnd,eax

    fn LoadLibrary,"RICHED20.DLL"
    mov hEdit, rv(RichEdit2,hInstance,hWnd,999,0)
    invoke SendMessage,hEdit,EM_EXLIMITTEXT,0,1000000000
    invoke SendMessage,hEdit,EM_SETOPTIONS,ECOOP_XOR,ECO_SELECTIONBAR

  ; ----------------------------------------------------
  ; different fixed font types from the operating system
  ; ----------------------------------------------------
  ; ANSI_FIXED_FONT
  ; OEM_FIXED_FONT

    invoke SendMessage,hEdit,WM_SETFONT,rv(GetStockObject,SYSTEM_FIXED_FONT),TRUE

    invoke LoadMenu,hInstance,600
    invoke SetMenu,hWnd,eax

    invoke ShowWindow,hWnd, SW_SHOWNORMAL
    invoke UpdateWindow,hWnd

    call MsgLoop
    ret

Main endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

MsgLoop proc

    LOCAL msg:MSG

  ; -----------------------------------
  ; Loop until PostQuitMessage is sent
  ; -----------------------------------

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      cmp eax, 0
      je ExitLoop

    ; ------------------------------------------------
    ; process hotkey directly in the message loop
    ; ------------------------------------------------
      .if msg.message == WM_KEYDOWN
        .if msg.wParam == VK_ESCAPE
          invoke SendMessage,hWnd,WM_SYSCOMMAND,SC_CLOSE,NULL
        .elseif msg.wParam == VK_CONTROL
          mov CtrlFlag, 1                   ; flag set
        .endif
      .endif

      .if msg.message == WM_KEYUP
        .if msg.wParam == VK_F1
            invoke SendMessage,hWnd,WM_COMMAND,10000,0
        .elseif msg.wParam == VK_F2
            invoke CallSearchDlg
        .elseif msg.wParam == VK_F3
            invoke TextFind,ADDR SearchText, TextLen
        .endif
        .if msg.wParam == VK_CONTROL
          mov CtrlFlag, 0                   ; flag clear
        .elseif msg.wParam == 4Eh           ; Ctrl + N
          .if CtrlFlag == 1
            invoke SendMessage,hWnd,WM_COMMAND,1000,0
          .endif
        .elseif msg.wParam == 4Fh           ; Ctrl + O
          .if CtrlFlag == 1
            invoke SendMessage,hWnd,WM_COMMAND,1010,0
          .endif
        .elseif msg.wParam == 53h           ; Ctrl + S
          .if CtrlFlag == 1
            invoke SendMessage,hWnd,WM_COMMAND,1020,0
          .endif
        .endif
      .endif
    ; ------------------------------------------------

      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
      jmp StartLoop
    ExitLoop:

      return msg.wParam

    ret

MsgLoop endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

WndProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL fname  :DWORD
    LOCAL opatn  :DWORD
    LOCAL spatn  :DWORD
    LOCAL rct    :RECT
    LOCAL buffer1[260]:BYTE  ; these are two spare buffers
    LOCAL buffer2[260]:BYTE  ; for text manipulation etc..
    LOCAL tbb   :TBBUTTON
    LOCAL Tba   :TBADDBITMAP

    Switch uMsg
      Case WM_COMMAND
      ; -------------------------------------------------------------------
        ;---------
        ; toolbar
        ;---------
        Switch wParam
          case 50
            fn SetWindowText,hWin,"Untitled"
            invoke SetWindowText,hEdit,0

          case 51
            sas opatn, "All files",0,"*.*",0
            mov fname, rv(open_file_dialog,hWin,hInstance,"Open File",opatn)
            cmp BYTE PTR [eax], 0
            jne @F
            return 0

          case 52
            sas spatn, "All files",0,"*.*",0
            mov fname, rv(save_file_dialog,hWin,hInstance,"Save File As ...",spatn)
            cmp BYTE PTR [eax], 0
            jne @F
            return 0
          @@:
            invoke file_write,hEdit,fname
            invoke SetWindowText,hWin,fname

          case 53
            invoke SendMessage,hEdit,WM_CUT,0,0

          case 54
            invoke SendMessage,hEdit,WM_COPY,0,0

          case 55
            invoke SendMessage,hEdit,EM_PASTESPECIAL,CF_TEXT,NULL

          case 56
            invoke SendMessage,hEdit,EM_UNDO,0,0

          case 57
            invoke CallSearchDlg
            
          case 1000
            file_new:
            fn SetWindowText,hWin,"Untitled"
            invoke SetWindowText,hEdit,0

          case 1010
          file_open:
            sas opatn, "All files",0,"*.*",0
            mov fname, rv(open_file_dialog,hWin,hInstance,"Open File",opatn)
            cmp BYTE PTR [eax], 0
            jne @F
            return 0
          @@:
            invoke file_read,hEdit,fname
            invoke SetWindowText,hWin,fname

          case 1020
          file_save_as:
            sas spatn, "All files",0,"*.*",0
            mov fname, rv(save_file_dialog,hWin,hInstance,"Save File As ...",spatn)
            cmp BYTE PTR [eax], 0
            jne @F
            return 0
          @@:
            invoke file_write,hEdit,fname
            invoke SetWindowText,hWin,fname

        ; ------------------
        ; edit menu commands
        ; ------------------
          case 1101
            undo:
            invoke SendMessage,hEdit,WM_UNDO,0,0

          case 1102
            redo:
            invoke SendMessage,hEdit,EM_REDO,0,0

          case 1103
            editcut:
            invoke SendMessage,hEdit,WM_CUT,0,0

          case 1104
            editcopy:
            invoke SendMessage,hEdit,WM_COPY,0,0
          case 1105
            editpaste:
            invoke SendMessage,hEdit,EM_PASTESPECIAL,CF_TEXT,NULL

          case 1106
            invoke SendMessage,hEdit,WM_CLEAR,0,0

          case 1107
            invoke Select_All,hEdit

          case 1108
            search:
            invoke CallSearchDlg
          
          case 1109
            find_next:
            invoke TextFind,ADDR SearchText, TextLen
            
          case 1090
          app_close:
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
          
          case 10000
            fn MsgboxI,hWin,"Assembly term-project.", "About",MB_OK,500

        Endsw
      ; -------------------------------------------------------------------

      case WM_DROPFILES
      ; --------------------------
      ; process dropped files here
      ; --------------------------
        mov fname, DropFileName(wParam)
        fn MsgboxI,hWin,fname,"WM_DROPFILES",MB_OK,500
        return 0

      case WM_CREATE
        mov hRebar,   rv(rebar,hInstance,hWin,rbht)     ; create the rebar control
        ;mov hToolBar, rv(addband,hInstance,hRebar)      ; add the toolbar band to it
        mov hStatus,  rv(StatusBar,hWin)                ; create the status bar
        ;--------------------
        ; Create the tool bar
        ;--------------------

        mov tbb.iBitmap,   0
        mov tbb.idCommand, 0
        mov tbb.fsState,   TBSTATE_ENABLED
        mov tbb.fsStyle,   TBSTYLE_SEP
        mov tbb.dwData,    0
        mov tbb.iString,   0

        invoke CreateToolbarEx,hWin,WS_CHILD or WS_CLIPSIBLINGS,
                               300,1,0,0,ADDR tbb,
                               1,16,16,0,0,sizeof TBBUTTON
        mov hToolBar, eax
        invoke ShowWindow,hToolBar,SW_SHOW

        ;-----------------------------------------
        ; Select tool bar bitmap from commctrl DLL
        ;-----------------------------------------

        mov Tba.hInst, HINST_COMMCTRL
        mov Tba.nID, 1   ; btnsize 1=big 2=small

        invoke SendMessage,hToolBar,TB_ADDBITMAP,1,ADDR Tba

        ;------------------------
        ; Add buttons to tool bar
        ;------------------------

        mov tbb.iBitmap,   STD_FILENEW
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        mov tbb.idCommand, 50
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_FILEOPEN
        mov tbb.idCommand, 51
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_FILESAVE
        mov tbb.idCommand, 52
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.idCommand, 0
        mov tbb.fsStyle,   TBSTYLE_SEP
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_CUT
        mov tbb.idCommand, 53
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_COPY
        mov tbb.idCommand, 54
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_PASTE
        mov tbb.idCommand, 55
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_UNDO
        mov tbb.idCommand, 56
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   0
        mov tbb.idCommand, 0
        mov tbb.fsStyle,   TBSTYLE_SEP
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_FIND
        mov tbb.idCommand, 57
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   0
        mov tbb.idCommand, 0
        mov tbb.fsStyle,   TBSTYLE_SEP
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

      case WM_SIZE
        invoke MoveWindow,hStatus,0,0,0,0,TRUE

        push esi
        invoke GetClientRect,hWin,ADDR rct
        mov esi, rct.bottom
        sub esi, rbht

        invoke GetClientRect,hStatus,ADDR rct

        sub esi, rct.bottom

        invoke MoveWindow,hEdit,0,rbht,rct.right,esi,TRUE

        pop esi

      case WM_SETFOCUS
        invoke SetFocus,hEdit

      case WM_CLOSE
      ; -----------------------------
      ; perform any required cleanups
      ; here before closing.
      ; -----------------------------

      case WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    Endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

TBcreate proc parent:DWORD

  ; -----------------------------
  ; run to toolbar creation macro
  ; -----------------------------
    ToolbarInit tbbW, tbbH, parent

  ; -----------------------------------
  ; Add toolbar buttons and spaces here
  ; arg1 bmpID (zero based)
  ; arg2 cmdID (1st is 50)
  ; -----------------------------------
    TBbutton  0,  50
    TBbutton  1,  51
  ; -----------------------------------

    mov eax, tbhandl

    ret

TBcreate endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

StatusBar proc hParent:DWORD

    LOCAL handl :DWORD
    LOCAL sbParts[4] :DWORD

    mov handl, rv(CreateStatusWindow,WS_CHILD or WS_VISIBLE or SBS_SIZEGRIP,NULL,hParent,200)

  ; --------------------------------------------
  ; set the width of each part, -1 for last part
  ; --------------------------------------------
    mov [sbParts+0], 100
    mov [sbParts+4], 200
    mov [sbParts+8], 300
    mov [sbParts+12],-1

    invoke SendMessage,handl,SB_SETPARTS,4,ADDR sbParts

    mov eax, handl

    ret

StatusBar endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
