TITLE Snake.asm

INCLUDE Irvine32.inc

.DATA

a WORD 1920 DUP(0)  ; Framebuffer (24x80)

tR BYTE 16d         ; 蛇的尾巴 -> row number
tC BYTE 47d         ; 蛇的尾巴 -> column number
hR BYTE 13d         ; 蛇的頭   -> row number
hC BYTE 47d         ; 蛇的頭   -> column number
fR BYTE 0           ; 食物 -> row
fC BYTE 0           ; 食物 -> column

tmpR BYTE 0         ; Temporary variable -> row indexes
tmpC BYTE 0         ; Temporary variable -> column indexes

rM BYTE 0d          ; Index of row above current row (row minus)
cM BYTE 0d          ; Index of column left of current column (column minus)
rP BYTE 0d          ; Index of row below current row (row plus)
cP BYTE 0d          ; Index of column right of current column (column plus)

eTail   BYTE    1d  ; Flag -> if tail should be deleted or not
search  WORD    0d  ; Variable for storing value of next snake segment
eGame   BYTE    0d  ; Flag -> game should be ended (collision)
cScore  DWORD   0d  ; Total score

d       BYTE    'w' ; current direction of the snake
newD    BYTE    'w' ; new direction specified by input
delayTime DWORD   100 ; Delay time between frames (game speed)


menuString   BYTE "Hello! Welcome to Gluttonous Snake Game!", 0Dh, 0Ah,
             "Please input '1' or '2' or '3' to select.", 0Dh, 0Ah, 0Ah,
             "1. Start Game", 0Dh, 0Ah,
             "2. Select Speed", 0Dh, 0Ah,
             "3. Exit",0Dh, 0Ah, 0
speedString  BYTE "1. Slow", 0Dh, 0Ah, 
             "2. Normal", 0Dh, 0Ah, 
             "3. Fast", 0Dh, 0Ah, 
             "4. Super fast", 0Dh, 0Ah, 0
GameOverString    BYTE "Game Over!", 0
scoreS  BYTE "Score: 0", 0
WrongMsg  BYTE "Invalid input", 0

myHandle DWORD ?    ; Variable for holding the terminal input handle
numInp   DWORD ?    ; Variable for holding number of bytes in input buffer
temp BYTE 16 DUP(?) ; Variable for holding data of type INPUT_RECORD
bRead    DWORD ?    ; Variable for holding number of read input bytes

.CODE

main PROC

menu:
    call Randomize              ; Set seed for food generation
    call Clrscr                 ; 清除螢幕
    mov edx, OFFSET menuString  
    call WriteString            ; 顯示 menuString

wait1:                      
    call ReadChar               ; 讀取輸入的字元 for menu

    cmp AL, '1'                 ; '1' -> startGame
    je startG

    cmp AL, '2'                 ; '2' -> choose speed
    je speed

    cmp AL, '3'                 ; '3' -> exit
    EXIT

speed:                      
    call Clrscr                 ; 清除螢幕
    mov edx, OFFSET speedString 
    call WriteString            ; 顯示 speedString

wait2:                      ; 讀取輸入的字元 for speed
    call ReadChar

    cmp AL, '1'                 ; '1' -> Slow speed
    je speed_Slow

    cmp AL, '2'                 ; '2' -> Normal speed
    je speed_Normal

    cmp AL, '3'                 ; '3' -> Fast speed
    je speed_Fast

    cmp AL, '4'                 ; '4' -> SuperFast speed
    je speed_SuperFast

    mov edx, OFFSET WrongMsg    
    call WriteString            ; 不是'1'~'4' -> 顯示 WrongMsg
    jmp wait2                   ; loop wait2

speed_Slow:                     ; Set refresh rate of game to 150ms
    mov delayTime, 150
    jmp menu                    ; 回到 main menu

speed_Normal:                   
; Set refresh rate of game to 100ms
    mov delayTime, 100
    jmp menu                    ; 回到 main menu

speed_Fast:
    mov delayTime, 75           ; Set refresh rate of game to 50ms
    jmp menu                    ; 回到 main menu

speed_SuperFast:
    mov delayTime, 50           ; Set refresh rate of game to 35ms
    jmp menu                    ; 回到 main menu                   

startG:                     
                                
    mov eax, 0                  ; Clear register
    mov edx, 0
    call Clrscr                 ; Clear terminal screen
    call initSnake              ; Initialize snake position
    call Paint                  ; Paint level to terminal screen
    call createFood             ; Create snake food location, print to screen
    call startGame              ; call main infinite loop
    mov eax, white + (black * 16)
    call SetTextColor           ; Gave was exited, reset screen color
    jmp menu                    ; and jump back to main menu

