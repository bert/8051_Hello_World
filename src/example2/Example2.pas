{
    This file is part of the Turbo51 examples.
    Copyright (C) 2008 - 2011 by Igor Funa

    http://turbo51.com/

    This file is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

Program Example2;

Uses I2C, SAA7129;

Const Const1ms  = - 22118400 div 12 div 1000;

Const Led_OFF = True;
      Led_ON  = False;

Type  TMode = (mdTest, mdNormal);

Var   Key1: Boolean absolute P1.7;
      Key2: Boolean absolute P1.6;
      Key3: Boolean absolute P1.5;
      Key4: Boolean absolute P1.4;
      Led1: Boolean absolute P1.3;
      Led2: Boolean absolute P1.2;
      Led3: Boolean absolute P1.1;
      Led4: Boolean absolute P1.0;
      SAA7121_Reset: Boolean absolute P3.7;

      I2C.SCL: Boolean absolute P3.4;
      I2C.SDA: Boolean absolute P3.5;

      BlinkTimer: Word; Volatile;
      Blink:      Boolean; Volatile;
      DelayTimer: Word; Volatile;
      Register:   Byte;
      Mode:       TMode;

Procedure Timer_1ms; Interrupt Timer0; Using 1; { 1 ms interrupt }
begin
  TL0 :=  Lo (Const1ms);
  TH0 :=  Hi (Const1ms);

  Inc (BlinkTimer);
  Blink := BlinkTimer and $0200 <> 0;
  If DelayTimer <> 0 then Dec (DelayTimer);
end;

Procedure Delay (DelayTime: Word);
begin
  DelayTimer := DelayTime;
  Repeat
  until DelayTimer = 0;
end;

Procedure Init;
begin
  SAA7121_Reset := False;

  TL0 :=  Lo (Const1ms);
  TH0 :=  Hi (Const1ms);
  PCON := $00;       { no IDLE, no POWER DOWN }
  TMOD := %00100001; { Timer1: no GATE, Timer,  8 bit timer, autoreload }
                     { Timer0: no GATE, Timer, 16 bit timer }
  TCON := %01010101; { Timer 1 run, Timer 0 run }
                     { Int1 falling edge, Int0 falling edge }
  IE   := %10000010; { Timer0}

  Delay (50);
  SAA7121_Reset := True;
  Delay (10);

  If not Key1 then Mode := mdTest else Mode := mdNormal;
end;

begin
  Init;

  While not I2C_AddressPresent (I2C_SAA7129_High) do
    begin
      Led1 := Blink;
      Led2 := Blink;
      Led3 := Blink;
      Led4 := Blink;
    end;

  Start_I2C;
  Send_I2C_Byte (I2C_SAA7129_High);
  Send_I2C_Byte ($00);
  For Register := $00 to $7F do
    Case Mode of
      mdTest:   Send_I2C_Byte (Registers_Test   [Register]);
      mdNormal: Send_I2C_Byte (Registers_Normal [Register]);
    end;
  Stop_I2C;

  Repeat
    Case Mode of
      mdTest: begin
                Led1 := Blink;
                Led2 := True;
                Led3 := True;
                Led4 := True;
              end;
      mdNormal: begin
                  Led1 := False;
                  Led2 := False;
                  Led3 := False;
                  Led4 := False;
                end;
    end;
  until False;
end.
