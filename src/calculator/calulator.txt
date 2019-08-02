; Turbo51 version 0.1.3.10, Copyright 2000 - 2011 Igor Funa

$REGISTERBANK (0)

_CODE         SEGMENT  CODE
_CONST        SEGMENT  CODE
_DATA         SEGMENT  DATA

              EXTRN    DATA  (CurrentIO)
              EXTRN    IDATA (StackStart)

              EXTRN    CODE  (sysWriteStr_CODE)
              EXTRN    CODE  (sysWriteLine)
              EXTRN    CODE  (sysReadLongInt)
              EXTRN    CODE  (sysStore_Long0_To_IDATA)
              EXTRN    CODE  (sysReadLine)
              EXTRN    CODE  (sysLoad_Long0_From_IDATA)
              EXTRN    CODE  (sysPushLongIntBCD)
              EXTRN    CODE  (sysWriteDecimalPushedBytes)
              EXTRN    CODE  (sysLoad_Long1_From_IDATA)
              EXTRN    CODE  (sysLongAddition)
              EXTRN    CODE  (sysLongSubtraction)
              EXTRN    CODE  (sysLongMultiplication)

; Program Calculator;
; 
; Const

RSEG _CONST

;  Osc = 22118400;
;  BaudRateTimerValue = Byte (- Osc div 12 div 32 div 19200);
; 
; Var SerialPort: Text;
;     Num1, Num2: LongInt;

RSEG _DATA

Num1:                           DS       4
Num2:                           DS       4

; 
; Procedure WriteToSerialPort; Assembler;


RSEG _CODE

USING 0

WriteToSerialPort:
; Asm
;   CLR   TI
              CLR       SCON.1

;   MOV   SBUF, A
              MOV       SBUF, A

; @WaitLoop:
L_0111:
;   JNB   TI, @WaitLoop
              JNB       SCON.1, L_0111

; end;
              RET

; 
; Function ReadFromSerialPort: Char;

RSEG _DATA

ReadFromSerialPort_Result:      DS       1

; Var ByteResult: Byte absolute Result;
ByteResult                      EQU      ReadFromSerialPort_Result


RSEG _CODE

ReadFromSerialPort:
; begin
;   While not RI do;
L_0115:
              JNB       SCON.0, L_0115

;   RI := False;
              CLR       SCON.0

;   ByteResult := SBUF;
              MOV       ReadFromSerialPort_Result, SBUF

; 
; { Echo character }
; 
;   Asm
;     MOV    A, Result
              MOV       A, ReadFromSerialPort_Result

;     LCALL  WriteToSerialPort
              LCALL     WriteToSerialPort

;   end;
; end;
              MOV       A, ReadFromSerialPort_Result
              RET

; 
; 
; Procedure Init;

Init:
; begin
;   TL1  := BaudRateTimerValue;
              MOV       TL1, #$FD

;   TH1  := BaudRateTimerValue;
              MOV       TH1, #$FD

;   TMOD := %00100001;    { Timer1: no GATE, 8 bit timer, autoreload }
              MOV       TMOD, #$21

;   SCON := %01010000;    { Serial Mode 1, Enable Reception }
              MOV       SCON, #$50

;   TI   := True;         { Indicate TX ready }
              SETB      SCON.1

;   TR1  := True;         { Enable timer 1 }
              SETB      TCON.6

; end;
              RET

RSEG _CONST

C_0435:                         DB        41, 'Turbo51 IO file demo - integer calculator'
C_045F:                         DB        20, 'Enter first number: '
C_0474:                         DB        21, 'Enter second number: '
C_048A:                         DB        3, ' + '
C_048E:                         DB        3, ' = '
C_0492:                         DB        3, ' - '
C_0496:                         DB        3, ' * '


CSEG AT $0000

Calculator:
; 
; {$DefaultFile On }
; 
; begin
              MOV       SP, #StackStart-1

;   Init;
              LCALL     Init

;   Assign (CurrentIO, ReadFromSerialPort, WriteToSerialPort);
              MOV       CurrentIO, #LOW  (WriteToSerialPort)
              MOV       CurrentIO+1, #HIGH (WriteToSerialPort)
              MOV       CurrentIO+2, #LOW  (ReadFromSerialPort)
              MOV       CurrentIO+3, #HIGH (ReadFromSerialPort)

