{
    This file is part of the Turbo51 examples.
    Copyright (C) 2008 - 2011 by Igor Funa

    http://turbo51.com/

    This file is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

Unit I2C;

Interface

Const High = True;
      Low  = False;

Var Ack: Boolean;
    SDA: Boolean absolute Forward;
    SCL: Boolean absolute Forward;

Procedure Start_I2C;
Procedure Stop_I2C;
Procedure Send_I2C_Byte (Data2Send: Byte);
Function  Receive_I2C_Byte: Byte;
Procedure Send_I2C_Ack;
Procedure Send_I2C_ClockPulse;
Function  I2C_AddressPresent (IIC_Adr: Byte): Boolean;

Implementation

Var BitCounter: Byte;

Procedure Start_I2C;
begin
  SCL := High;
  Asm
    NOP
    NOP
  end;
  SDA := Low;
  Asm
    NOP
    NOP
  end;
  SCL := Low;
end;

Procedure Stop_I2C;
begin
  SDA := Low;
  Asm
    NOP
    NOP
  end;
  SCL := High;
  Asm
    NOP
    NOP
  end;
  SDA := High;
end;

Procedure Send_I2C_Byte (Data2Send: Byte);
begin
  For BitCounter := 1 to 8 do
    begin
      SDA := (Data2Send and $80) <> 0;
      Asm
        NOP
        NOP
      end;
      SCL := High;
      Asm
        NOP
        NOP
      end;
      SCL := Low;
      Data2Send := Data2Send shl 1;
    end;
  Asm
    NOP
  end;
  SDA := High;
  Asm
    NOP
    NOP
  end;
  SCL := High;
  Asm
    NOP
    NOP
  end;
  Ack := not SDA;
  SCL := Low;
end;

Function Receive_I2C_Byte: Byte;
Var Data: Byte;
begin
  Data := 0;
  For BitCounter := 1 to 8 do
    begin
      SCL := High;
      Asm
        NOP
        NOP
      end;
      Data := Data shl 1;
      Data := Data or (Byte (SDA) + 0);
      SCL := Low;
    end;
  Receive_I2C_Byte := Data;
end;

Procedure Send_I2C_Ack;
begin
  SDA := Low;
  Asm
    NOP
  end;
  SCL := High;
  Asm
    NOP
  end;
  SCL := Low;
  Asm
    NOP
  end;
  SDA := High;
end;

Procedure Send_I2C_ClockPulse;
begin
  SCL := High;
  Asm
    NOP
  end;
  SCL := Low;
end;

Procedure Delay;
begin
Asm
  MUL  AB
  MUL  AB
  MUL  AB
  MUL  AB
  MUL  AB
  MUL  AB
  MUL  AB
end;
end;

Function  I2C_AddressPresent (IIC_Adr: Byte): Boolean;
begin
  Start_I2C;
  Send_I2C_Byte (IIC_Adr);
  Stop_I2C;
  I2C_AddressPresent := Ack;
  Delay;
end;

end.