main ENDP

initSnake PROC USES ebx edx

; This procedure initializes the snake to the default position in the center of the screen

    mov DH, 13      ; Set row number to 13
    mov DL, 47      ; Set column number to 47
    mov BX, 1       ; First segment of snake
    call saveIndex  ; Write to framebuffer

    mov DH, 14      ; Set row number to 14
    mov DL, 47      ; Set column number to 47
    mov BX, 2       ; Second segment of snake
    call saveIndex  ; Write to framebuffer

    mov DH, 15      ; Set row number to 15
    mov DL, 47      ; Set column number to 47
    mov BX, 3       ; Third segment of snake
    call saveIndex  ; Write to framebuffer

    mov DH, 16      ; Set row number to 16
    mov DL, 47      ; Set column number to 47
    mov BX, 4       ; Fourth segment of snake
    call saveIndex  ; Write to framebuffer

    RET

initSnake ENDP

clearMem PROC

; 1. 清除 framebuffer
; 2. 重設蛇的位置和長度
; 3. 設定所有flags回到預設值

    mov DH, 0               ; Set the row register to zero
    mov BX, 0               ; Set the data register to zero

    oLoop:                  ; Outer loop for matrix indexing (for rows)
        cmp DH, 24          ; Count for 24 rows and break if row number is 24
                            ; (since indexing starts form 0)
        je endOLoop

        mov DL, 0           ; Set the column number to zero

        iLoop:              ; Inner loop for matrix indexing (for columns)
            cmp DL, 80      ; Count for 80 columns and
            je endILoop     ; break if column number is 80

            call saveIndex  ; call procedure for writing to the framebuffer
                            ; based on the DH and DL registers
            INC DL          ; Increment column number
            jmp iLoop       ; Continue inner loop

    endILoop:               ; End of innter loop
        INC DH              ; Increment row number
        jmp oLoop           ; Continue outer loop

endOLoop:                   ; End of outer loop
    mov tR, 16              ; Reset coordinates of
    mov tC, 47              ; snake tail (row and column)
    mov hR, 13              ; Reset coordinates of
    mov hC, 47              ; snake head (row and column)

    mov eGame, 0            ; Clear the end game flag
    mov eTail, 1            ; Set the erase tail flag (no food eaten)
    mov d, 'w'              ; Set current direction to up
    mov newD, 'w'           ; Set new direction to up
    mov cScore, 0           ; Reset total score

    RET
clearMem ENDP

startGame PROC USES eax ebx ECX edx

        mov eax, white + (black * 16)       ; Set text color to white on black
        call SetTextColor
        mov DH, 24                          ; Move cursor to bottom lef side
        mov DL, 0                           ; of screen, to write the score
        call GotoXY                         ; string
        mov edx, OFFSET scoreS
        call WriteString

        ; Get console input handle and store it in memory
        INVOKE getStdHandle, STD_INPUT_HANDLE
        mov myHandle, eax
        mov ECX, 10

        ; Read two events from buffer
        INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead
        INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead

       ; Main infinite loop
    more:

        ; Get number of events in input buffer
        INVOKE GetNumberOfConsoleInputEvents, myHandle, ADDR numInp
        mov ECX, numInp

        cmp ECX, 0                          ; Check if input buffer is empty
        je done                             ; Continue loop if buffer is empty

        ; Read one event from input buffer and save it at temp
        INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead
        mov DX, WORD PTR temp               ; Check if EventType is KEY_EVENT,
        cmp DX, 1                           ; which is determined by 1st WORD
        JNE SkipEvent                       ; of INPUT_RECORD message

            mov DL, BYTE PTR [temp+4]       ; Skip key released event
            cmp DL, 0
            je SkipEvent
                mov DL, BYTE PTR [temp+10]  ; Copy pressed key into DL

                cmp DL, 1Bh                 ; Check if ESC key was pressed and
                je quit                     ; quit the game if it was

                cmp d, 'w'                  ; Check if current snake direction
                je case1                    ; is vertical, and jump to case1 to
                cmp d, 's'                  ; handle direction change if the
                je case1                    ; change is horizontal

                jmp case2                   ; Jump to case2 if the current
                                            ; direction is horizontal
                case1:
                    cmp DL, 25h             ; Check if left arrow was in input
                    je case11
                    cmp DL, 27h             ; Check if right arrow was in input
                    je case12
                    jmp SkipEvent           ; If up or down arrows were in
                                            ; input, no direction change
                    case11:
                        mov newD, 'a'       ; Set new direction to left
                        jmp SkipEvent
                    case12:
                        mov newD, 'd'       ; Set new direction to right
                        jmp SkipEvent

                case2:
                    cmp DL, 26h             ; Check if up arrow was in input
                    je case21
                    cmp DL, 28h             ; Check if down arrow was in input
                    je case22
                    jmp SkipEvent           ; If left of right arrows were in
                                            ; input, no direction change
                    case21:
                        mov newD, 'w'       ; Set new direction to up
                        jmp SkipEvent
                    case22:
                        mov newD, 's'       ; Set new direction to down
                        jmp SkipEvent

    SkipEvent:
        jmp more                            ; Continue main loop

    done:

        mov BL, newD                        ; Set new direction as snake
                                            ; direction
        mov d, BL
        call MoveSnake                      ; Update direction and position
        mov eax, delayTime                    ; Delay before next iteration (game
        call Delay                          ; speed is influenced this way)

        mov BL, d                           ; Why is this needed?
        mov newD, BL                        ; Maybe delete these two lines

        cmp eGame, 1                        ; Check if end game flag is set
        je quit                             ; (from a collision)

        jmp more                            ; Continue main loop

        quit:
        call clearMem                       ; Set all game related things to
        mov delayTime, 100                    ; default, and go back to main
                                            ; menu
    RET

