Program Calculator;

Const
 Osc = 22118400;
 BaudRateTimerValue = Byte (- Osc div 12 div 32 div 19200);

Var SerialPort: Text;
    Num1, Num2: LongInt;

Procedure WriteToSerialPort; Assembler;
Asm
  CLR   TI
  MOV   SBUF, A
@WaitLoop:
  JNB   TI, @WaitLoop
end;

Function ReadFromSerialPort: Char;
Var ByteResult: Byte absolute Result;
begin
  While not RI do;
  RI := False;
  ByteResult := SBUF;

{ Echo character }

  Asm
    MOV    A, Result
    LCALL  WriteToSerialPort
  end;
end;


Procedure Init;
begin
  TL1  := BaudRateTimerValue;
  TH1  := BaudRateTimerValue;
  TMOD := %00100001;    { Timer1: no GATE, 8 bit timer, autoreload }
  SCON := %01010000;    { Serial Mode 1, Enable Reception }
  TI   := True;         { Indicate TX ready }
  TR1  := True;         { Enable timer 1 }
end;

{$DefaultFile On }

begin
  Init;
  Assign (CurrentIO, ReadFromSerialPort, WriteToSerialPort);

  Writeln ('Turbo51 IO file demo - integer calculator');
  Repeat
    Write   ('Enter first number: ');
    Readln  (Num1);
    Write   ('Enter second number: ');
    Readln  (Num2);
    Writeln (Num1, ' + ', Num2, ' = ', Num1 + Num2);
    Writeln (Num1, ' - ', Num2, ' = ', Num1 - Num2);
    Writeln (Num1, ' * ', Num2, ' = ', Num1 * Num2);
  until False;
end.
