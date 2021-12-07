{Object_Title_and_Purpose}


CON
       _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        ' Creating a Pause()
        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        _MS_001     = _ConClkFreq / 1_000

        '' [Declaring pins for Motors]
        motor1 = 10
        motor2 = 11
        motor3 = 12
        motor4 = 13

OBJ

        Motors        : "Servo8Fast_vZ2.spin"
        Term          : "FullDuplexSerial.spin"         'UART communication for debugging

VAR

        LONG cogIDVal
        LONG cogStack[64]

PUB Main                            'Core 0

        Init                        'Run the initialise function
        Pause(1000)                 'Buffer before running

        Forward(10000, 100)          'Move forwards for time (ms) at speed above base
        TurnRight(100, 100)
        Forward(10000, 100)
        TurnLeft(100, 100)
        Forward(10000, 100)
        StopAllMotors
        Pause(3000)
        Reverse(10000, 100)          'Move backwards for time (ms at speed above base
        TurnRight(100, 100)
        Reverse(10000, 100)
        TurnLeft(100, 100)
        Reverse(10000, 100)
        StopAllMotors               'Stop Motors
        StopCore

        repeat

PUB Start(Direction)

        cogIDVal := cognew(MotorCore(Direction), @cogStack)

PUB Init

        Motors.Init                 'Initialise the Motors
        Motors.AddSlowPin(motor1)
        Motors.AddSlowPin(motor2)
        Motors.AddSlowPin(motor3)
        Motors.AddSlowPin(motor4)

        Motors.Start

        return

PUB StopCore

        if cogID < 0
          cogstop(cogIDVal)

PUB MotorCore(Direction)

        Init

        StopAllMotors

        {repeat
          case LONG [Direction]
            1:
              Forward(100, 100)
            2:
              Reverse(100, 100)
            3:
              TurnLeft(100, 100)
            4:
              TurnRight(100, 100)
            5:
              StopAllMotors  }

PUB Set(motor, speed) | m, v

        if (motor == 10)            'Base motor speed (0) for all motors
          m := 1460
        elseif (motor == 11)
          m := 1460
        elseif (motor == 12)
          m := 1460
        elseif (motor == 13)
          m := 1460

        v := m + speed              'Get the set value by adding the speed required to base value

        Motors.Set(motor, v)

        return

PUB StopAllMotors  | t

        Set(motor1, 0)            'Set all motors speed to base (0)
        Set(motor2, 0)
        Set(motor3, 0)
        Set(motor4, 0)
        return

PUB Forward(ms ,speed) | t


        repeat t from 0 to ms       'Set motor speed for set amount of time
          Set(motor1, speed)
          Set(motor2, speed)
          Set(motor3, speed)
          Set(motor4, speed)

        repeat t from 0 to 1000    'Stop motors for 1000 cycles
          Set(motor1, 0)
          Set(motor2, 0)
          Set(motor3, 0)
          Set(motor4, 0)
        return

PUB Reverse(ms, speed) | t, v

        v := -speed

        repeat t from 0 to ms      'Set motor speed to below base value for reverse motion
          Set(motor1, v)
          Set(motor2, v)
          Set(motor3, v)
          Set(motor4, v)

        repeat t from 0 to 1000    'Stop motors for 1000 cycles
          Set(motor1, 0)
          Set(motor2, 0)
          Set(motor3, 0)
          Set(motor4, 0)
        return

PUB TurnLeft(left, right) | t

        repeat t from 0 to 10000   'Set each turn values for left and right side wheels
          Set(motor1, left)
          Set(motor2, -right)
          Set(motor3, left)
          Set(motor4, -right)

        repeat t from 0 to 1000    'Stop motors for 1000 cycles
          Set(motor1, 0)
          Set(motor2, 0)
          Set(motor3, 0)
          Set(motor4, 0)
        return

PUB TurnRight(left, right) | t

        repeat t from 0 to 10000   'Set each turn values for left and right side wheels
          Set(motor1, -left)
          Set(motor2, right)
          Set(motor3, -left)
          Set(motor4, right)

        repeat t from 0 to 1000    'Stop motors for 1000 cycles
          Set(motor1, 0)
          Set(motor2, 0)
          Set(motor3, 0)
          Set(motor4, 0)
        return

PRI Pause(ms) | t

        t := cnt - 1088
        repeat (ms #> 0)
          waitcnt(t += _MS_001)
        return