startGame ENDP

MoveSnake PROC USES ebx edx

; This procedure updates the framebuffer, thus moving the snake. The procedure
; starts from the snake tail, and searches for the next segment in the
; region of the current segment. All segments get updated, while the last
; segment gets erased (if no food has been eaten), and a new segment gets
; addded to the beginning of the snake, depending on the terminal input.
; This procedure also check if there has been a collision, and if the food was
; gobbled or not.

    cmp eTail, 1            ; Check if erase tail flag is set
    JNE NoETail             ; Don't erase the tail if flag is not set

        mov DH, tR          ; Copy tail row index into DH
        mov DL, tC          ; Copy tail column index into DL
        call accessIndex    ; Access framebuffer at given index
        DEC BX              ; Decrement value returned from framebuffer (this
                            ; gives us the value of the next segment)
        mov search, BX      ; Copy value of next segment to search

        mov BX, 0           ; Erase the value at current index from the
        call saveIndex      ; framebuffer (the snake tail)

        call GotoXY         ; Erase snake tail pixel from screen
        mov eax, white + (black * 16)
        call SetTextColor
        mov AL, ' '
        call WriteChar

        PUSH edx            ; Move cursor to bottom right side of the screen
        mov DL, 79
        mov DH, 23
        call GotoXY
        POP edx

        mov AL, DH          ; Copy tail row index into AL
        DEC AL              ; Get index of row above current row
        mov rM, AL          ; Save index of row above current row
        ADD AL, 2           ; Get index of row below current row
        mov rP, AL          ; Save index of row below current row

        mov AL, DL          ; Copy tail column index into AL
        DEC AL              ; Get index of column left of current column
        mov cM, AL          ; Save index of column left of current column
        ADD AL, 2           ; Get index of column right of current column
        mov cP, AL          ; Save index of column right of current column

        cmp rP, 24          ; Check if new index is getting off screen
        JNE next1
            mov rP, 0       ; Wrap the index around the screen

        next1:
        cmp cP, 80          ; Check if new index is getting off screen
        JNE next2
            mov cP, 0       ; Wrap the index around the screen

        next2:
        cmp rM, 0           ; Check if new index is getting off screen
        JGE next3
            mov rM, 23      ; Wrap the index around the screen

        next3:
        cmp cM, 0           ; Check if new index is getting off screen
        JGE next4
            mov cM, 79      ; Wrap the index around the screen

        next4:

        mov DH, rM          ; Copy row index of pixel above tail into DH
        mov DL, tC          ; Copy column index of pixel above tail into DL
        call accessIndex    ; Access pixel value in framebuffer
        cmp BX, search      ; Check if pixel is the next segment of the snake
        JNE melseif1
            mov tR, DH      ; Move tail to new location, if it is
            jmp mendif

        melseif1:
        mov DH, rP          ; Copy row index of pixel below tail into DH
        call accessIndex    ; Acces pixel value in framebuffer
        cmp BX, search      ; Check if pixel is the next segment of the snake
        JNE melseif2
            mov tR, DH      ; Move tail to new location, if it is
            jmp mendif

        melseif2:
        mov DH, tR          ; Copy row index of pixel left of tail into DH
        mov DL, cM          ; Copy column index of pixel left of tail into DH
        call accessIndex    ; Access pixel value in framebuffer
        cmp BX, search      ; Check if pixes is the next segment of the snake
        JNE melse
            mov tC, DL      ; Move tail to new location, if it is
            jmp mendif

        melse:
            mov DL, cP      ; Move tail to pixel right of tail
            mov tC, DL

        mendif:

    NoETail:

    mov eTail, 1            ; Set erase tail flag
    mov DH, tR              ; Copy row index of tail into DH
    mov DL, tC              ; Copy column index of tail into DL
    mov tmpR, DH            ; Copy row index into memory
    mov tmpC, DL            ; Copy column index into memory

    whileTrue:              ; Infinite loop for going over all the snake
                            ; segments and adjusting each value
        mov DH, tmpR        ; Copy current row index into DH
        mov DL, tmpC        ; Copy current column index into DL
        call accessIndex    ; Get pixel value form framebuffer
        DEC BX              ; Decrement pixel value to get the value of the
                            ; next snake segment
        mov search, BX      ; Copy value of next segment into search

        PUSH ebx            ; Replace current segment value in framebuffer with
        ADD BX, 2           ; previous segment value (snake is moving, segments
        call saveIndex      ; are moving)
        POP ebx

        cmp BX, 0           ; Check if the current segment is the head of the
        je break            ; snake

        mov AL, DH          ; Copy row index of current segment into AL
        DEC AL              ; Get index of row above current row
        mov rM, AL          ; Save index of row above current row
        ADD AL, 2           ; Get index of row below current row
        mov rP, AL          ; Save index of row below current row

        mov AL, DL          ; Copy column index of current segment into AL
        DEC AL              ; Get index of column left of current column
        mov cM, AL          ; Save index of column left of current column
        ADD AL, 2           ; Get index of column right of current column
        mov cP, AL          ; Save index of column right of current column

        cmp rP, 24          ; Check if new index is getting off screen
        JNE next21
            mov rP, 0       ; Wrap index around screen

        next21:
        cmp cP, 80          ; Check if new index is getting off screen
        JNE next22
            mov cP, 0       ; Wrap index around screen

        next22:
        cmp rM, 0           ; Check if index is getting off screen
        JGE next23
            mov rM, 23      ; Wrap index around screen

        next23:
        cmp cM, 0           ; Check if index is getting off screen
        JGE next24
            mov cM, 79      ; Wrap index around screen

        next24:

        mov DH, rM          ; Copy row index of pixel above segment into DH
        mov DL, tmpC        ; Copy column index of pixel above segment into DH
        call accessIndex    ; Access pixel value in framebuffer
        cmp BX, search      ; Check if pixel is the next segment of the snake
        JNE elseif21
            mov tmpR, DH    ; Move index to new location, if it is
            jmp endif2

        elseif21:
        mov DH, rP          ; Copy row index of pixel below segment into DH
        call accessIndex    ; Access pixel value in framebuffer
        cmp BX, search      ; Check if pixel is the next segment of the snake
        JNE elseif22
            mov tmpR, DH    ; Move index to new location, if it is
            jmp endif2

        elseif22:
        mov DH, tmpR        ; Copy row index of pixel left of segment into DH
        mov DL, cM          ; Copy column index of pxl left of segment into DL
        call accessIndex    ; Access pixel value in framebuffer
        cmp BX, search      ; Check if pixel is the next segment of the snake
        JNE else2
            mov tmpC, DL    ; Move index to new location if it is
            jmp endif2

        else2:
            mov DL, cP      ; Move index to pixel right of segment
            mov tmpC, DL

        endif2:
        jmp whileTrue       ; Continue loop until the snake head is reached

    break:

    mov AL, hR              ; Copy head row index into AL
    DEC AL                  ; Get index of row above head row
    mov rM, AL              ; Save index of row above head row
    ADD AL, 2               ; Get index of row below head row
    mov rP, AL              ; Save index of row below head row

    mov AL, hC              ; Copy head column index into AL
    DEC AL                  ; Get index of column left of head column
    mov cM, AL              ; Save index of column left of head column
    ADD AL, 2               ; Get index of column right of head column
    mov cP, AL              ; Save index of column right of head column

    cmp rP, 24              ; Check if new index is getting off screen
    JNE next31
        mov rP, 0           ; Wrap index around screen

    next31:
    cmp cP, 80              ; Chekc if new index is getting off screen
    JNE next32
        mov cP, 0           ; Wrap index around screen

    next32:
    cmp rM, 0               ; Check if new index is getting off sreen
    JGE next33
        mov rM, 23          ; Wrap index around screen

    next33:
    cmp cM, 0               ; Check if new index is getting off screen
    JGE next34
        mov cM, 79          ; Wrap index around screen

    next34:

    cmp d, 'w'              ; Check if input direction is up
    JNE elseif3
        mov AL, rM          ; Move head row index to new location,
        mov hR, AL          ; above current location
        jmp endif3

    elseif3:
    cmp d, 's'              ; Check if input direction is down
    JNE elseif32
        mov AL, rP          ; Move head row index to new location,
        mov hR, AL          ; below current location
        jmp endif3

    elseif32:
    cmp d, 'a'              ; Check if input direction is left
    JNE else3
        mov AL, cM          ; Move head column index to new location,
        mov hC, AL          ; left of current location
        jmp endif3

    else3:
        mov AL, cP          ; Move head column index to new location,
        mov hC, AL          ; right of current location

    endif3:

    mov DH, hR              ; Copy new head row index into DH
    mov DL, hC              ; Copy new head column index into DL

    call accessIndex        ; Get pixel value of new head location
    cmp BX, 0               ; Check if new head location is empty space
    je NoHit                ; If the new head location is empty space, there
                            ; has been no collision
    mov eax, 4000           ; Set delay time to 4000ms
    mov DH, 24              ; Move cursor to new location, to write game over
    mov DL, 11              ; message
    call GotoXY
    mov edx, OFFSET GameOverString
    call WriteString

    call Delay              ; call delay to pause game for 4 seconds
    mov eGame, 1            ; Set end game flag

    RET                     ; Exit procedure

    NoHit:                  ; Part of procedure that handles the case where
    mov BX, 1               ; there's been no collision
    call saveIndex          ; Write head value to new head location

    mov cl, fC              ; Copy food column to memory
    mov ch, fR              ; Copy food row to memory

    cmp cl, DL              ; Compare new head column and food column
    JNE foodNotGobbled      ; Food has not been eaten
    cmp ch, DH              ; Compare new head row and food row
    JNE foodNotGobbled      ; Food has not been eaten

    call createFood         ; Food has been eaten, create new food location
    mov eTail, 0            ; Clear erase tail flag, so that snake grows in
                            ; next framebuffer update

    mov eax, white + (black * 16)
    call SetTextColor       ; Change background color to white on black

    PUSH edx                ; Push edx onto stack

    mov DH, 24              ; Move cursor to new location, to update score
    mov DL, 7
    call GotoXY
    mov eax, cScore         ; Move score to eax and increment it
    INC eax
    call WriteDec
    mov cScore, eax         ; Copy updated score value back into memory

    POP edx                 ; Pop edx off of stack

    foodNotGobbled:         ; Part of procedure that handles the case where
    call GotoXY             ; food has not been eaten (just adds head)
    mov eax, blue + (white * 16)
    call setTextColor       ; Change text color to blue on white
    mov AL, ' '             ; Write whitesoace to new head location
    call WriteChar
    mov DH, 24              ; Move cursor to bottom right side of screen
    mov DL, 79
    call GotoXY

    RET                     ; Exit procedure

