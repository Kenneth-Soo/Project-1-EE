{
  Project:      CommControl
  Platform:     Parallex Project USB Board
  Revision:     1.1
  Author:       Kenneth
  Date:         10th November 2021
  Log:
        Date:        Description:
        10/11/2021
}


CON
        _clkmode    = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq    = 5_000_000
        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        _MS_001     = _ConClkFreq / 1_000

        commRxPin   = 20
        commTxPin   = 21
        commBaud    = 9600

        commStart   = $7A
        commForward = $01
        commReverse = $02
        commLeft    = $03
        commRight   = $04
        commStopAll = $AA

OBJ
        Comm   : "FullDuplexSerial.spin"
        Motor  : "MotorControl.spin"
        Sensor : "SensorControl.spin"

VAR

        LONG cogIDVal
        LONG cogStack[64]
        LONG RxValue

PUB Init

        Comm.Start(commTxPin, commRxPin, 0, commBaud)
        Pause(3000)

PUB Start(Input)

        cogIDVal := cognew(CommCore(Input), @cogStack)

PUB CommCore(Input)

        repeat
          RxValue := Comm.RxCheck
          if (RxValue == CommStart)
            repeat
              RxValue := Comm.RxCheck
              case RxValue
                commForward:
                  LONG [Input] := 01
                commReverse:
                  LONG [Input] := 02
                commLeft:
                  LONG [Input] := 03
                commRight:
                  LONG [Input] := 04
                commStopAll:
                  LONG [Input] := 05

PRI Pause(ms) | t

        t := cnt - 1088
        repeat (ms #> 0)
          waitcnt(t += _MS_001)
        return