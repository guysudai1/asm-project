; multi-segment executable file template.
MODEL small  
.386
DATASEG
    
    ; add your data here!
    
    ; defining the vectors 
    ; their form is (x , y , z)
    ; -1 constant to mult by( just for absolute value)
    ; increment to connect lines
    XIncrement dd ?
    YIncrement dd ?
    Steps dd ?
    Vector1 dd 3 dup(0)
    Vector2 dd 3 dup(0)
    Vector3 dd 3 dup(0)
    Vector4 dd 3 dup(0)
    Vector5 dd 3 dup(0)
    Vector6 dd 3 dup(0)
    Vector7 dd 3 dup(0)
    Vector8 dd 3 dup(0)
    Vector9 dd 3 dup(0)
    Vector10 dd 3 dup(0)    
    ; this variable marks the end of the vectors
    endOfVectors dd "$"
    
    itsEaster dd 3 dup(0,1048576,0) ; EASTER EGG 
    foundEasterEgg db "You have found the easter egg!"
    returned dd 0
    
    
    ; ending the definition of the vectors
    len dw 16
                      
   
    selectedOption dw 0 ; variable for the menu screens
    
    ; 0 - cube
    ; 1 - pyramid
    ; 2 - Prism
    ; 3 - ark                  
    
    selectedoptionshapes dw 0 ; the final shape to use
    
    menu2selected dw 0 
    
    maxOptions dw 2
    menu2maxoptions dw 2
    
    ; current position (in pixels) { row , col }
    factorialHelper dd ?
    PI dd  00000000000000110010010000111111b ; pi in an 16.16 format   
    currentPos dw 2 dup(0)
    tempPos dw 2 dup(0)
                 
    calcAngle dw ? ; the angle to add ( ranges from 0 to 65535 )
    
    menuFocused db 16
    menuTextGuide db 24 , 255 , 25
    menuTextGuideEnter db "ENTER"
    menuTextCube db "Cube"
    menuTextPyramid db "Pyramid" 
    menuText2Angle db "Angle"
    menuText2ActAngle dw 0 ; the actual angle to calculate with
    menuText2PrintAngle db 5 dup(30h) ; the angle to print       
    menuText2GuideColor db "CHOOSE COLOR " , 24 , 255 , 25
    menuText2GuideAngle db "CHOOSE ANGLE | DEL" 
    menuText2GuideTab db "TAB TO FOCUS"
    simulGuideReturn db "r to return"
    colorOfChoice db 1
                                                   
    ; file opening var
    sinCalcFactorial dd 0 
    sinCalcAngle dd 0
    sinCalcSign dd 0  
    sinCalcSum dd 0 ; a variable used to calculate sine
    
    cosCalcSum dd 0 ; a variable used to calculate cosine
    cosCalcAngle dd 0
    cosCalcFactorial dd 0
    cosCalcSign dd 0 
    
    
    tanx dd 0
    
    cosRadSign dw 0  ; sign that determines if to get the cos in the negative form or positive
    sinRadSign dw 0  ; sign that determines if to get the cos in the negative form or positive 
    toRadians dd 0 ; from degrees to radians 
   
    pushToAdd1 dd 0
    pushToAdd2 dd 0
    
    pushToSub1 dd 0
    pushToSub2 dd 0
    
    pushToMult1 dd 0
    pushToMult2 dd 0    
    
    pushToRad dd 0
    
    pushToDiv1 dd 0
    pushToDiv2 dd 0
    
    divFixedHelper dd 0  ; a variable to put the result of dividing two fixed point numbers in an 16.16 format
                        
    mulFixedHelper dd 0 ; a variable to put the result of multiplying two fixed point numbers in an 16.16 format

STACK 200h