MoveSnake ENDP

createFood PROC USES eax ebx edx

; This procedure generates food for the snake. It uses a radnom nubmer to
; generate the row and column values for the location of the food. It also
; takes into account the position of the snake and obstacles, so that the food
; doesn't overlap with the snake or the obstacles.

    redo:                       ; Loop for food position generation
    mov eax, 24                 ; Generate a radnom integer in the
    call RandomRange            ; range 0 to numRows - 1
    mov DH, AL

    mov eax, 80                 ; Generate a radnom integer in the
    call RandomRange            ; range 0 to numCol - 1
    mov DL, AL

    call accessIndex            ; Get content of generated location

    cmp BX, 0                   ; Check if content is empty space
    JNE redo                    ; Loop until location is empty space

    mov fR, DH                  ; Set food row value
    mov fC, DL                  ; Set food column value

    mov eax, white + (cyan * 16); Set text color to white on cyan
    call setTextColor
    call GotoXY                 ; Move cursor to generated position
    mov AL, ' '                 ; Write whitespace to terminal
    call WriteChar

    RET

createFood ENDP

accessIndex PROC USES eax ESI edx

; This procedure accesses the framebuffer and returns the value of the pixel
; specified by DH (row index) and DL (column index). The pixel value gets
; returned through the register BX.

    mov BL, DH      ; Copy row index into BL
    mov AL, 80      ; Copy multiplication constant for row number
    MUL BL          ; Mulitply row index by 80 to get framebuffer segment
    PUSH DX         ; Push DX onto stack
    mov DH, 0       ; Clear upper byte of DX to get only column index
    ADD AX, DX      ; Add column offset to row segment to get pixel address
    POP DX          ; Pop DX off of stack
    mov ESI, 0      ; Clear indexing register
    mov SI, AX      ; Copy generated address into indexing register
    SHL SI, 1       ; Multiply address by 2 since the elements are of type WORD

    mov BX, a[SI]   ; Copy framebuffer content into BX register

    RET

