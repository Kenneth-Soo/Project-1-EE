{
  Project:      EE-7 Assignment
  Platform:     Parallex Project USB Board
  Revision:     1.1
  Author:       Kenneth
  Date:         13th November 2021
  Log:
        Date:        Description:
        13/11/2021
}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        _MS_001     = _ConClkFreq / 1_000

OBJ

        Motor   : "MotorControl.spin"
        Sensor  : "SensorControl.spin"
        Term    : "FullDuplexSerial.spin"
        Comm    : "CommControl.spin"

VAR

        LONG Ultra1, Ultra2, ToF1, ToF2

        LONG Direction, Input

PUB Main | Status

        Comm.Init
        Motor.Start(@Direction)
        Term.Start(31, 30, 0, 115200)
        Sensor.Start(@Ultra1, @Ultra2, @ToF1, @ToF2)

        Pause(3000)

        {
        repeat
          Term.Str(String(13, "ToF 1 Reading: "))
          Term.Dec(ToF1)
          Term.Str(String(13, "ToF 2 Reading: "))
          Term.Dec(ToF2)
          Term.Str(String(13, "Ultra 1 Reading: "))
          Term.Dec(Ultra1)
          Term.Str(String(13, "Ultra 2 Reading: "))
          Term.Dec(Ultra2)
          Pause(100)
          Term.Tx(0)
        }

        repeat
          case Input
            01:
                Motor.Forward(100,100)
            02:
                Motor.Reverse(100,100)
            03:
              Motor.TurnLeft(-100,100)
            04:
              Motor.TurnRight(100,-100)
            05:
              Motor.StopAllMotors

PRI Pause(ms) | t

        t := cnt - 1088
        repeat (ms #> 0)
          waitcnt(t += _MS_001)
        return
