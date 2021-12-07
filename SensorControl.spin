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

        ' Creating a Pause()
        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        _MS_001     = _ConClkFreq / 1_000

        '' [Declare pins for sensor]
        'Ultrasonic 1 (Front)  - I2C bus 1
        ultra1SCL = 6
        ultra1SDA = 7
        'Ultrasonic 2 (Back)   - I2C bus 2
        ultra2SCl = 8
        ultra2SDA = 9
        'ToF 1 (Front) - I2C bus 1
        tof1SCL = 0
        tof1SDA = 1
        tof1RST = 14
        tofADD  = $29
        'ToF 2 (Back) - I2C bus 2
        tof2SCL = 2
        tof2SDA = 3
        tof2RST = 15

OBJ
        Term      : "FullDuplexSerial.spin"
        Ultra[2]  : "EE-7_Ultra.spin"
        ToF[2]    : "EE-7_ToF.spin"

VAR

        LONG cogIDVal
        LONG cogStack[64]

PUB Start(Ultra1, Ultra2, ToF1, ToF2)

        StopCore

        cogIDVal := cognew(Init(Ultra1,Ultra2,ToF1,ToF2), @cogStack)

        return

PUB Init(Ultra1, Ultra2, ToF1, ToF2)

        'Declaration & initialisation
        Ultra[0].Init(ultra1SCL, ultra1SDA)
        Ultra[1].Init(ultra2SCL, ultra2SDA)

        ' Initialize The front ToF Sensor
        ToF[0].Init(tof1SCL, tof1SDA, tof1RST)
        ToF[0].ChipReset(1)     'Last state is ON position
        Pause(1000)
        ToF[0].FreshReset(tofADD)
        ToF[0].MandatoryLoad(tofADD)
        ToF[0].RecommendedLoad(tofADD)
        ToF[0].FreshReset(tofADD)

        ' Initialize the back ToF Sensor
        ToF[1].Init(tof2SCL, tof2SDA, tof2RST)
        ToF[1].ChipReset(1)
        Pause(1000)
        ToF[1].FreshReset(tofADD)
        ToF[1].MandatoryLoad(tofADD)
        ToF[1].RecommendedLoad(tofADD)
        ToF[1].FreshReset(tofADD)

        repeat
          LONG [Ultra1] := Ultra[0].readSensor
          LONG [Ultra2] := Ultra[1].readSensor
          LONG [ToF1] := ToF[0].GetSingleRange(tofADD)
          LONG [Tof2] := ToF[1].GetSingleRange(tofADD)
          Pause(100)

PUB StopCore

        if cogIDVal
          cogstop(cogIDVal~)

PRI Pause(ms) | t

        t := cnt - 1088
        repeat (ms #> 0)
          waitcnt(t += _MS_001)
        return