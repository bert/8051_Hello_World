{
    This file is part of the Turbo51 examples.
    Copyright (C) 2008 - 2011 by Igor Funa

    http://turbo51.com/

    This file is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

Program HelloWorld;

Const
 Osc      = 22118400;
 BaudRate = 19200;

 BaudRateTimerValue = Byte (- Osc div 12 div 32 div BaudRate);

Var SerialPort: Text;

Procedure WriteToSerialPort; Assembler;
Asm
  CLR   TI
  MOV   SBUF, A
@WaitLoop:
  JNB   TI, @WaitLoop
end;

Procedure Init;
begin
  TL1  := BaudRateTimerValue;
  TH1  := BaudRateTimerValue;
  TMOD := %00100001;    { Timer1: no GATE, 8 bit timer, autoreload }
  SCON := %01010000;    { Serial Mode 1, Enable Reception }
  TI   := True;         { Indicate TX ready }
  TR1  := True;         { Enable timer 1 }

  Assign (SerialPort, WriteToSerialPort);
end;

begin
  Init;
  Writeln (SerialPort, 'Hello world!');
end.
