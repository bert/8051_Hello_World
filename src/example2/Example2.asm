; Turbo51 version 0.1.3.10, Copyright 2000 - 2011 Igor Funa

$REGISTERBANK (0, 1)

_CODE         SEGMENT  CODE
_DATA         SEGMENT  DATA
_BIT          SEGMENT  BIT

              PUBLIC   SCL
              PUBLIC   SDA

              EXTRN    IDATA (StackStart)

; {
;     This file is part of the Turbo51 examples.
;     Copyright (C) 2008 - 2011 by Igor Funa
; 
;     http://turbo51.com/
; 
;     This file is distributed in the hope that it will be useful,
;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
; }
; 
; Program Example2;
; 
; Uses I2C, SAA7129;
              EXTRN    DATA  (IIC_Adr)
              EXTRN    DATA  (Data2Send)

              EXTRN    CODE  (I2C_AddressPresent)
              EXTRN    CODE  (Start_I2C)
              EXTRN    CODE  (Send_I2C_Byte)
              EXTRN    CODE  (Stop_I2C)

              EXTRN    CODE  (Registers_Test)
              EXTRN    CODE  (Registers_Normal)

; 
; Const Const1ms  = - 22118400 div 12 div 1000;

RSEG _CONST

; 
; Const Led_OFF = True;
;       Led_ON  = False;
; 
; Type  TMode = (mdTest, mdNormal);
; 
; Var   Key1: Boolean absolute P1.7;
Key1                            BIT      P1.7

;       Key2: Boolean absolute P1.6;
Key2                            BIT      P1.6

;       Key3: Boolean absolute P1.5;
Key3                            BIT      P1.5

;       Key4: Boolean absolute P1.4;
Key4                            BIT      P1.4

;       Led1: Boolean absolute P1.3;
Led1                            BIT      P1.3

;       Led2: Boolean absolute P1.2;
Led2                            BIT      P1.2

;       Led3: Boolean absolute P1.1;
Led3                            BIT      P1.1

;       Led4: Boolean absolute P1.0;
Led4                            BIT      P1.0

;       SAA7121_Reset: Boolean absolute P3.7;
SAA7121_Reset                   BIT      P3.7

; 
;       I2C.SCL: Boolean absolute P3.4;
SCL                             BIT      P3.4

;       I2C.SDA: Boolean absolute P3.5;
SDA                             BIT      P3.5

; 
;       BlinkTimer: Word; Volatile;

RSEG _DATA

BlinkTimer:                     DS       2

;       Blink:      Boolean; Volatile;

RSEG _BIT

Blink:                          DBIT     1

;       DelayTimer: Word; Volatile;

RSEG _DATA

DelayTimer:                     DS       2

;       Register:   Byte;
Register:                       DS       1

;       Mode:       TMode;
Mode:                           DS       1

; 
; Procedure Timer_1ms; Interrupt Timer0; Using 1; { 1 ms interrupt }


CSEG AT $000B

USING 1

Timer_1ms:
; begin
              PUSH      PSW
              MOV       PSW, #8
              PUSH      ACC

;   TL0 :=  Lo (Const1ms);
              MOV       TL0, #$CD

;   TH0 :=  Hi (Const1ms);
              MOV       TH0, #$F8

; 
;   Inc (BlinkTimer);
              INC       BlinkTimer
              MOV       A, BlinkTimer
              JNZ       L_0020
              INC       BlinkTimer+1
L_0020:

;   Blink := BlinkTimer and $0200 <> 0;
              MOV       A, BlinkTimer+1
              MOV       C, ACC.1
              MOV       Blink, C

;   If DelayTimer <> 0 then Dec (DelayTimer);
              MOV       A, DelayTimer+1
              ORL       A, DelayTimer
              JZ        L_0035
              DEC       DelayTimer
              MOV       A, DelayTimer
              CJNE      A, #-1, L_0035
              DEC       DelayTimer+1
L_0035:

; end;
              POP       ACC
              POP       PSW
              RETI

; 
; Procedure Delay (DelayTime: Word);

RSEG _DATA

DelayTime:                      DS       2


RSEG _CODE

USING 0

Delay:
; begin
;   DelayTimer := DelayTime;
              MOV       DelayTimer, DelayTime
              MOV       DelayTimer+1, DelayTime+1

;   Repeat
L_0040:
;   until DelayTimer = 0;
              MOV       A, DelayTimer+1
              ORL       A, DelayTimer
              JNZ       L_0040

; end;
              RET

; 
; Procedure Init;