accessIndex ENDP

saveIndex PROC USES eax ESI edx

; This procedure accesses the framebuffer and writes a value to the pixel
; specified by DH (row index) and DL (column index). The pixel value has to be
; passed though the register BX.

    PUSH ebx        ; Save ebx on stack
    mov BL, DH      ; Copy row number to BL
    mov AL, 80      ; Copy multiplication constant for row number
    MUL BL          ; Multiply row index by 80 to get framebuffer segment
    PUSH DX         ; Push DX onto stack
    mov DH, 0       ; Clear DH register, to access the column number
    ADD AX, DX      ; Add column offset to get the array index
    POP DX          ; Pop old address off of stack
    mov ESI, 0      ; Clear indexing register
    mov SI, AX      ; Move generated address into ESI register
    POP ebx         ; Pop ebx off of stack
    SHL SI, 1       ; Multiply address by two, because elements
                    ; are of type WORD
    mov a[SI], BX   ; Save BX into array

    RET

saveIndex ENDP

Paint PROC USES eax edx ebx ESI

; This procedure reads the contents of the framebuffer, pixel by pixel, and
; puts them onto the terminal screen. This includes the snake and the walls.
; The color of the walls can be changed in this procedure. The color of the
; snake has to be changed here, as well as in the moveSnake procedure.

    mov eax, blue + (white * 16)    ; Set text color to blue on white
    call SetTextColor

    mov DH, 0                       ; Set row number to 0

    loop1:                          ; Loop for indexing of the rows
        cmp DH, 24                  ; Check if the indexing has arrived
        JGE endLoop1                ; at the bottom of the screen

        mov DL, 0                   ; Set column number to 0

        loop2:                      ; Loop for indexing of the columns
            cmp DL, 80              ; Check if the indexing has arrived
            JGE endLoop2            ; at the right side of the screen
            call GOTOXY             ; Set cursor to current pixel position

            mov BL, DH              ; Generate the framebuffer address from
            mov AL, 80              ; the row value stored in DH
            MUL BL
            PUSH DX                 ; Save DX on stack
            mov DH, 0               ; Clear upper bite of DX
            ADD AX, DX              ; Add offset to row address (column adress)
            POP DX                  ; Restore old value of DX
            mov ESI, 0              ; Clear indexing register
            mov SI, AX              ; Move pixel address into indexing register
            SHL SI, 1               ; Multiply indexing address by 2, since
                                    ; we're using elements of type WORD in the
                                    ; framebuffer
            mov BX, a[SI]           ; Get the pixel

            cmp BX, 0               ; Check if pixel is empty space,
            je NoPrint              ; and don't print it if is

            cmp BX, 0FFFFh          ; Check if pixel is part of a wall
            je printHurdle          ; Jump to segment for printing walls

            mov AL, ' '             ; Pixel is part of the snake, so print
            call WriteChar          ; whitespace
            jmp noPrint             ; Jump to end of loop

            PrintHurdle:            ; Segment for printing the walls
            mov eax, blue + (gray * 16) ; Change the text color to blue on gray
            call SetTextColor

            mov AL, ' '             ; Print whitespace
            call WriteChar

            mov eax, blue + (white * 16)    ; Change the text color back to
            call SetTextColor               ; blue on white

            NoPrint:
            INC DL                  ; Increment the column number
            jmp loop2               ; Continue column indexing

    endLoop2:                       ; End of column loop
        INC DH                      ; Increment the row number
        jmp loop1                   ; Continue row indexing

endLoop1:                           ; End of row loop

RET

Paint ENDP

END main