; 
;   Writeln ('Turbo51 IO file demo - integer calculator');
              MOV       DPTR, #C_0435
              MOV       R6, #0
              LCALL     sysWriteStr_CODE
              LCALL     sysWriteLine

;   Repeat
L_001D:
;     Write   ('Enter first number: ');
              MOV       DPTR, #C_045F
              MOV       R6, #0
              LCALL     sysWriteStr_CODE

;     Readln  (Num1);
              LCALL     sysReadLongInt
              MOV       R0, #Num1
              LCALL     sysStore_Long0_To_IDATA
              LCALL     sysReadLine

;     Write   ('Enter second number: ');
              MOV       DPTR, #C_0474
              MOV       R6, #0
              LCALL     sysWriteStr_CODE

;     Readln  (Num2);
              LCALL     sysReadLongInt
              MOV       R0, #Num2
              LCALL     sysStore_Long0_To_IDATA
              LCALL     sysReadLine

;     Writeln (Num1, ' + ', Num2, ' = ', Num1 + Num2);
              MOV       R0, #Num1
              LCALL     sysLoad_Long0_From_IDATA
              LCALL     sysPushLongIntBCD
              MOV       R6, #0
              LCALL     sysWriteDecimalPushedBytes
              MOV       DPTR, #C_048A
              MOV       R6, #0
              LCALL     sysWriteStr_CODE
              MOV       R0, #Num2
              LCALL     sysLoad_Long0_From_IDATA
              LCALL     sysPushLongIntBCD
              MOV       R6, #0
              LCALL     sysWriteDecimalPushedBytes
              MOV       DPTR, #C_048E
              MOV       R6, #0
              LCALL     sysWriteStr_CODE
              MOV       R0, #Num1
              LCALL     sysLoad_Long0_From_IDATA
              MOV       R0, #Num2
              LCALL     sysLoad_Long1_From_IDATA
              LCALL     sysLongAddition
              LCALL     sysPushLongIntBCD
              MOV       R6, #0
              LCALL     sysWriteDecimalPushedBytes
              LCALL     sysWriteLine

;     Writeln (Num1, ' - ', Num2, ' = ', Num1 - Num2);
              MOV       R0, #Num1
              LCALL     sysLoad_Long0_From_IDATA
              LCALL     sysPushLongIntBCD
              MOV       R6, #0
              LCALL     sysWriteDecimalPushedBytes
              MOV       DPTR, #C_0492
              MOV       R6, #0
              LCALL     sysWriteStr_CODE
              MOV       R0, #Num2
              LCALL     sysLoad_Long0_From_IDATA
              LCALL     sysPushLongIntBCD
              MOV       R6, #0
              LCALL     sysWriteDecimalPushedBytes
              MOV       DPTR, #C_048E
              MOV       R6, #0
              LCALL     sysWriteStr_CODE
              MOV       R0, #Num1
              LCALL     sysLoad_Long0_From_IDATA
              MOV       R0, #Num2
              LCALL     sysLoad_Long1_From_IDATA
              CLR       C
              LCALL     sysLongSubtraction
              LCALL     sysPushLongIntBCD
              MOV       R6, #0
              LCALL     sysWriteDecimalPushedBytes
              LCALL     sysWriteLine

;     Writeln (Num1, ' * ', Num2, ' = ', Num1 * Num2);
              MOV       R0, #Num1
              LCALL     sysLoad_Long0_From_IDATA
              LCALL     sysPushLongIntBCD
              MOV       R6, #0
              LCALL     sysWriteDecimalPushedBytes
              MOV       DPTR, #C_0496
              MOV       R6, #0
              LCALL     sysWriteStr_CODE
              MOV       R0, #Num2
              LCALL     sysLoad_Long0_From_IDATA
              LCALL     sysPushLongIntBCD
              MOV       R6, #0
              LCALL     sysWriteDecimalPushedBytes
              MOV       DPTR, #C_048E
              MOV       R6, #0
              LCALL     sysWriteStr_CODE
              MOV       R0, #Num1
              LCALL     sysLoad_Long0_From_IDATA
              MOV       R0, #Num2
              LCALL     sysLoad_Long1_From_IDATA
              LCALL     sysLongMultiplication
              LCALL     sysPushLongIntBCD
              MOV       R6, #0
              LCALL     sysWriteDecimalPushedBytes
              LCALL     sysWriteLine

;   until False;
              LJMP      L_001D

; end.

              END