Init:
; begin
;   SAA7121_Reset := False;
              CLR       P3.7

; 
;   TL0 :=  Lo (Const1ms);
              MOV       TL0, #$CD

;   TH0 :=  Hi (Const1ms);
              MOV       TH0, #$F8

;   PCON := $00;       { no IDLE, no POWER DOWN }
              MOV       PCON, #0

;   TMOD := %00100001; { Timer1: no GATE, Timer,  8 bit timer, autoreload }
              MOV       TMOD, #$21

;                      { Timer0: no GATE, Timer, 16 bit timer }
;   TCON := %01010101; { Timer 1 run, Timer 0 run }
              MOV       TCON, #$55

;                      { Int1 falling edge, Int0 falling edge }
;   IE   := %10000010; { Timer0}
              MOV       IE, #$82

; 
;   Delay (50);
              MOV       DelayTime, #LOW  ($0032)
              MOV       DelayTime+1, #HIGH ($0032)
              LCALL     Delay

;   SAA7121_Reset := True;
              SETB      P3.7

;   Delay (10);
              MOV       DelayTime, #LOW  ($000A)
              MOV       DelayTime+1, #HIGH ($000A)
              LCALL     Delay

; 
;   If not Key1 then Mode := mdTest else Mode := mdNormal;
              JB        P1.7, L_0076
              MOV       Mode, #0
              RET
L_0076:
              MOV       Mode, #1

; end;
              RET


CSEG AT $0000

              AJMP     Example2


RSEG _CODE

Example2:
; 
; begin
              MOV       SP, #StackStart-1

;   Init;
              LCALL     Init
              MOV       R3, #$8C

; 
;   While not I2C_AddressPresent (I2C_SAA7129_High) do
              SJMP      L_0094
L_0084:

;     begin
;       Led1 := Blink;
              MOV       C, Blink
              MOV       P1.3, C

;       Led2 := Blink;
              MOV       C, Blink
              MOV       P1.2, C

;       Led3 := Blink;
              MOV       C, Blink
              MOV       P1.1, C

;       Led4 := Blink;
              MOV       C, Blink
              MOV       P1.0, C

;     end;
L_0094:
;   While not I2C_AddressPresent (I2C_SAA7129_High) do
              MOV       IIC_Adr, R3
              LCALL     I2C_AddressPresent
              JNC       L_0084

; 
;   Start_I2C;
              LCALL     Start_I2C

;   Send_I2C_Byte (I2C_SAA7129_High);
              MOV       Data2Send, #$8C
              LCALL     Send_I2C_Byte

;   Send_I2C_Byte ($00);
              MOV       Data2Send, #0
              LCALL     Send_I2C_Byte

;   For Register := $00 to $7F do
              MOV       Register, #$FF
L_00AD:
              INC       Register

;     Case Mode of
              MOV       R2, Mode

;       mdTest:   Send_I2C_Byte (Registers_Test   [Register]);
              CJNE      R2, #0, L_00C1
              MOV       A, Register
              MOV       DPTR, #Registers_Test
              MOVC      A, @A + DPTR
              MOV       Data2Send, A
              LCALL     Send_I2C_Byte
              SJMP      L_00CF
L_00C1:

;       mdNormal: Send_I2C_Byte (Registers_Normal [Register]);
              CJNE      R2, #1, L_00CF
              MOV       A, Register
              MOV       DPTR, #Registers_Normal
              MOVC      A, @A + DPTR
              MOV       Data2Send, A
              LCALL     Send_I2C_Byte
L_00CF:
              MOV       A, Register
              CJNE      A, #$7F, L_00AD

;     end;
;   Stop_I2C;
              LCALL     Stop_I2C

; 
;   Repeat
L_00D7:
;     Case Mode of
              MOV       R2, Mode

;       mdTest: begin
              CJNE      R2, #0, L_00E8

;                 Led1 := Blink;
              MOV       C, Blink
              MOV       P1.3, C

;                 Led2 := True;
              SETB      P1.2

;                 Led3 := True;
              SETB      P1.1

;                 Led4 := True;
              SETB      P1.0

;               end;
              SJMP      L_00F3
L_00E8:

;       mdNormal: begin
              CJNE      R2, #1, L_00F3

;                   Led1 := False;
              CLR       P1.3

;                   Led2 := False;
              CLR       P1.2

;                   Led3 := False;
              CLR       P1.1

;                   Led4 := False;
              CLR       P1.0

;                 end;
L_00F3:
;     end;
;   until False;
              SJMP      L_00D7

; end.

RSEG _CONST


              END