CODESEG 
    start:       
    
    ; set segment registers:
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    mov ax , 200h
    mov sp , ax                                
    theBeginning:
    
    call startMode ; setting the video mode
    xor eax , eax
    xor ebx , ebx
    xor ecx , ecx
    xor edx , edx
    call getShape
    
    push ax
    push ax
    call drawMenuBox 
    
    call getFeatures 
    
    lea si , menuText2ActAngle
    mov ax , [si]
    lea si , calcAngle 
    
    mov [si] , ax 
    xor eax , eax
    xor ebx , ebx
    xor ecx , ecx
    xor edx , edx
    push ax
    push ax
    call drawMenuBox             
    
    mov ax , @data
    mov es , ax
    mov al , 1
    mov ah , 13h
    mov bh , 0
    mov bl , 8
    mov cx , 11
    mov dh , 0
    mov dl , 15
    lea bp , simulGuideReturn
    int 10h
    ; initiating the selected shape's vectors
    
    lea si , selectedoptionShapes
    mov ax , [si]  
    cmp ax , 0
    jnz notCubeShape
    call initiateCube
    jmp mainLoop
    notCubeShape:
    cmp ax, 1
    jnz notPyramidShape
    call initiatePyramid
    jmp mainLoop
    notPyramidShape:      
    mainLoop:      
                
        ;cmp cx , 0
        ;jz endProgram 

        ; clearing the entire screen
        ; initializing the positions 
        lea di , colorOfChoice
        lea si , selectedoptionshapes
        mov bx , [si]
        cmp bx , 0
        jnz notCube
        mov al , [di]
        xor ah , ah
        push ax
        call drawCube
        jmp skipIt1
        notCube: 
        cmp bx , 1
        jnz notPyramidSelected
        mov al , [di]
        xor ah , ah
        push ax
        call drawPyramid
        jmp skipIt1 
        notPyramidSelected:
        
        skipIt1:
        call waitForArrow

        jmp mainloop
    endProgram:
    
    mov ax, 4c00h
    int 21h   
    
    
    ; EASTER EGG - CAN YOU FIGURE OUT WHAT IS DOES?
    
    easterEgg proc 
        mov bp , sp
        pushad
  
        
          push bp
    
          mov dx , 1
          push dx
          call degToRadiansSin
          pop bp
          lea si , sincalcsum
          mov eax , [si] 
          
           
          push bp
            
          mov dx , 1
          push dx
          call degToRadiansCos
          pop bp
          
          lea si , sincalcsum
          mov [si] , eax

          mov cx , 0
          
          keepEastering:
              mov ax , 30
              push ax      
              
              lea si , tempPos
              push si
              mov ax , 100
              mov [si] , ax
              
              add si , 2 
              mov ax , 160
              mov [si] , ax
              
              lea si , itsEaster
              push si
              
              call drawvecsnew 
              
              xor eax , eax
              xor ebx , ebx
              xor edx , edx
              
              cmp cx , 361
              jz doneEaster
              
              lea di , itsEaster 
              mov eax , [di] 
              add di ,4
              mov edx , [di] 
              sub di , 4
              
              ; implementing the x0cos(0) part
              push bp
              lea si , pushToMult1
              mov [si] , eax       
              push si
              lea si , coscalcsum
              push si
              
              call mulFixed
              pop bp    
              ; getting the value of x0cos(0)   
              lea si , mulFixedHelper
              mov ebx , [si]
              ; implementing the ysin(0) part
              push bp
              lea si , pushToMult1
              mov [si] , edx  
              push si
              lea si , sincalcsum
              push si
              call mulFixed
              pop bp 
              ; subtracting between the two given values
              lea si , mulFixedHelper
              mov edx , [si]
              sub ebx , edx
              mov [di] , ebx                        
              
              ; y = x0sin(0) + y0cos(0) 
              ; where 
              ; 0 - angle, y - y value of the vector, y0 - old y length, x0 - old x length
              add di , 4
              
              push bp
              lea si , pushToMult1
              mov [si] , eax  
              push si
              lea si , sincalcsum
              push si 
             
              call mulFixed
              pop bp                 
              
              lea si , mulFixedHelper
              mov ebx , [si]
              
              mov eax , [di]
              push bp
              lea si , pushToMult1
              mov [si] , eax
              push si
              lea si , coscalcsum
              push si
              call mulFixed
              
              pop bp
              lea si , mulFixedHelper
              mov eax , [si]
              
              add ebx , eax
              mov [di] , ebx
              
              inc cx
              jmp keepEastering 
              
        doneEaster:
        popad 
        ret
    endp
    
        
    ; ********** ;
    ; START MENU ;
    ; ********** ; 
    
    drawMenuBox proc
        ; draws the menu cube
        mov bp , sp
        ; bp + 2 - inner color
        ; bp + 4 - outer color edges
        pushad
        mov cx , 80       
        drawEdge1:
        cmp cx , 76
        jz goDrawUpperEdge
        dec cx
        mov dx , 60
        drawEdge:
        cmp dx , 29
        jz drawEdge1
        mov ax , [bp+4]
        push bp
        push ax
        push cx
        push dx
        call drawFaster
        pop bp
        dec dx
        jmp drawEdge
        
        goDrawUpperEdge:
        inc dx
        goDrawUpperEdge1:
        cmp dx , 26
        jz goDrawOtherEdge
        mov cx , 76
        dec dx
        drawEdge4:
        cmp cx , 100
        jz godrawUpperEdge1
        mov ax , [bp + 4]  
        push bp
        push ax
        push cx
        push dx
        call drawFaster
        pop bp
        inc cx
        jmp drawEdge4
        ; stop drawing top left edge
        ; start drawing top right edge
        goDrawOtherEdge:
        
        mov cx , 239       
        drawEdge2:
        cmp cx , 243
        jz goDrawUpperEdge2
        inc cx
        mov dx , 60
        drawEdge3:
        cmp dx , 29
        jz drawEdge2
        mov ax , [bp + 4]
        push bp
        push ax
        push cx
        push dx
        call drawFaster
        pop bp
        dec dx
        jmp drawEdge3 
        
        goDrawUpperEdge2:
        inc dx
        goDrawUpperEdge3:
        
        cmp dx , 26
        jz goDrawOtherEdge1
        mov cx , 220
        dec dx
        drawEdge5:
        cmp cx , 244
        jz godrawUpperEdge3
        mov ax , [bp + 4]   
        push bp
        push ax
        push cx
        push dx
        call drawFaster
        pop bp
        inc cx
        jmp drawEdge5
        
        ; stop drawing top right edge
        ; draw bottom left edge
        goDrawOtherEdge1:
        
        mov cx , 80
        mov dx , 175
        
        drawEdge6:
        cmp cx , 76
        jz goDrawUpperEdge4
        dec cx
        mov dx , 150
        drawEdge7:
        cmp dx , 181
        jz drawEdge6
        mov ax , [bp + 4]
        push bp
        push ax
        push cx
        push dx
        call drawFaster 
        pop bp
        inc dx
        jmp drawEdge7
        goDrawUpperEdge4:
        dec dx       
        goDrawUpperEdge5:
        cmp dx , 184
        jz goDrawOtherEdge2
        mov cx , 76 
        inc dx
        drawEdge8:
        cmp cx , 100
        jz goDrawUpperEdge5
        mov ax , [bp + 4]
        push bp
        
        push ax
        push cx
        push dx
        call drawFaster
        pop bp
        inc cx
        jmp drawEdge8
        
        ; end drawing bottom left edge
        ; draw bottom right edge
        goDrawOtherEdge2:
        
        mov cx , 244
        mov dx , 175
        
        drawEdge9:
        cmp cx , 240
        jz goDrawUpperEdge6
        dec cx
        mov dx , 150
        drawEdge10:
        cmp dx , 181
        jz drawEdge9
        push bp
        
        mov ax , [bp + 4]
        push ax
        push cx
        push dx
        call drawFaster
        pop bp
        inc dx
        jmp drawEdge10 
         
        goDrawUpperEdge6:
        dec dx       
        goDrawUpperEdge7:
        cmp dx , 184
        jz goDrawCubeNow
        mov cx , 221 
        inc dx
        drawEdge11:
        cmp cx , 244
        jz goDrawUpperEdge7
        mov ax , [bp + 4] 
        push bp
        
        push ax
        push cx
        push dx
        call drawFaster
        pop bp
        inc cx
        jmp drawEdge11
        ; end bottom right edge
        ; draw the inner side of the menu 
        goDrawCubeNow:
        mov cx , 80
        mov dx , 30
        drawRow:
        cmp cx , 240
        jz moveCol
        push bp
        
        mov ax , [bp + 2]
        push ax
        push cx
        push dx
        call drawFaster
        pop bp
        inc cx
        jmp drawRow
        moveCol:
        cmp dx , 181
        jz donePainting
        mov cx , 80
        inc dx
        push bp
        
        mov ax , [bp + 2]
        push ax
        push cx
        push dx
        call drawFaster
        pop bp
        jmp drawRow
        DonePainting:
        popad
        ret 4
    endp  
    
    getShape proc     
        ; draws the selections menu 
        ; starts with the program
        ; start drawing top left edge
        pushad
        lea si , selectedOption
        mov bx , 0
        mov [si] , bx
        lea si , selectedOptionShapes
        mov [si] , bx
        ; draw the box of the menu
        mov ax , 111
        push ax
        mov ax , 12
        push ax
        call drawmenubox
        
        showOptions:
        ; draw the text pyramid
        mov ax , @data
        mov es , ax
        mov ah , 13h
        mov al , 1
        mov bx , 0
        ;lea si , selectedOption
        ;mov bx , [si]
        ;cmp bx , 0
        ;jnz doWhite1
        ;mov bl , 28
        ;jmp skipSelected1
        ;doWhite1:
        mov bl , 30    
        ;skipSelected1:
        mov cx , 4
        mov dh ,85
        mov dl , 154
        lea bp , menuTextCube
        int 10h 
        
        
         ; checks if the option is selected
        ; if it's selected, draw an arrow to its left
        lea si , selectedOption
        mov bx , [si]
        cmp bx , 0
        jnz notSelectedShapePyr0
        
        mov ax , @data
        mov es , ax
        mov ah , 13h
        mov al , 1
        mov bx , 0
        mov bl , 16
        mov cx , 1
        mov dh , 85
        mov dl , 152
        lea bp , menuFocused
        int 10h            
        
        jmp dontDrawOverTheArrow0
        notSelectedShapePyr0:     
        ; if it's not selected, look
        ; for an arrow to its left
        ; and if there is, delete it
        mov dx , 60
        mov cx , 125
        keepDrawingOver0:
        cmp dx , 80
        jz dontDrawOverTheArrow0
        mov cx , 125
        inc dx
        KeepDrawingRowOver0:
        cmp cx , 140
        jz keepDrawingOver0
        mov ah , 0Dh
        mov bh , 0
        int 10h
        cmp al, 16
        jnz notArrowColor0
        mov ax , 12
        push ax
        push cx
        push dx
        call drawFaster
        notArrowColor0: 
        inc cx
        jmp keepDrawingRowOver0
        dontDrawOverTheArrow0:
        
        ; draw the text's background
        mov dx , 65
        mov cx , 100
        keepDrawOption:
        cmp dx , 80
        jz firstOptionDone
        inc dx       
        mov cx , 100
        drawOptionRow:
        cmp cx , 180
        jz keepDrawOption
        mov ah , 0Dh
        mov bh , 0
        int 10h
        cmp al , 0
        jnz dontDraw
        mov ax , 12         
        push ax
        push cx
        push dx
        call drawFaster
        dontDraw:
        inc cx
        jmp drawOptionRow
        
        firstOptionDone:  
        ; draw the text pyramid
        mov ax , @data
        mov es , ax
        mov ah , 13h
        mov al , 1
        lea si , selectedOption
        ;mov bx , [si]
        ;cmp bx , 1
        ;jnz doWhite
        ;mov bl , 28
        ;jmp skipSelected
        ;doWhite:
        mov bl , 30    
        ;skipSelected:
        mov bh , 0
        mov cx , 7
        mov dh ,88
        mov dl , 153
        lea bp , menuTextPyramid
        int 10h
        
        lea si , selectedOption
        mov bx , [si]
        cmp bx , 1
        jnz notSelectedShapePyr
        
        mov ax , @data
        mov es , ax
        mov ah , 13h
        mov al , 1
        mov bx , 0
        mov bl , 16
        mov cx , 1
        mov dh , 88
        mov dl , 150
        lea bp , menuFocused
        int 10h 
        jmp dontDrawOverTheArrow
        notSelectedShapePyr:     
        
        mov dx , 90
        mov cx , 110
        keepDrawingOver:
        cmp dx , 100
        jz dontDrawOverTheArrow
        mov cx , 110
        inc dx
        KeepDrawingRowOver:
        cmp cx , 120
        jz keepDrawingOver
        mov ah , 0Dh
        mov bh , 0
        int 10h
        cmp al, 16
        jnz notArrowColor
        mov ax , 12
        push ax
        push cx
        push dx
        call drawFaster
        notArrowColor: 
        inc cx
        jmp keepDrawingRowOver
        dontDrawOverTheArrow: 
        ; draw the background of the text
        mov dx , 90
        mov cx , 100
        keepDrawOption1:
        cmp dx , 110
        jz secondOptionDone
        inc dx       
        mov cx , 100
        drawOptionRow1:
        cmp cx , 200
        jz keepDrawOption1
        mov ah , 0Dh
        mov bh , 0
        int 10h
        cmp al , 0
        jnz dontDraw1
        mov ax , 12         
        push ax
        push cx
        push dx
        call drawFaster
        dontDraw1:
        inc cx
        jmp drawOptionRow1
        
        secondOptionDone:

        mov ax , @data
        mov es , ax
        mov ah , 13h
        mov al , 1
        mov bh , 0
     
        mov bl , 30    
        mov cx , 3
        mov dh ,94
        mov dl , 154
        lea bp , menuTextGuide
        int 10h 
        
        
        mov ax , @data
        mov es , ax
        mov ah , 13h
        mov al , 1
        mov bh , 0
     
        mov bl , 30    
        mov cx , 5
        mov dh ,96
        mov dl , 153
        lea bp , menuTextGuideEnter
        int 10h 
        
        
        checkForSelect:
           mov ax , 2
           int 33h
           mov ah , 1
           int 16h
           push ax
           mov ah , 0ch
           int 21h
           pop ax   
           cmp ah , 1Ch ; checking if enter is pressed
           jz gotoNextMenu
           cmp ah , 50h ; checking if down arrow is pressed
           jz selectDown
           cmp ah , 48h ; checking if up arrow is pressed
           jz selectUp
           jmp checkForSelect
        
        selectDown:
        lea si , selectedoption
        mov bx , [si]
        lea si , maxoptions
        mov ax , [si]
        dec ax 
        cmp bx ,ax
        jz checkforselect
        lea si , selectedoption
        inc bx
        mov [si] , bx
        
        jmp showoptions
        
        selectUp:
        lea si , selectedoption
        mov bx , [si] 
        cmp bx ,0
        jz checkforselect
        lea si , selectedoption
        dec bx
        mov [si] , bx
        
        jmp showoptions
        
        goToNextMenu:
        
        lea si , selectedoption
        mov bx , [si]
        lea si , selectedoptionshapes
        mov [si] , bx
        popad
        ret
    endp
        
    getFeatures proc 
        ; draws the selections menu 
        ; starts with the program
        ; start drawing top left edge
        pushad
        
        xor eax , eax
        xor ebx , ebx
        xor ecx , ecx
        xor edx , edx
        lea si , selectedoption
        mov ax , 0
        mov [si] , ax
        lea si , menutext2actangle
        mov ax, 0
        mov [si] , ax
        call updateAngle
        
        lea si , colorOfChoice
        mov al , 1
        mov [si] , al
        
        RenderoptionsAngle:
            mov ax , 111
            push ax
            
            mov ax , 12
            push ax
            call drawmenubox
            
            drawCalcAngleOption:
                ; drawing the angle's text
                
                ; checking if the angle given
                ; is not 0
                ; if it is, just draw the text "Angle"
                mov ax , @data
                mov es , ax
                mov ah , 13h
                mov al , 1
                mov bx , 0
                mov bl , 30
                mov cx , 12
                mov dh , 85
                mov dl , 150
                lea bp , menuText2GuideTab
                int 10h      
                
                mov ax , @data
                mov es , ax
                mov ah , 13h
                mov al , 1
                mov bx , 0
                mov bl , 30
                mov cx , 5
                mov dh , 5
                mov dl , 138
                lea bp , menuTextGuideEnter
                int 10h      
                
                mov ax , @data
                mov es , ax
                mov ah , 13h
                mov al , 1
                mov bx , 0
                mov bl , 30
                mov cx , 18
                mov dh , 87
                mov dl , 147
                lea bp , menuText2GuideAngle
                int 10h      
                
                lea si , menutext2actangle
                mov ax, [si] 
                cmp ax , 0
                jnz drawAngle
                    mov ax , @data
                    mov es , ax
                    ; bl - color
                    ; cx - how many characters to print
                    ; dl - cx
                    ; dh - dx
                    ; bp - the pointer to the variable
                    mov ah , 13h
                    mov al , 1
                    mov bx , 0
                    mov bl , 30
                    mov cx , 5
                    mov dh ,90
                    mov dl , 154
                    lea bp , menuText2Angle
                    int 10h
                    jmp dontDrawAngle2
                drawAngle: 
                ; drawing the angle 
                ; bl - color
                ; cx - how many characters to print
                ; dl - cx
                ; dh - dx
                ; bp - the pointer to the variable        
                mov ax , @data
                mov es , ax
                mov ah , 13h
                mov al , 1
                mov bx , 0
                mov bl , 30
                mov cx , 5
                mov dh ,90
                mov dl , 154
                lea bp , menuText2printangle
                int 10h
                
                dontDrawAngle2:
                ; drawing the box that the option 
                ; is on
                mov dx , 100
                mov cx , 100
                keepDrawOptionAngle:
                cmp dx , 120
                
                jz firstOptionDoneFeatures
                inc dx       
                mov cx , 100
                drawOptionRowAngle:
                cmp cx , 200
                jz keepDrawOptionAngle
                mov ah , 0Dh
                mov bh , 0
                int 10h
                cmp al , 0
                jnz dontDrawAngle 
                lea si , selectedoption
                mov bx , [si]
                cmp bx , 0
                jnz notSelectedAngle
                mov ax , 8        
                jmp drawItAngle
                notSelectedAngle:
                mov ax , 29
                drawItAngle: 
                push ax
                push cx
                push dx
                call drawFaster
                dontDrawAngle:
                inc cx
                jmp drawOptionRowAngle
            
            firstOptionDoneFeatures:
                mov ax , @data
                mov es , ax
                mov ah , 13h
                mov al , 1
                mov bx , 0
                mov bl , 30
                mov cx , 16
                mov dh , 93
                mov dl , 148
                lea bp , menuText2GuideColor
                int 10h
                ; drawing the colored box
                mov dx , 160
                mov cx , 140
                lea si , colorOfChoice
                mov al , [si]
                mov ah , 0
                drawTheColorBox: 
                cmp cx , 181
                jz drawTheColorCol
                push ax
                push cx
                push dx
                call drawFaster
                inc cx
                jmp drawthecolorbox                
                drawTheColorCol:
                cmp dx , 170
                jz finishedTheBox
                inc dx
                mov cx , 140
                jmp drawTheColorBox
                
                finishedTheBox:
                ; check if the color is selected
                ; if the color is selected
                ; draw a box around the color
                ; else, wait for a key
                lea si , selectedoption
                mov ax , selectedoption
                cmp ax , 1
                jnz isNotSelectedColor
                mov dx , 159
                mov cx , 139
                mov ax , 0 
                ; draw the top stick
                ; above the colored box
                drawStickLoop:
                cmp cx , 182
                jz drawStick2
                push ax
                push cx
                push dx
                call drawfaster                
                inc cx
                jmp drawstickLoop 
                ; draw the stick to left
                ; of the colored box
                drawStick2:
                mov dx , 160
                mov cx , 139
                mov ax , 0
                drawStick2Loop:  
                cmp dx , 171
                jz drawStick3
                push ax
                push cx
                push dx
                call drawfaster
                inc dx
                jmp drawstick2loop  
                ; draw the stick to the bottom of the
                ; colored box
                drawStick3:
                mov dx , 170
                mov cx , 140
                mov ax , 0
                drawStick3Loop:
                cmp cx , 182
                jz drawStick4
                push ax
                push cx
                push dx
                call drawfaster
                inc cx
                jmp drawstick3loop 
                ; draw the stick to the right
                ; of the colored box
                drawStick4:
                mov dx , 160
                mov cx , 181
                mov ax , 0 
                drawStick4Loop:
                cmp dx , 171
                jz donePaintingAroundBox
                push ax
                push cx
                push dx
                call drawfaster
                inc dx
                jmp drawStick4Loop
                donePaintingAroundBox:
                isNotSelectedColor:
                
        getOptionNow: 
            ; getting an input from the user, and using it
            ; to change the options
            
            ; checking if the user wants 
            ; to check a different option
            mov ax , 1
            int 16h
            mov bx , ax 
            lea si , selectedoption
            mov ax , [si]        
            ; checking if the user pressed enter
            ; if he did, end the selections menu
            cmp bl , 0Dh
            jnz notWantEndMenu2
            jmp goToProgramWithOptions 
            ; checking if the user pressed tab
            ; if yes, select the other option
            notWantEndMenu2:
            cmp bl , 9
            jnz notTab
            lea si , selectedoption
            mov ax , 1
            mov cx , [si]
            lea si , menu2maxoptions
            mov ax , [si]
            dec ax
            ; checking if the current option's index
            ; is equal to the max options' index
            ; cx current option index, ax max options index
            cmp cx , ax
            jnz justAdd
            mov cx , 0
            jmp finishingTabbing
            justAdd:
            inc cx                 
            finishingTabbing:
            lea si , selectedoption
            mov [si] , cx
            jmp RenderoptionsAngle
            notTab:
            
            cmp ax , 0
            jnz notSelectedAngleMenu2
            checkForNumbers:
                cmp bl , 30h ; check if input is 0
                    jnz isNotZero
                    ; getting the current angle 
                    ; selected in the menu
                    lea si , menutext2actangle
                    mov ax , [si]
                    mov bx , 10000
                    mov dx , 0
                    div bx 
                    ; checking if the angle
                    ; is bigger than 9999
                    cmp ax , 0
                    jnz isnotzero
                    ; adding the desired number
                    ; to the angle
                    mov ax , [si]
                    mov bx , 10
                    mul bx
                    cmp dx , 0
                    jnz tooBigNumber0
                    mov [si] , ax 
                    ; updating the printed angle 
                    call updateAngle
                    
                    tooBigNumber0:
                    
                    jmp RenderoptionsAngle
                    isNotZero: 
                cmp bl , 31h ; check if input is 1
                    jnz isNotOne
                    lea si , menutext2actangle
                    mov ax , [si]
                    mov bx , 10000
                    mov dx , 0
                    div bx  
                    ; checking if the angle
                    ; is bigger than 9999
                    cmp ax , 0
                    jnz isnotone
                    mov ax , [si]
                    mov bx , 10
                    mul bx           
                    
                    cmp dx , 0
                    jnz tooBigNumber1
                    ; adding the desired number
                    ; to the angle
                    add ax , 1
                    mov [si] , ax 
                     ; updating the printed angle 
                    call updateAngle 
                    
                    tooBigNumber1:
                    
                    jmp RenderoptionsAngle
                    isNotOne: 
                cmp bl , 32h
                    jnz isNotTwo
                    lea si , menutext2actangle
                    mov ax , [si]
                    mov bx , 10000
                    mov dx , 0
                    div bx    
                    ; checking if the angle
                    ; is bigger than 9999
                    cmp ax , 0  
                    jnz isnottwo
                    mov ax , [si]
                    mov bx , 10
                    mul bx    
                    cmp dx , 0
                    jnz tooBigNumber2   
                    ; adding the desired number
                    ; to the angle
                    add ax , 2
                    mov [si] , ax   
                     ; updating the printed angle 
                    call updateAngle 
                    tooBigNumber2: 
                    jmp RenderoptionsAngle
                    isNottwo:
                cmp bl , 33h
                    jnz isNotThree
                    lea si , menutext2actangle
                    mov ax , [si]
                    mov bx , 10000
                    mov dx , 0
                    div bx     
                    ; checking if the angle
                    ; is bigger than 9999
                    cmp ax , 0
                    jnz isnotthree
                    mov ax , [si]
                    mov bx , 10
                    mul bx
                    cmp dx , 0
                    jnz tooBigNumber3 
                    ; adding the desired number
                    ; to the angle
                    add ax , 3
                    mov [si] , ax   
                     ; updating the printed angle 
                    call updateAngle 
                    tooBigNumber3:
                    jmp RenderoptionsAngle
                    isNotthree:
                cmp bl , 34h
                    jnz isNotfour
                    lea si , menutext2actangle
                    mov ax , [si]
                    mov bx , 10000
                    mov dx , 0
                    div bx    
                    ; checking if the angle
                    ; is bigger than 9999
                    cmp ax , 0
                    jnz isnotfour
                    mov ax , [si]
                    mov bx , 10
                    mul bx 
                    cmp dx , 0
                    jnz tooBigNumber4
                    ; adding the desired number
                    ; to the angle
                    add ax , 4
                    mov [si] , ax 
                     ; updating the printed angle 
                    call updateAngle 
                    tooBigNumber4:
                    jmp RenderoptionsAngle
                    isNotfour:
                cmp bl , 35h
                    jnz isNotfive
                    lea si , menutext2actangle
                    mov ax , [si]
                    mov bx , 10000
                    mov dx , 0
                    div bx     
                    ; checking if the angle
                    ; is bigger than 9999
                    cmp ax , 0
                    jnz isnotfive
                    mov ax , [si]
                    mov bx , 10
                    mul bx  
                    cmp dx , 0
                    jnz tooBigNumber5
                    ; adding the desired number
                    ; to the angle
                    add ax , 5
                    mov [si] , ax
                     ; updating the printed angle 
                    call updateAngle 
                    tooBigNumber5:
                    jmp RenderoptionsAngle
                    isNotfive:
                 cmp bl , 36h
                    jnz isNotsix
                    lea si , menutext2actangle
                    mov ax , [si]
                    mov bx , 10000
                    mov dx , 0
                    div bx   
                    ; checking if the angle
                    ; is bigger than 9999
                    cmp ax , 0
                    jnz isnotsix
                    mov ax , [si]
                    mov bx , 10
                    mul bx       
                    cmp dx , 0
                    jnz tooBigNumber6 
                    ; adding the desired number
                    ; to the angle
                    add ax , 6
                    mov [si] , ax   
                     ; updating the printed angle 
                    call updateAngle 
                    tooBigNumber6:
                    jmp RenderoptionsAngle
                    isNotsix:
                 cmp bl , 37h
                    jnz isNotseven
                    lea si , menutext2actangle
                    mov ax , [si]
                    mov bx , 10000
                    mov dx , 0
                    div bx     
                    ; checking if the angle
                    ; is bigger than 9999
                    cmp ax , 0
                    jnz isnotseven
                    mov ax , [si]
                    mov bx , 10
                    mul bx
                    cmp dx , 0
                    jnz tooBigNumber7 
                    ; adding the desired number
                    ; to the angle
                    add ax , 7
                    mov [si] , ax  
                     ; updating the printed angle 
                    call updateAngle 
                    tooBigNumber7:
                    jmp RenderoptionsAngle
                    isNotseven:
                 cmp bl , 38h
                    jnz isNoteight
                    lea si , menutext2actangle
                    mov ax , [si]
                    mov bx , 10000
                    mov dx , 0
                    div bx   
                    ; checking if the angle
                    ; is bigger than 9999
                    cmp ax , 0
                    jnz isnoteight
                    mov ax , [si]
                    mov bx , 10
                    mul bx       
                    cmp dx , 0
                    jnz tooBigNumber8    
                    ; adding the desired number
                    ; to the angle
                    add ax , 8
                    mov [si] , ax  
                     ; updating the printed angle 
                    call updateAngle 
                    tooBigNumber8:
                    jmp RenderoptionsAngle
                    isNoteight:
                 cmp bl , 39h
                    jnz isNotnine
                    lea si , menutext2actangle
                    mov ax , [si]
                    mov bx , 10000
                    mov dx , 0
                    div bx    
                    ; checking if the angle
                    ; is bigger than 9999
                    cmp ax , 0
                    jnz isnotnine
                    mov ax , [si]
                    mov bx , 10
                    mul bx      
                    cmp dx , 0
                    jnz tooBigNumber9  
                    ; adding the desired number
                    ; to the angle
                    add ax , 9
                    mov [si] , ax  
                     ; updating the printed angle 
                    call updateAngle 
                    tooBigNumber9:
                    jmp RenderoptionsAngle
                    isNotnine:
                cmp bl , 8 ; checking if it's backspace
                jnz notDelete
                lea si , menutext2actangle             
                ; divide the angle by 10,
                ; in order to remove the last number
                mov ax , [si]
                mov bx , 10
                mov dx , 0
                div bx
                mov [si] , ax 
                 ; updating the printed angle 
                call updateAngle 
                
                jmp RenderoptionsAngle
                
                notDelete:
            notSelectedAngleMenu2:      
            cmp ax , 1
            jnz getOptionNow
            ; checking if the user 
            ; is pressing the up arrow
            ; if they are, change the color of the box
            cmp bh , 48h                          
            jnz notUpKeyMenu2 
            lea si , colorOfChoice
            mov al , [si]
            ; checking if al is in its max value
            ; and if it is, not adding anything to it         
            cmp al , 255
            jz getOptionNow
            inc al
            mov [si] , al
            jmp RenderoptionsAngle
            notUpKeyMenu2: 
            cmp bh , 50h
            jnz getOptionNow
            lea si , colorOfChoice
            mov al , [si]
            ; checking if al is in its max value
            ; and if it is, not adding anything to it         
            cmp al , 1
            jz getOptionNow
            dec al
            mov [si] , al 
            jmp RenderoptionsAngle  
            
            
        goToProgramWithOptions:
        popad
        ret
    endp
      
      
    updateAngle proc
        ; updates the printed angle
        ; and changes its ascii 
        pushad
        lea si , menutext2actangle
        lea di , menutext2printangle
        mov dx , 0
        mov ax , [si]
        mov bx , 10000
        div bx
        
        add ax , 30h
        mov [di] , al
        inc di
        
        mov ax , dx
        mov dx , 0
        mov bx , 1000
        div bx
        
        add ax , 30h
        mov [di] , al
        inc si 
        inc di
        
        mov ax , dx
        mov dx , 0
        mov bx , 100
        div bx
        
        add ax , 30h
        mov [di] , al
        inc si 
        inc di
        
        mov ax , dx
        mov dx , 0
        mov bx , 10
        div bx
        
        add ax , 30h
        mov [di] , al
        inc si 
        inc di
        
        mov ax , dx
        
        add ax , 30h
        mov [di] , al
        inc si 
        inc di
        
        popad
        ret
    endp  
    
    ; ********** ;
    ; END MENU ;
    ; ********** ;
   
    ; ************* ;
    ; start pyramid ;
    ; ************* ;
    
    drawPyramid proc
        ; bp + 2 - color to paint the pyramid by
        mov bp , sp
        pushad
        lea di , currentPos
        mov ax , 100
        mov [di] , ax
        add di , 2
        mov ax,  160
        mov [di] , ax
        
        lea di , tempPos
        mov ax ,100
        mov [di] , ax
        add di , 2
        mov ax , 160
        mov [di] , ax
        
        ; apex
        
        push bp
        mov ax , [bp + 2]
        push ax
        
        lea di , tempPos
        push di
        
        lea di , vector8
        push di
        
        call drawvecsnew
        pop bp
        
        ; base
        
        push bp 
        
        mov ax , [bp + 2]
        push ax
        
        lea di , currentpos
        push di
        
        lea di , vector4
        push di
        call drawvecsnew
        
        pop bp
        
        ; change position
        lea di , currentPos
        mov ax , [di]
        lea di , tempPos
        mov [di] , ax
        
        lea di , currentPos
        add di , 2
        mov ax , [di]
        lea di , tempPos
        add di , 2
        mov [di] , ax
        ; end change pos
        
        ; apex
        push bp
        mov ax , [bp + 2]
        push ax
        
        lea di , tempPos
        push di
        
        lea di , vector7
        push di
        
        call drawvecsnew
        pop bp
        
        ; base 
        push bp 
        
        mov ax , [bp + 2]
        push ax
        
        lea di , currentpos
        push di
        
        lea di , vector3
        push di
        call drawvecsnew
        
        pop bp 
        
        ; change position
        lea di , currentPos
        mov ax , [di]
        lea di , tempPos
        mov [di] , ax
        
        lea di , currentPos
        add di , 2
        mov ax , [di]
        lea di , tempPos
        add di , 2
        mov [di] , ax
        ; end change pos
        
        ; apex
        push bp
        mov ax , [bp + 2]
        push ax
        
        lea di , tempPos
        push di
        
        lea di , vector5
        push di
        
        call drawvecsnew
        
        pop bp          
        
        ; base
        push bp 
        
        mov ax , [bp + 2]
        push ax
        
        lea di , currentpos
        push di
        
        lea di , vector2
        push di
        call drawvecsnew
        
        pop bp
        
         ; change position
        lea di , currentPos
        mov ax , [di]
        lea di , tempPos
        mov [di] , ax
        
        lea di , currentPos
        add di , 2
        mov ax , [di]
        lea di , tempPos
        add di , 2
        mov [di] , ax
        ; end change pos
        
        ;apex
        push bp
        mov ax , [bp + 2]
        push ax
        
        lea di , tempPos
        push di
        
        lea di , vector6
        push di
        
        call drawvecsnew
        
        pop bp
        
        ; base
        push bp 
        
        mov ax , [bp + 2]
        push ax
        
        lea di , currentpos
        push di
        
        lea di , vector1
        push di
        call drawvecsnew
        pop bp
        
    
        popad 
        ret 2
    endp 
    resetVectors proc
      ; resets the vectors' components
       xor eax , eax
      lea di , Vector1
      resetAllVecs:  
         
          cmp [di] , "$"
          jz doneSpinningResetting
          mov [di] , eax
          add di , 4
          mov [di] , eax
          add di , 4
          mov [di] , eax
          add di , 4
          jmp resetAllVecs
          
      doneSpinningResetting:
      
      ret  
    endp
    initiatePyramid proc
        ; initiates the pyramid's vectors
        pushad            
        call resetVectors
        xor eax , eax     
        xor ebx , ebx
        xor ecx, ecx
        xor edx , edx
        lea si , len
        mov ax , [si]
        shl eax , 16   
        
        ; vectors that construct the base
        lea di , vector1 ; (0, -len, 0)
        add di , 4
        neg eax
        mov [di] , eax
        lea di , vector2 ; (-len , 0 , 0)
        mov [di] , eax
        neg eax
        lea di , vector3 ; (0 , len , 0)
        add di , 4
        mov [di] , eax
        lea di , vector4 ; (len , 0 , 0)
        mov [di] , eax
        ; the sides that connect the apex ( the top of the pyramid )
        ; to the base ( the lower part of the pyramid ) 
        
        shr eax , 1
        neg eax
        lea di , vector5 ; (-len/2, -len/2, len)
        mov [di] , eax
        add di , 4
        mov [di] , eax
        add di , 4
        neg eax
        shl eax , 1
        mov [di] , eax
        
        lea di , vector6 ; (len/2,-len/2,len)
        shr eax , 1
        mov [di] , eax
        add di , 4
        neg eax
        mov [di] , eax
        add di , 4
        neg eax
        shl eax , 1
        mov [di] , eax
        
        lea di , vector7 ; (-len/2,len/2,len)
        shr eax , 1
        neg eax
        mov [di] , eax
        neg eax
        add di , 4
        mov [di] , eax
        add di , 4
        shl eax , 1
        mov [di] , eax
        
        lea di , vector8 ; (len/2,len/2,len)
        shr eax , 1
        mov [di] , eax
        add di , 4
        mov [di] , eax
        add di , 4
        shl eax , 1                         
        mov [di] , eax                      
        
        popad 
        ret
    endp    
      
      
    ; ************* ;
    ; end pyramid ;
    ; ************* ;
    
    
    ; ************* ;
    ;  start cube   ;
    ; ************* ;
    drawPillarCube proc
        ; bp + 2 - color
        mov bp , sp
        pushad
        lea di , tempPos
    
        lea si , currentPos
        
        mov ax , [si]
        
        mov [di] , ax
        
        add di , 2
        
        add si , 2
        
        mov ax , [si]
        
        mov [di] , ax
        mov ax , [bp + 2]
        push ax
        
        lea bx , tempPos
        push bx
        
        lea bx , Vector5
        push bx
        call drawVecsNew            
        popad
        ret 2
    endp
    
    initiateCube proc
       ; start the vectors with the appropriate cords 
       pushad 
       call resetVectors
       lea si , len 
       mov eax , [si]
       shl eax , 16
       ; initiating the x vector
       ; vectors 1 - 4 are {x , y , 0}
       lea bx , Vector1
       mov [bx] , eax
       ; initializing the vector that comes after the x-axis vector
       lea bx , Vector2
       add bx , 4
       mov [bx] , eax
       
       lea bx , Vector3
                   
       neg eax
       mov [bx] , eax
       
       ; initializing the y vectors
       lea bx , Vector4
       add bx , 4
       mov [bx] , eax
       neg eax
       ; vectors 5 - 8 are the pillars {0 , 0 , z}
       lea bx , Vector5
       add bx , 8
       
       mov [bx] ,eax
      
      
       ; vectors 9 - 12 are above the pillars { x , y , 0}  
       
       ; initializing the vector that comes after the x-axis vector
       ; initializing the y vectors  
       popad
        
       ret
    endp     
    
    drawCube proc             
        ; draws a cube with a given color
        ; bp + 2 - cube color
        mov bp , sp
        pushad
        lea di , currentPos
        mov ax , 100
        mov [di] , ax
        add di , 2
        mov ax,  160
        mov [di] , ax
        
        lea di , tempPos
        mov ax , 100
        mov [di] , ax
        add di , 2
        mov ax , 160
        mov [di] , ax
        
        push bp 
        
        mov ax , [bp + 2]
        push ax
        call drawPillarCube
        
        pop bp 
        
        push bp 

        mov ax , [bp + 2]
        push ax
        
        lea bx , tempPos
        push bx  
        
        
        
        lea bx , Vector1
        push bx
        call drawVecsnew 
        
        pop bp
        
        push bp
        
        mov ax , [bp + 2]
        push ax
        
        
        lea bx , currentPos
        push bx
         
        lea bx , Vector1
        push bx
        
        call drawVecsnew
        pop bp
        push bp 
        
        
        mov ax , [bp + 2]
        push ax
               
        CALL drawPillarCube                            
        pop bp
        push bp 
        
        mov ax , [bp + 2]
        push ax
        
        
        lea bx , tempPos
        push bx
          
        lea bx , Vector2
        push bx
        
        call drawVecsnew
        pop bp
        push bp 
        
        mov ax , [bp + 2]
        push ax
        
        
        lea bx , currentPos
        push bx
                       
        lea bx , Vector2
        push bx
        
        call drawVecsnew  
        pop bp
        push bp 
        
        
        mov ax , [bp + 2]
        push ax              
        CALL drawPillarCube 
        pop bp
        push bp 
        
        mov ax , [bp + 2]
        push ax
        
        
        lea bx , tempPos
        push bx
        
        lea bx , Vector3
        push bx
        
        call drawVecsnew
        pop bp
        push bp 
        
        mov ax , [bp + 2]
        push ax
        
        lea bx , currentPos
        push bx
                           
        lea bx , Vector3
        push bx
        
        call drawVecsnew
        
        pop bp
        push bp 
        
        mov ax , [bp + 2]
        push ax              
        CALL drawPillarCube
        pop bp
        push bp 
              
        
        mov ax , [bp + 2]
        push ax
        
        lea bx , tempPos
        push bx
        
        lea bx , Vector4
        push bx
        
        call drawVecsnew
        pop bp
        push bp 
          
        mov ax , [bp + 2]
        push ax
        
        lea bx , currentPos
        push bx
                        
        lea bx , Vector4
        push bx
        
        call drawVecsnew
        pop bp
        
        popad
        ret 2
    endp
    
    ; ************* ;
    ;   end cube    ;
    ; ************* ;
    
    
     
    waitforArrow proc  
        ; waits for the user to press either the left or right arrows
         pushad
         waitForArrowClick:
            mov ah , 01
            int 16h
            jz waitForArrowClick
            mov ah , 0
            int 16h
            mov bx , ax 
            cmp bh , 50h
            jz pressedDown
            cmp bh , 48h
            jz pressedUp
            cmp bh , 4Bh
            jz pressedLeft
            cmp bh , 4Dh
            jz pressedRight 
            cmp bl , 'r'
            jz goToBeginning 
            cmp bl , 'R'
            jz goToBeginning
            cmp bl , 'c' ; you have found the easter egg!
            jz easterEggKeyPress    
            cmp bl , 'C'
            jz easterEggKeyPress
            jmp waitforarrowclick
        
        pressedDown:
        
        call clrVec
        lea si , calcangle
        mov ax , [si]   
        mov bx , 360
        sub bx , ax
        push bx
        call spinVecHoriz
        jmp clickedItArrow
        pressedUp:
        
        call clrVec
        lea si , calcangle
        mov ax , [si]
        push ax
        call spinVecHoriz
        jmp clickedItArrow
        pressedLeft:
        ; if the user pressed the left arrow
        ; spin the cube to the left side
        call clrVec
        lea si , calcangle
        mov ax , [si]
        mov bx , 360
        sub bx , ax
        push bx
        call spinVec
        
        jmp clickedItArrow
        
        easterEggKeyPress:
        call startMode
        call easterEgg
       
        mov ax , @data
        mov es , ax
        mov ah , 13h
        mov al , 1
        mov bh , 0
        mov bl , 8
        mov cx , 30
        mov dh , 0
        mov dl , 0
        lea bp , foundEasterEgg                
        int 10h  
        
        mov ax , @data
        mov es , ax
        mov al , 1
        mov ah , 13h
        mov bh , 0
        mov bl , 8
        mov cx , 11
        mov dh , 3
        mov dl , 15
        lea bp , simulGuideReturn
        int 10h
                        
        waitForRestart:
            mov ah , 01
            int 16h
            jz waitForRestart
            mov ah , 0
            int 16h
            mov bx , ax
            cmp bl , 'r'
            jz waitforrestartclick 
            cmp bl , 'R'
            jz waitforrestartclick    
            jmp waitforRestart
            
        waitForRestartClick:
        popad
        pop di
        jmp theBeginning
        
        
        pressedRight:
        ; if the user pressed the right arrow
        ; spin the cube to the right side
        call clrVec 
        lea si , calcangle
        mov ax , [si]
        push ax
        call spinVec
        jmp clickedItArrow
        goToBeginning:
        popad
        pop di
        call startMode
        jmp theBeginning
        
        clickedItArrow:
        popad
        ret
    endp
   
    
    
    
    drawFaster proc
        ; bp + 2 - row (dx)
        ; bp + 4 - column (cx)
        ; bp + 6 - color
        mov bp , sp ; changing bp to access the stack segment
        ; pushing the values to not lose them in the process of calling the function
        push ax
        push bx
        push cx
        push dx    
        
        mov ax, 0A000h ; 0A000h is the video memory address (for some video modes like 13h)
        mov ds , ax
        mov ax , [bp + 2] ; getting the row ( Y )
        mov bx , [bp + 4] ; getting the column ( X )
        mov cx , 320 ; multiplying the row by 320 to get the offset, and then adding the column
        mul cx
        
        add ax , bx
        mov di , ax
        mov ax , [bp + 6] ; getting the desired color to paint the pixel in 
        mov [di] , al ; changing the color of the chosen pixel with the desired color
        ; changing the data segment's address back to its original state 
        mov ax , @data
        mov ds, ax      
        
        ; changing the values back to what they were
        pop dx
        pop cx
        pop bx
        pop ax
        ret 6
    endp
        
    clrVec proc 
       ; clears the current shape from the screen
       pushad
       
       lea si , selectedoptionshapes
       mov ax , [si]
       cmp ax , 0
       jnz eraseElse
       mov ax , 0
       push ax
       call drawCube
       jmp finishingErasing
       eraseElse:      
       cmp ax , 1
       jnz eraseOtherShape
       mov ax , 0
       push ax
       call drawPyramid
       jmp finishingErasing
       eraseOtherShape:
       finishingErasing:
       popad 
       ret 
    endp  
    
    startMode proc
        ; initializing the video mode
        push ax
        mov ah , 0
        mov al , 13h
        int 10h
        
        pop ax
        ret
    endp

    addFixed proc 
        ; adds fixed point variables and puts the result in returned 
        mov bp , sp
        pushad
        mov bx , [bp + 2]
        mov di , [bp + 4]
        
        mov eax , [bx]
        mov edx , [di]
        
        
        add eax , edx
        
        
        lea si , returned 
        mov [si] , eax
        
        popad
        ret 4  
        
    endp         
    
    subFixed proc 
       mov bp , sp  
       ; bp + 4 - to sub by y
       ; bp + 2 - subbed  x  
       ; x - y = result
       pushad
       mov bx , [bp + 2]
       mov si , [bp + 4]
       mov eax , [bx]
       mov edx , [si]

       sub eax , edx    

       lea si , returned
       mov [si] , eax
       
       
       popad   
    ret 4    
    endp
    getFactorial proc    
      mov bp , sp
      ; bp + 2 - get the factorial of that number
      pushad
      xor eax , eax
      xor ecx , ecx
      mov ax , [bp + 2]
      mov cx , [bp + 2]
     
      keepMulti:
      cmp cx , 1
      jz exitIt  
      cmp ax , 0
      jz addOne
      dec cx  
      mul cx
                       
      jmp keepMulti
      addOne:
      inc ax
      exitIt:          
      
      lea si , factorialHelper
      mov [si] , eax    
     popad 
    ret 2
    
    endp
    mulFixed proc  
        ; multiplies two fixed point numbers with the 16.16 format 
        mov bp , sp
        pushad
        
        mov bx , [bp + 2]          ; receives an address
        mov si , [bp + 4]          ; receives an address
        mov eax , [bx]
        mov ecx , [si]
        mov edx , 0
       
        imul ecx
        
        lea si , mulFixedHelper   
     
        SHRD EAX , EDX , 16 ; scaling the result back to 16.16 format
        mov [si] , eax
        ; check if it needs rounding
         popad
    ret 4
    endp
           
    mulFixedNum proc
      ; multiplies a fixed point number
      ; with a number number  
        
      mov bp , sp
      pushad
        
      mov bx , [bp + 2]          ; receives an address
      mov si , [bp + 4]          ; receives an address
      mov eax , [bx]
      mov ecx , [si]
      mov edx , 0
       
      mul ecx
        
      lea si , mulFixedHelper   
     
      mov [si] , eax
        ; check if it needs rounding
      popad
      ret 4  
    endp       
    divFixed proc            
         ; bp + 4 - gets divided - is an address
         ; bp + 2 - dividend - is an address
         ; divides two fixed point numbers with the 16.16 format
         
         mov bp , sp
         pushad
         
         mov si , [bp + 4] 
         mov bx , [bp + 2]  
         mov eax , [si]
         mov ecx , [bx]
         mov edx ,eax
         sar EDX , 16
         SHL EAX , 16
         IDIV ecx    

         lea si , divFixedHelper
         mov [si] , eax

         popad     
         ret 4
    endp 
    divFixedNumber proc            
         ; bp + 4 - gets divided - is an address
         ; bp + 2 - dividend - is an address
         ; divides a fixed point number with a real number
         
         mov bp , sp
         pushad
         
         mov si , [bp + 4] 
         mov bx , [bp + 2] 
         mov ecx , [bx]
         mov edx ,0  
         mov eax , [si]
         CDQ
      
         idiv ecx           

         lea si , divFixedHelper
         mov [si] , eax
         
         popad     
         ret 4
    endp 
    
    
    ; ********** ;
    ; START TRIG ; 
    ; ********** ;  
    
    
    degToRadiansCos proc
       ; bp + 2 - the angle to convert to radians
       ; uses Cosine identities to get more accurate results with COS(X) 
       ; r = (degrees * pi) /  180
       mov  bp , sp
       pushad  
       lea si , coscalcsum
       
       xor eax, eax
       mov [si] , eax   
       lea si , cosradsign
       mov [si] , ax 
       xor ebx , ebx
       xor ecx , ecx
       xor edx , edx
        
       mov bx , [bp + 2] ; receives a number
       mov edx , ebx
       mod360:
           cmp edx , 360
           JBE initCosSignRad
           sub edx , 360
           jmp mod360

       initCosSignRad:
       lea di , cosRadSign
       mov ax , 0
       mov [di] , ax
       
       noDecAngle:
           
           cmp edx , 45 ; checking if x <= 45
           JBE dontDo                                              
           cmp edx , 90 ; checking if x > 90
           ja checkFor180Deg
           mov eax , 90 ; using the identity sin(90-x) = cos(x)
           sub eax , edx
           
           push ax
           call degToRadiansSin
           
           lea si , sincalcsum
           mov eax , [si]     
           
           lea si , coscalcsum
           lea di , cosRadSign
           mov dx , 0
           cmp [di], dx
           jz dontDoNegSign
           neg eax
           dontDoNegSign:
           mov [si] , eax
           
           popad
           ret 2
       checkFor180Deg:    
           cmp edx , 180 ; checking if x <= 180 
           
           JA go180    
           ; using the identity -cos(x) = cos(180 - x)
           mov eax , 180
           sub eax , edx
           mov edx , eax
           lea di , cosRadSign
           mov ax , 1     
           sub ax , [di]
           mov [di] , ax ; mov 1 if it's negative
           cmp edx , 45
           ja noDecAngle       
           jmp dontDo
       
       go180:
           cmp edx , 270 ; checking if x <= 270
           JA go360   
           ; using the identity cos(360 - x) = cos(x) = -cos(180 - x)
           mov eax , 180
           sub edx , eax
          
           lea di , cosRadSign
           mov ax , 1   
           sub ax , [di]
           mov [di] , ax 
           cmp edx , 45
           ja noDecAngle
           jmp dontDo
       go360:       
       ; using the identity cos(360 - x) = cos(x)
           mov eax , 360
           sub eax , edx
           mov edx , eax
           cmp edx , 45
           ja noDecAngle

       dontDo:
           ; using the formula to convert from degrees to radians
           ; where X is degrees and r is the radians
           ; r = (X * PI) / 180
           
           ; this part does the (X * PI) part
           lea di , PI
           mov eax , [di] 
           
           lea si , pushToMult1
           mov [si] , eax
           
           lea si , pushToMult2   
           
           mov [si] , edx
           
           lea si , pushToMult1
           push si
           lea si , pushToMult2
           push si
           call mulFixedNum
                 
           ; implementing the / 180 part      
           mov ebx , 180 ; to convert to radians u need to divide by 180 in 16.16 format and multiply by pi
           
           lea di , mulFixedHelper
           
           push di
           
           lea si , pushToDiv1
           mov [si] , ebx
           push si 
           call divFixedNumber
           
           lea di , divFixedHelper
           mov eax , [di] 
           
           
           ; getting the final result 
           lea si , toRadians
           mov [si] , eax
                                  
                                  
           ; pushing the result and getting the cosine of the given angle                       
           push si
           call calcCos
           lea si , coscalcsum
           mov eax , [si]
           
           ; checking if the sin is not negative, if it is transfer the result to a negative result
           ; if the original angle is 220, and the given result is 0.7666, we make it into -0.7666
           lea di , cosRadSign 
           mov dx , [di]
           cmp dx , 0
           jz dontNegIt
           neg eax     
           dontNegIt:
           mov [si] , eax
           
           exceptionGotCos:
               
           popad
       ret 2 
    endp
    
    
    degToRadiansSin proc
       
       ; transfers given angle from degrees to radians, and calculates the sin value of that angle
       
       ; bp + 2 - the angle to convert to radians
       ; uses Sine identities to get more accurate results with SIN(X) 
       
       mov  bp , sp
       pushad
       lea si , sincalcsum      
       xor eax , eax
       mov [si] , eax
       xor ebx , ebx
       xor ecx , ecx
       xor edx , edx
       
        
       mov bx , [bp + 2] ; receives a number
       mov edx , ebx
       
       ; angle mod 360
      
       mod360Sin:
           cmp edx , 360
           JBE initIt
           sub edx , 360
           jmp mod360Sin    
           

       initIt:
               
       lea di , sinRadSign
       mov ax , 0
       mov [di] , ax
       
       noDecAngleSin:  
        
           ; setting the new angle to the angle with the mod on it
           
           
           cmp edx , 45 ; checking if x <= 45
           JBE dontDoSin 
           cmp edx , 90
           ja checkFor180DegSin                                             
           ; using the identity sin(90 - x) = cos(x)
           mov eax , 90
           sub eax , edx
           
           push ax
           call degToRadiansCos
           
           lea si , coscalcsum
           mov eax , [si]
           lea si , sincalcsum 
           lea di , sinRadSign
           mov dx , 0
           cmp [di] , dx
           jz justDoWithNoNeg
           neg eax
           justDoWithNoNeg:
           mov [si] , eax
           
           popad
           ret 2 
       checkFor180DegSin:
           cmp edx , 180 ; checking if x <= 180 
           
           JA go180Sin 
           ; using the identity sin(180 - x ) = sin(x) 
           mov eax , 180
           sub eax , edx
           mov edx , eax       
           cmp edx , 45
           ja noDecAngleSin
           jmp dontDoSin 
           
       go180Sin:  
           
           cmp edx , 270 ; checking if x <= 270
           JA go360Sin
           ; using the identity sin(x - 180) = sin(180 - (x - 180)) = sin(-x) = -sin(x)
           mov eax , 180                     
           sub edx , eax
          
           lea di , sinRadSign
           mov ax , 1      
           sub ax , [di]
           mov [di] , ax 
           cmp edx , 45
           ja noDecAngleSin
           
           jmp dontDoSin    
           
       go360Sin:       
           ; using the identity sin(360 - x) = -sin(x)
           mov eax , 360
           sub eax , edx
           mov edx , eax
           lea di , sinRadSign
           mov ax , 1       
           sub ax , [di]
           mov [di] , ax       
           cmp edx  , 45 
           ja noDecAngleSin
       dontDoSin:        
       
           ; using the formula to convert from degrees to radians
           ; where X is degrees and r is the radians
           ; r = (X * PI) / 180
           
           ; this part does the (X * PI) part
           lea di , PI
           mov eax , [di] 
           
           lea si , pushToMult1
           mov [si] , eax
           
           lea si , pushToMult2   
           
           mov [si] , edx
           
           lea si , pushToMult1
           push si
           lea si , pushToMult2
           push si
           call mulFixedNum
           
           mov ebx , 180 ; to convert to radians u need to divide by 180 in 16.16 format and multiply by pi
           
           lea di , mulFixedHelper
           
           push di
           
           lea si , pushToDiv1
           mov [si] , ebx
           push si 
           call divFixedNumber
           
           lea di , divFixedHelper
           mov eax , [di] 
           
           
           lea si , toRadians
           mov [si] , eax
           
           push si
           call calcSin
           lea si , sincalcsum
           mov eax , [si]
           lea di , sinRadSign
           mov dx , [di]
           cmp dx , 0
           jz dontNegSin
           
           neg eax      
           dontNegSin:
           
           mov [si] , eax
           exceptionGot:
               
       popad
       ret 2 
    endp
    calcCos proc 
        ; TODO - IMPLEMENT NEGATIVE NUMBERS
        ; bp + 2 - the address of angle to calculate
        
        ; calculating sin(x) with taylor's series
        mov bp , sp
        pushad 
        xor ecx , ecx
        xor eax , eax
        xor ebx , ebx
        xor edx , edx
        ; the formula to calculate sin(x) is SIGMA from 1 to infinity
        ; angle^(2n) * (((-1) ^ n) / n ^ (2n))
        keepAddingCos:  ; ax  , bx
            cmp cx , 8
            jae finishedCos ; checking if 6 cycles are finished
            
            mov dx , 0
            
            push cx
            push ax   
            
            xor eax , eax
            mov ax , 1
        powerICos: ; -1 ^ cx  
          ; changing the sign every round    
          cmp cx , 0
          jz goNextPowerCos
          neg ax  
          dec cx
          jmp powerICos
                     
        goNextPowerCos:
        ; the final sign
        mov dx , ax    
        pop ax    
        pop cx    
        
        push si  
        
        ; moving the final sign to the designated variable
        lea si , cosCalcSign
        mov [si] , dx       
        
        pop si
        ; calculating the angle on the top of the equation ( the dividend )
        
        push ax
        push cx
        
        ; calculating the amount of cycles need to multiply the angle by itself       
        ; resetting ecx and eax
        xor eax , eax  
        shl ecx , 24
        shr ecx , 24 
        mov ch , 0
        add cl , cl
        
        
        mov si , [bp + 2] ; getting the angle
        lea di , PushToMult2
        mov ebx , [si]
        mov [di] , ebx 
                         
                         
        ; putting the angle in ebx (before we put it in ebx, we need to put it in bx, because it's an address)  
        xor ebx , ebx
        mov si , [bp + 2]
        mov ebx , [si]
        lea si , PushToMult1
        
        ; ending the calculations
        ; now the number of cycles is in cx
        ; the angle is in edx
        cmp cl , 0
        jz putOneCos
        multPowerAngleCos:
            ; multiplying the angle by itself cx times
            cmp cx , 1
            jz finishPowerCos   
            ; multiplying by the result of the previous multiplication
            mov [si] , ebx
            ; multiplying the angle by the result of the previous angle multiplication 
            push bp
            
            push si      
            push di  
            call mulFixed
            
            pop bp     
            ; getting the result of the multiplication
            lea bx , mulFixedHelper
            mov ebx , [bx]                            
            ; decreasing the amount of rounds to multiply by
            dec cx
            jmp multPowerAngleCos                                   
        
        putOneCos:
            mov ebx , 10000000000000000b ; angle ^ 0 == 1                 
        finishPowerCos:
            pop cx
            pop ax
            
            push si
            push cx   
            ; putting the value of the multiplied angle in sinCalcAngle
            lea si , cosCalcAngle
            mov [si] , ebx
            ; multiplying cx by 2 and adding one to the result to get the bottom part of the formula
            add cx , cx   
            push bp
            
            push cx
            call getFactorial 
            pop bp
            ; getting the result from the factorial function
            lea di , factorialHelper  
            mov eax , [di]            
            ; putting the result of the factorial in sinCalcFactorial
            lea si , cosCalcFactorial 
            mov [si] , eax 
            pop cx
            pop si
            ; now calculating what to add to the sum
            
            ; dividing the angle by the factorial we got earlier
            lea si , factorialHelper
            lea di , coscalcAngle        
            push bp
            
            push di
            push si
            call divFixedNumber
            
            pop bp
            ; getting the result of the division
            lea si , divFixedHelper
            mov eax , [si]
            
            lea di , cosCalcSign
            
            neg eax
            neg eax
            lea si , cosCalcSum
            mov edx , [si]
            
            cmp [di] , 0
            jl DecItCos
            add edx , eax
                        
                        
                        
            jmp addToSumCos
            DecItCos:  
                sub edx , eax
            addToSumCos:
                mov [si] , edx
                          
                inc cx
                jmp keepAddingCos
            finishedCos:
              
        popad
        ret 2
    endp
    calcSin proc                 
        
        ; bp + 2 - the address of angle to calculate
        
        ; calculating sin(x) with taylor's series
        mov bp , sp
        pushad 
        xor ecx , ecx
        xor eax , eax
        xor ebx , ebx
        xor edx , edx
        
        lea di , sincalcsum
        
        mov [di] , eax
        
       
        ; the formula to calculate sin(x) is SIGMA from 1 to infinity
        ; angle^(2n + 1) * (((-1) ^ n) / n ^ (2n + 1))
        keepAdding:  ; ax  , bx
            cmp cx , 7
            jae finished ; checking if 3 cycles are finished
            
            mov dx , 0
            
            push cx
            push ax   
            
            xor eax , eax
            mov ax , 1
        powerI: ; -1 ^ cx  
          ; changing the sign every round    
          cmp cx , 0
          jz goNextPower
          neg ax  
          dec cx
          jmp powerI
                     
        goNextPower:
        ; the final sign
        mov dx , ax    
        
        pop ax    
        pop cx    
        
        push si  
        
        ; moving the final sign to the designated variable
        lea si , sinCalcSign
        mov [si] , dx       
        
        pop si
        ; calculating the angle on the top of the equation ( the dividend )
        
        push ax
        push cx
        
        ; calculating the amount of cycles need to multiply the angle by itself       
        ; resetting ecx and eax
        xor eax , eax
        mov ax , 2   
        shl ecx , 24
        shr ecx , 24
        mul cl
        mov ah , 0
        mov cx , ax 
        
        mov si , [bp + 2] ; getting the angle
        lea di , PushToMult2
        mov ebx , [si]
        mov [di] , ebx 
                         
                         
        ; putting the angle in ebx (before we put it in ebx, we need to put it in bx, because it's an address)  
        xor ebx , ebx
        mov si , [bp + 2]
        mov ebx , [si]
        lea si , PushToMult1
        
        ; ending the calculations
        ; now the number of cycles is in cx
        ; the angle is in edx
        multPowerAngle:
            ; multiplying the angle by itself cx times
            cmp cx , 0
            jz finishPower   
            ; multiplying by the result of the previous multiplication
            mov [si] , ebx
            ; multiplying the angle by the result of the previous angle multiplication 
            push bp
            
            push si      
            push di  
            call mulFixed
            
            pop bp     
            ; getting the result of the multiplication
            lea bx , mulFixedHelper
            mov ebx , [bx]                            
            ; decreasing the amount of rounds to multiply by
            dec cx
            jmp multPowerAngle                                   
                          
        finishPower:                  
            pop cx
            pop ax
        
        goToBot:
    
        
        push si
        push cx   
        ; putting the value of the multiplied angle in sinCalcAngle
        lea si , sinCalcAngle
        mov [si] , ebx
        ; multiplying cx by 2 and adding one to the result to get the bottom part of the formula
        add cx , cx
        inc cx   
        push bp
        
        push cx
        call getFactorial 
        pop bp
        ; getting the result from the factorial function
        lea di , factorialHelper  
        mov eax , [di]            
        ; putting the result of the factorial in sinCalcFactorial
        lea si , sinCalcFactorial 
        mov [si] , eax 
        pop cx
        pop si
         
         
         
        ; now calculating what to add to the sum
        
        ; dividing the angle by the factorial we got earlier
        lea si , factorialHelper
        lea di , sincalcAngle        
        push bp
        
        push di
        push si
        call divFixedNumber
        
        pop bp
        ; getting the result of the division
        lea si , divFixedHelper
        mov eax , [si]
        
        lea di , sinCalcSign
        
        
        lea si , sinCalcSum
        mov edx , [si]
        
        cmp [di] , 0
        jl DecIt
        add edx , eax
                    
                    
                    
        jmp addToSum
        DecIt:
            sub edx , eax
        addToSum:
            mov [si] , edx
                          
            inc cx
            jmp keepAdding
        finished:
          
        popad
        ret 2
    endp
    
    
    
    ; ********** ;
    ;  END TRIG  ; 
    ; ********** ;  
    
    
    drawVecsNew proc 
         ; draws the vector it receives using two points, 
         ; the anchor and the initial point of the vecto,
         ; and uses Bresenham's Line Generation Algorithm to connect them
         ; bp + 2 - address of the vector
         ; bp + 4 - address of the position
         ; bp + 6 - color of the vector
         mov bp , sp
         pushad
         xor eax , eax
         xor ebx , ebx
         xor ecx , ecx
         xor edx , edx

         lea di , len
         mov bl , [di]
                 
     
         
         mov di , [bp + 4]
         mov dx , [di]
         add di , 2
         mov cx , [di]
         
         shl edx , 16
         shl ecx , 16             
         
         ; going to the last point from the beginning point

         mov di , [bp + 2]
         mov eax , [di]
         
         add edx , eax
         sub ecx , eax
         
         add di , 4
         mov eax, [di]
         add ecx , eax
         add ecx , eax
         
         add di , 4
         mov eax, [di]
         sub edx, eax
         sub edx , eax 
          
         gotLastPoint: 

         
         ; end point is now (edx , ecx) = (row, col)
         
         mov di , [bp + 4]
         mov ax , [di]
         add di , 2
         mov bx , [di]
         
         shl eax , 16
         shl ebx , 16
         sub eax , edx
         sub ebx , ecx  
         
         ; checking if eax(dx) is negative, and taking its absolute value
         pushad
         and eax , 10000000000000000000000000000000b
         cmp eax , 10000000000000000000000000000000b
         JNZ rowNotNeg  
         popad
         neg eax
         jmp noPop
         rowNotNeg:
         popad
         
         noPop: 
         
         ; checking if ebx(dy) is negative, and taking its absolute value  
         pushad
         and ebx , 10000000000000000000000000000000b
         cmp ebx , 10000000000000000000000000000000b
         JNZ colNotNeg  
         popad
         neg ebx
         jmp noPopCol
         colNotNeg:
         
         popad
         
         noPopCol:   
         
         ; calculating how many times we need to draw
         ; the vector, and putting that amount in Steps
         lea di , Steps
         
         cmp eax , ebx
         ja rowBigger  
         push bx
         shr ebx , 16
         mov [di] , ebx
         shl ebx , 16
         pop bx
         jmp skipSteps
         rowBigger:   
         push ax
         shr eax , 16
         mov [di] , eax
         shl eax , 16  
         pop ax
         skipSteps:
         
         ; getting the dx and dy again.
         mov di , [bp + 4]
         mov ax , [di]
         add di , 2
         mov bx , [di]
         
         shl eax , 16
         shl ebx , 16
         
         sub eax , edx
         sub ebx , ecx                 
         
         ; diving the dx , dy by the amount of steps
         push bp
         
         ; checking how much to increment the cx(col) value per drawing
         lea si , pushToDiv1
         mov [si] , eax
         push si
         lea si , Steps
         push si
         
         call divFixedNumber
         lea si , divFixedHelper
         mov eax , [si]
         pop bp
         lea si , XIncrement
         mov [si] , eax 
         
         cmp eax , 0
         
         ; checking how much to increment the dx(row) value per drawing
         push bp
         lea si , pushToDiv1
         mov [si] , ebx
         push si     
         lea si , Steps
         push si
         
         call divFixedNumber
         lea si , divFixedHelper
         mov ebx , [si]
         pop bp
         lea si , YIncrement
         mov [si] , ebx 
         push cx
         push dx
         shr ecx , 16
         shr edx , 16
         ; setting the current position to the position
         ; of the end point
         mov si , [bp + 4]
         mov [si] , dx
         add si , 2
         mov [si] , cx
         
         shl ecx , 16
         shl edx , 16
         pop dx
         pop cx
         lea si , Steps
         mov bx , [si] ; assuming Steps isnt more than 2 ^ 8
         ; drawing the vector
         drawIt:
         cmp bl , 0
         jz stopDrawing 
         push dx
         push cx
         
         shr edx , 16
         shr ecx , 16
         cmp dx , 0
         jz stopDrawingWithPop
         cmp cx , 0 
         jz stopDrawingWithPop
         
         push bp
         mov ax , [bp + 6] ; white
         push ax
         push cx
         push dx
         call drawFaster
         pop bp
         shl edx , 16
         shl ecx , 16
         pop cx
         pop dx
         
         ; incrementing dx , cx to draw the point in different places
         lea si , xincrement
         mov eax , [si]
         cmp eax , 0
         JNL addItNow
         neg eax
         sub edx , eax 
         jmp skipAddingIt 
         addItNow:
         add edx , eax 
          
         skipAddingIt:
         
         lea si , yincrement 
         mov eax , [si]
         cmp eax , 0
         JNL addItNowCol
         neg eax
         sub ecx , eax 
         jmp skipAddingItCol 
         addItNowCol:
         add ecx , eax 
          
         skipAddingItCol:
         
         dec bx
         jmp drawIt
         
         stopDrawingWithPop:
         pop cx
         pop dx
         
         stopDrawing:
         
         
         popad
         
         ret 6
    endp
    
    spinVec proc
      ; bp + 2 - the angle (a number) 
      ; to spin the vectors by (in degrees)
 
      mov bp , sp
      pushad
      xor eax , eax
      xor ebx , ebx
      xor ecx , ecx
      xor edx , edx
      
      
      push bp
    
      mov dx , [bp + 2]
      push dx
      call degToRadiansSin
      pop bp
      lea si , sincalcsum
      mov eax , [si] 
       
      push bp
        
      mov dx , [bp + 2]
      push dx
      call degToRadiansCos
      pop bp
      
      lea si , sincalcsum
      mov [si] , eax
      
      lea di , Vector1
      spinAllVecs:  
          xor eax , eax
          xor ebx , ebx
          xor ecx , ecx
          xor edx , edx
          cmp [di] , "$"
          jz doneSpinning
          ; x = x0cos(0) - y0sin(0)
          ; 0 - angle, x - x value of the vector, y0 - old y length, x0 - old x length
          
          mov eax , [di] ; getting the x value of the vector
          add di ,4
          mov edx , [di] ; getting the y value of the vector
          sub di , 4
          
          ; implementing the x0cos(0) part
          push bp
          lea si , pushToMult1
          mov [si] , eax       
          push si
          lea si , coscalcsum
          push si
          
          call mulFixed
          pop bp    
          ; getting the value of x0cos(0)   
          lea si , mulFixedHelper
          mov ebx , [si]
          ; implementing the ysin(0) part
          push bp
          lea si , pushToMult1
          mov [si] , edx  
          push si
          lea si , sincalcsum
          push si
          call mulFixed
          pop bp 
          ; subtracting between the two given values
          lea si , mulFixedHelper
          mov edx , [si]
          sub ebx , edx
          mov [di] , ebx                        
          
          ; y = x0sin(0) + y0cos(0) 
          ; where 
          ; 0 - angle, y - y value of the vector, y0 - old y length, x0 - old x length
          add di , 4
          
          push bp
          lea si , pushToMult1
          mov [si] , eax  
          push si
          lea si , sincalcsum
          push si 
         
          call mulFixed
          pop bp                 
          
          lea si , mulFixedHelper
          mov ebx , [si]
          
          mov eax , [di]
          push bp
          lea si , pushToMult1
          mov [si] , eax
          push si
          lea si , coscalcsum
          push si
          call mulFixed
          
          pop bp
          lea si , mulFixedHelper
          mov eax , [si]
          
          add ebx , eax
          mov [di] , ebx
          
          add di , 8
          jmp spinAllVecs
          
      doneSpinning:
      popad
    ret 2
    endp
    
    
    spinVecHoriz proc
      ; bp + 2 - the angle (a number) 
      ; to spin the vectors by (in degrees)
 
      mov bp , sp
      pushad
      xor eax , eax
      xor ebx , ebx
      xor ecx , ecx
      xor edx , edx
      
      
      push bp
    
      mov dx , [bp + 2]
      push dx
      call degToRadiansSin
      pop bp
      lea si , sincalcsum
      mov eax , [si] 
       
      push bp
        
      mov dx , [bp + 2]
      push dx
      call degToRadiansCos
      pop bp
      
      lea si , sincalcsum
      mov [si] , eax
      
      lea di , Vector1
      spinAllVecsHoriz:  
          xor eax , eax
          xor ebx , ebx
          xor ecx , ecx
          xor edx , edx
          cmp [di] , "$"
          jz doneSpinningHoriz
          ; x = x0cos(0) - z0sin(0)
          ; 0 - angle, x - x value of the vector, z0 - old z length, x0 - old x length
          
          mov eax , [di] ; getting the y value of the vector
          add di ,8
          mov edx , [di] ; getting the z value of the vector
          sub di , 8
          
          ; implementing the x0cos(0) part
          push bp
          lea si , pushToMult1
          mov [si] , eax       
          push si
          lea si , coscalcsum
          push si
          
          call mulFixed
          pop bp    
          ; getting the value of y0cos(0)   
          lea si , mulFixedHelper
          mov ebx , [si]
          ; implementing the zsin(0) part
          push bp
          lea si , pushToMult1
          mov [si] , edx  
          push si
          lea si , sincalcsum
          push si
          call mulFixed
          pop bp 
          ; subtracting between the two given values
          lea si , mulFixedHelper
          mov edx , [si]
          sub ebx , edx
          mov [di] , ebx                        
          
          ; z = x0sin(0) + z0cos(0) 
          ; where 
          ; 0 - angle, z - z value of the vector, z0 - old z length, y0 - old y length
          add di , 8
          
          push bp
          lea si , pushToMult1
          mov [si] , eax  
          push si
          lea si , sincalcsum
          push si 
         
          call mulFixed
          pop bp                 
          
          lea si , mulFixedHelper
          mov ebx , [si]
          
          mov eax , [di]
          push bp
          lea si , pushToMult1
          mov [si] , eax
          push si
          lea si , coscalcsum
          push si
          call mulFixed
          
          pop bp
          lea si , mulFixedHelper
          mov eax , [si]
          
          add ebx , eax
          mov [di] , ebx
          
          add di , 4
          jmp spinAllVecsHoriz
          
      doneSpinningHoriz:
      popad
    ret 2
    endp         
END start ; set entry point and stop the assembler.
