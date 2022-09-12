; System procedures
.export _waitVSync
; Draw procedures
.export _fillScreen
.export _drawRect
; Debug procedures
.export _consoleLogHex
.export _consoleLogWord
.export _consoleLogBinary
.export _consoleLogDecimal
.export _consoleLogChar
.export _consoleLogStr
.export _startStopwatch
.export _stopStopwatch
.export _moveRight
.export _waitStart
.export _waitFrames

.zeropage
VMEM_POINTER: .res 2, $00
DATA_POINTER: .res 2, $00
X_COORD: .res 1, $00
Y_COORD: .res 1, $00
TEMP1: .res 1, $00
TEMP2: .res 1, $00


.segment "CODE"
.PC02

; ----- SYSTEM PROCEDURES ---

.proc _waitVSync: near
    ; Wait for vsync end.
    loop1:
    BIT $DF88
    BVS loop1
    ; Wait for vsync start
    loop2:
    BIT $DF88
    BVC loop2
    RTS
.endproc

.proc _waitStart: near
    wait_loop:
    BIT $df9c
    BVS wait_loop
    RTS
.endproc

.proc _waitFrames: near
    TAX
    wait_vsync_end:
    BIT $DF88
    BVS wait_vsync_end
    wait_vsync_begin:
    BIT $DF88
    BVC wait_vsync_begin   
    DEX
    BNE wait_vsync_end
    RTS
.endproc

; ---- DRAW PROCEDURES ---
.proc _fillScreen: near
    ; Init video pointer
    LDX #$60
    STX VMEM_POINTER+1
    LDY #$00
    STY VMEM_POINTER
    ; Load current color
loop:
    STA (VMEM_POINTER), Y
    INY
    BNE loop
	INC VMEM_POINTER+1
    BPL loop
    RTS
.endproc

.proc _convert_coords_to_mem: near
    ; Calculate Y coord
    STZ VMEM_POINTER
    LDA Y_COORD
    LSR
    ROR VMEM_POINTER
    LSR
    ROR VMEM_POINTER
    ADC #$60
    STA VMEM_POINTER+1
    ; Calculate X coord
    LDA X_COORD
    LSR
    CLC
    ADC VMEM_POINTER
    STA VMEM_POINTER
    BCC skip_upper
    INC VMEM_POINTER+1
    skip_upper:
	RTS
.endproc

.proc _drawRect: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; LDA Y_COORD
    LDY #1
    LDA (DATA_POINTER),y
    STA Y_COORD
        
    ;LDA X_COORD
    LDA (DATA_POINTER)
    STA X_COORD
        
    ; Calculate memory position
	JSR _convert_coords_to_mem
    
    ; Write mem position to struct
    LDA VMEM_POINTER
    LDY #2
    STA (DATA_POINTER),y
    LDA VMEM_POINTER+1
    INY
    STA (DATA_POINTER),y
    
    ; Divide width by 2 and store in temp1
	LDY #5
	LDA (DATA_POINTER), Y
    LSR
    STA TEMP1
	
	; Load height in x
	LDY #6
	LDA (DATA_POINTER), Y
	TAX
    
	; Load color in A
	LDY #4
	LDA (DATA_POINTER), Y
    		
	paint_row:
    LDY TEMP1
	; Draw as many pixels as Y register says
    DEY
	paint:
	STA (VMEM_POINTER), Y
	DEY
	BPL paint

	; Next row
	PHA
    LDA VMEM_POINTER
	CLC
	ADC #$40
	STA VMEM_POINTER
	BCC skip_upper
	INC VMEM_POINTER+1
 	skip_upper:
	PLA
    DEX
	BNE paint_row

	RTS
.endproc

.proc _moveRight: near
	; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; Update VMEM_POINTER
    LDY #2
    LDA (DATA_POINTER), Y
    STA VMEM_POINTER
    INY
    LDA (DATA_POINTER), Y
    STA VMEM_POINTER+1
        
    ; Divide width by 2 and store in temp1
	LDY #5
	LDA (DATA_POINTER), Y
    LSR
    STA TEMP1
            
    ; Store height in X
	LDY #6
	LDA (DATA_POINTER), Y
    TAX
    
    ; Store background color in A
    LDY TEMP1    
    INY
    LDA (VMEM_POINTER), Y
    TAY
                    
    ; Draw left column
    loop:
    TYA
    STA (VMEM_POINTER)
    LDA VMEM_POINTER
    CLC
    ADC #$40
    STA VMEM_POINTER
    BCC skip_upper
    INC VMEM_POINTER+1
    skip_upper:
    DEX
    BNE loop
    
    ; Update X coord
    
    
    ; Update VMEM_POINTER
    LDA VMEM_POINTER
    INA
    LDY #2
    STA (DATA_POINTER), Y    
    
    RTS
.endproc



; ------ DEBUG PROCEDURES

.proc  _consoleLogHex: near
    ; Set virtual serial port in hex mode
    LDX #$00
	STX $df94
    ; Send value to virtual serial port
    STA $df93
    RTS
.endproc

.proc  _consoleLogWord: near
    ; Set virtual serial port in hex mode
    LDY #$00
	STY $df94
    ; Send value to virtual serial port
    STA $df93
    STX $df93
    RTS
.endproc

.proc  _consoleLogBinary: near
    ; Set virtual serial port in hex mode
    LDX #$02
	STX $df94
    ; Send value to virtual serial port
    STA $df93
    RTS
.endproc

.proc  _consoleLogDecimal: near
    ; Set virtual serial port in hex mode
    LDX #$03
	STX $df94
    ; Send value to virtual serial port
    STA $df93
    RTS
.endproc

.proc  _consoleLogChar: near
    ; Set virtual serial port in ascii mode
    LDX #$01
    STX $df94
    ; Send value to virtual serial port
    STA $df93
    RTS
.endproc

.proc  _consoleLogStr: near
    ; Get data pointer from procedure args
    STA DATA_POINTER
    STX DATA_POINTER+1
    ; Set virtual serial port in ascii mode
    LDA #$01
    STA $df94
    ; Iterator
    LDY #$00
    loop:
    LDA (DATA_POINTER),Y
    BEQ end
    STA $df93
    INY
    BNE loop
    end:
    RTS
.endproc

.proc _startStopwatch: near
    LDA #$FB
    STA $DF94
    RTS
.endproc

.proc _stopStopwatch: near
    LDA #$FC
    STA $DF94
    RTS
.endproc
