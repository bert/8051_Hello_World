; Turbo51 version 0.1.3.10, Copyright 2000 - 2011 Igor Funa

$REGISTERBANK (0)

_CODE         SEGMENT  CODE
_DATA         SEGMENT  DATA
_BIT          SEGMENT  BIT

              PUBLIC   Ack
              PUBLIC   Data2Send
              PUBLIC   IIC_Adr
              PUBLIC   BitCounter

              PUBLIC   Start_I2C
              PUBLIC   Stop_I2C
              PUBLIC   Send_I2C_Byte
              PUBLIC   Receive_I2C_Byte
              PUBLIC   Send_I2C_Ack
              PUBLIC   Send_I2C_ClockPulse
              PUBLIC   Delay
              PUBLIC   I2C_AddressPresent

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
; Unit I2C;
; 
; Interface
; 
; Const High = True;

RSEG _CONST

;       Low  = False;
; 
; Var Ack: Boolean;

RSEG _BIT

Ack:                            DBIT     1

;     SDA: Boolean absolute Forward;
              EXTRN    BIT   (SDA)

;     SCL: Boolean absolute Forward;
              EXTRN    BIT   (SCL)

; 
; Procedure Start_I2C;
; Procedure Stop_I2C;
; Procedure Send_I2C_Byte (Data2Send: Byte);

RSEG _DATA

Data2Send:                      DS       1

; Function  Receive_I2C_Byte: Byte;
Receive_I2C_Byte_Result:        DS       1

; Procedure Send_I2C_Ack;
; Procedure Send_I2C_ClockPulse;
; Function  I2C_AddressPresent (IIC_Adr: Byte): Boolean;

RSEG _BIT

I2C_AddressPresent_Result:      DBIT     1

RSEG _DATA

IIC_Adr:                        DS       1

; 
; Implementation
; 
; Var BitCounter: Byte;
BitCounter:                     DS       1

; 
; Procedure Start_I2C;

USING 0

Start_I2C:
; begin
;   SCL := High;
              SETB      SCL

;   Asm
;     NOP
              NOP

;     NOP
              NOP

;   end;
;   SDA := Low;
              CLR       SDA

;   Asm
;     NOP
              NOP

;     NOP
              NOP

;   end;
;   SCL := Low;
              CLR       SCL

; end;
              RET

; 
; Procedure Stop_I2C;

Stop_I2C:
; begin
;   SDA := Low;
              CLR       SDA

;   Asm
;     NOP
              NOP

;     NOP
              NOP

;   end;
;   SCL := High;
              SETB      SCL

;   Asm
;     NOP
              NOP

;     NOP
              NOP

;   end;
;   SDA := High;
              SETB      SDA

; end;
              RET

; 
; Procedure Send_I2C_Byte (Data2Send: Byte);

Send_I2C_Byte:
; begin
;   For BitCounter := 1 to 8 do
              MOV       BitCounter, #0
              MOV       R2, Data2Send
L_001B:
              INC       BitCounter

;     begin
;       SDA := (Data2Send and $80) <> 0;
              MOV       A, R2
              RLC       A
              MOV       SDA, C

;       Asm
;         NOP
              NOP

;         NOP
              NOP

;       end;
;       SCL := High;
              SETB      SCL

;       Asm
;         NOP
              NOP

;         NOP
              NOP

;       end;
;       SCL := Low;
              CLR       SCL

;       Data2Send := Data2Send shl 1;
              MOV       A, R2
              ADD       A, ACC
              MOV       R2, A

;     end;
              MOV       A, BitCounter
              CJNE      A, #8, L_001B

;   Asm
;     NOP
              NOP

;   end;
;   SDA := High;
              SETB      SDA

;   Asm
;     NOP
              NOP

;     NOP
              NOP

;   end;
;   SCL := High;
              SETB      SCL

;   Asm
;     NOP
              NOP

;     NOP
              NOP

;   end;
;   Ack := not SDA;
              MOV       C, SDA
              CPL       C
              MOV       Ack, C

;   SCL := Low;
              CLR       SCL

; end;
              RET

; 
; Function Receive_I2C_Byte: Byte;
; Var Data: Byte;
Data:                           DS       1

Receive_I2C_Byte:
; begin
;   Data := 0;
              MOV       R2, #0

;   For BitCounter := 1 to 8 do
              MOV       BitCounter, R2
L_0047:
              INC       BitCounter

;     begin
;       SCL := High;
              SETB      SCL

;       Asm
;         NOP
              NOP

;         NOP
              NOP

;       end;
;       Data := Data shl 1;
              MOV       A, R2
              ADD       A, ACC
              MOV       R2, A

;       Data := Data or (Byte (SDA) + 0);
              MOV       C, SDA
              CLR       A
              RLC       A
              ORL       A, R2
              MOV       R2, A

;       SCL := Low;
              CLR       SCL

;     end;
              MOV       A, BitCounter
              CJNE      A, #8, L_0047

;   Receive_I2C_Byte := Data;
; end;
              MOV       A, R2
              RET

; 
; Procedure Send_I2C_Ack;

Send_I2C_Ack:
; begin
;   SDA := Low;
              CLR       SDA

;   Asm
;     NOP
              NOP

;   end;
;   SCL := High;
              SETB      SCL

;   Asm
;     NOP
              NOP

;   end;
;   SCL := Low;
              CLR       SCL

;   Asm
;     NOP
              NOP

;   end;
;   SDA := High;
              SETB      SDA

; end;
              RET

; 
; Procedure Send_I2C_ClockPulse;

Send_I2C_ClockPulse:
; begin
;   SCL := High;
              SETB      SCL

;   Asm
;     NOP
              NOP

;   end;
;   SCL := Low;
              CLR       SCL

; end;
              RET

; 
; Procedure Delay;

Delay:
; begin
; Asm
;   MUL  AB
              MUL       AB

;   MUL  AB
              MUL       AB

;   MUL  AB
              MUL       AB

;   MUL  AB
              MUL       AB

;   MUL  AB
              MUL       AB

;   MUL  AB
              MUL       AB

;   MUL  AB
              MUL       AB

; end;
; end;
              RET

; 
; Function  I2C_AddressPresent (IIC_Adr: Byte): Boolean;

I2C_AddressPresent:
; begin
;   Start_I2C;
              LCALL     Start_I2C

;   Send_I2C_Byte (IIC_Adr);
              MOV       Data2Send, IIC_Adr
              LCALL     Send_I2C_Byte

;   Stop_I2C;
              LCALL     Stop_I2C

;   I2C_AddressPresent := Ack;
              MOV       C, Ack
              MOV       I2C_AddressPresent_Result, C

;   Delay;
              LCALL     Delay

; end;
              MOV       C, I2C_AddressPresent_Result
              RET

RSEG _CONST

; 
; end.

              END

