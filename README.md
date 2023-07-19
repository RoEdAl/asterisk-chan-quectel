# Asterisk channel driver for *Quectel* and *SimCOM* modules

See original [README](//github.com/IchthysMaranatha/asterisk-chan-quectel/blob/master/README.md) of this project.

----

Supported modules:

* Quectel *EC25-E*,
* SimCOM *SIM7600G-H*,
* SimCOM *SIM900* (analog input/output, see [here](//github.com/RoEdAl/asterisk-chan-quectel/wiki/Using-SIM900-board-with-analog-input-and-output) for more details),
* SimCOM *A7670E* (analog input/output, see [here](//github.com/RoEdAl/asterisk-chan-quectel/wiki/SimCOM-A7670X-limitations) for more details).

# Changes

## Configuration

* `quectel_uac` option renamed to `uac` and it's a on/**off**/ext switch now.

    `alsadev` option is also defaulted to `hw:Android` (when `uac=on`) or `hw:0` (when `uac=ext`).

* New `multiparty` option (on/**off**).

    Ability to handle multiparty calls wastly complicates audio handling.
    Without multiparty calls audio handling is much simpler and uses less resources (CPU, memory, synchronization objects).
    I decided to turn off multiparty calls support by default.
    You can enable it but remember that multiparty calls were never working in UAC mode and even in TTY (serial) mode this support should be considered as **unstable**.
    When `mutliparty` is *off* all multiparty calls are **activley rejected**.

* `dtmf` option is a on/**off** switch now.

    DTMF detection is now performed by *Quectel* module itself (`AT+QTONEDET` or `AT+DDET` command).

* New `dtmf_duration` option.

    Duration in miliseconds of generated *DTMF*.

* New `msg_direct` option (**none**/on/off).

    Specify how to receive messages (`AT+CNMI` command):

    | value | description |
    | :---: | ------- |
    | **none** | do not change |
    | on | messages are received directly by `+CMT:` *URI*  |
    | off | messages are received by `AT+CMGR` command in response to `+CMTI` *URI* |

* New `msg_storage` option (**auto**/sm/me/mt/sr).

    Setting prefered message storage (`AT+CPMS` command):

    | value | description |
    | :---: | ------- |
    | **auto** | do not change |
    | sm | (U)SIM message storage |
    | *me* | mobile equipment message storage |
    | mt | same as *me* storage |
    | sr | SMS status report storage location |

* New `msg_service` option (**-1**/0/1).

    Selecting `Message Service` (`AT+CSMS` command):

    | value | description |
    | :---: | ------ |
    | **-1** | do not change |
    | 0 | SMS AT commands are compatible with *GSM phase 2* |
    | 1 | SMS AT commands are compatible with *GSM phase 2+* |

* New `moh` option (**on**/off).

    Specify hold/unhold action:

    | value  | description |
    | :----: | ----------- |
    | **on** | play/stop MOH |
    | off    | disable/enable uplink voice using `AT+CMUT` command |

* `txgain` and `rxgain` options reimplented.

    * TX/RX gain is performed by module itself.
        
        This channel driver just sends `AT+QMIC`/`AT+QRXGAIN` (`AT+CMICGAIN`/`AT+COUTGAIN` for *SimCOM* module) commands.

    * Default value is **-1** now - use current module setting, do not change gain.
    * Range: **0-65535** or **0-100%**.

    See also `quectel autio gain tx` and `quectel audio gain rx` commands below.

* New `query_time` option (on/**off**).

    | value | description |
    | :---: | ----------- |
    | on | *ping* module with `AT+QLTS` (or `AT+CCLK` for *SimCOM* module) command |
    | **off** | *ping* module with standard `AT` command |

* New `slin16` option (on/**off**).

    Enable/disable 16kHz audio (default is 8kHz).\
    Currently only *SimCOM* SIM7600X module handles 16kHz audio.

## Commands

* `simcom` is an alias of `quectel` commands now.

    You may type `simcom ...` command instead of `quectel ...` one.
    For example `quectel show device status` command is equivalent of `simcom show device status` one.

* Additional fields in `show device status` command.

    Added `Access technology`, `Network Name`, `Short Network Name`, `Registered PLMN`, `Band` and `Module Time` fields:

    ```
        -------------- Status -------------
    Device                  : quectel0
    State                   : Free
    Audio UAC               : hw:Android
    Data                    : /dev/ttyUSB2
    Voice                   : Yes
    SMS                     : Yes
    Manufacturer            : Quectel
    Model                   : EC25
    Firmware                : EC25EXXXXXXXXXX
    IMEI                    : YYYYYYYYYYYYYYY
    IMSI                    : ZZZZZZZZZZZZZZZ
    GSM Registration Status : Registered, home network
    RSSI                    : 22, -69 dBm
    Access technology       : LTE
    Network Name            : Xxxxx
    Short Network Name      : Yxxxx
    Registered PLMN         : 26006
    Provider Name           : Zxxxxxx
    Band                    : LTE BAND 3
    Location area code      : 0000
    Cell ID                 : AAAAAAA
    Subscriber Number       : Unknown
    SMS Service Center      : +99000111222
    Module Time             : 2000/01/01,00:00:00+08,1
    Use UCS-2 encoding      : Yes
    Tasks in queue          : 0
    Commands in queue       : 0
    Call Waiting            : Disabled
    Current device state    : start
    Desired device state    : start
    When change state       : now
    Calls/Channels          : 0
        Active                : 0
        Held                  : 0
        Dialing               : 0
        Alerting              : 0
        Incoming              : 0
        Waiting               : 0
        Releasing             : 0
        Initializing          : 0
    ```

    Some of theese fields are constantly updated via `act` and `csq` notifications (see `AT+QINDCFG` command).

    Additional channel vaiables are also defined:
    
    - `QUECTELNETWORKNAME`
    - `QUECTELSHORTNETWORKNAME`
    - `QUECTELPROVIDER`
    - `QUECTELPLMN`
    - `QUECTELMCC`
    - `QUECTELMNC`

    `PLMN` (*Public Land Mobile Network Code*) combines `MCC` (*Mobile Country Code*) and `MNC` (*Mobile Network Code*).

    `SMS Service Center` is now decoded from *UCS-2*.

* Additional fields ins `quectel show device settings` command.

    Displaying new configuration options:

    ````
        ------------- Settings ------------
    Device                  : quectel0
    Audio UAC               : hw:Android
    Data                    : /dev/ttyUSB2
    IMEI                    : 
    IMSI                    : 
    Channel Language        : en
    Context                 : quectel-incoming
    Exten                   : 
    Group                   : 0
    RX gain                 : -1
    TX gain                 : -1
    Use CallingPres         : Yes
    Default CallingPres     : Presentation Allowed, Passed Screen
    Disable SMS             : No
    Message Service         : 1
    Message Storage         : ME
    Direct Message          : On
    Auto delete SMS         : Yes
    Reset Quectel           : No
    Call Waiting            : auto
    Multiparty Calls        : No
    DTMF Detection          : No
    Hold/Unhold Action      : Mute
    Query Time              : Yes
    Initial device state    : start
    ````

* New `quectel audio` commands:

    These are just wrappers around few audio-related *AT* commands:

    | command | *AT* command |
    | :------ | ------------ |
    | `quectel audio mode` | `AT+QAUDMOD` |
    | `quectel audio gain tx` | `AT+QMIC` |
    | `quectel audio gain rx` | `AT+QRXGAIN` |
    | `quectel audio loop` | `AT+QAUDLOOP` |

## Internal

* `UCS-2` encoding is mandatory now.
* Hanging-up calls using `AT+QHUP` command with specific *release cause*.
* Handling calls is based on `ccinfo` notifications (see `AT+QINDCFG="ccinfo"` command) instead of `DSCI` (`AT^DSCI` command) call status notifications.
* Improved/extended *AT* commands response handler.

    Changes required to properly handle `AT+CMGL` command response.
    This command is now executed at initialization stage in order to receive unread messages.

* Simplyfying audio handling (when `mutliparty` is off, see above) in UAC and TTY mode.

    * Using less resources.
    * Much simpler error handling.
    * More debug messages.
    * Reorganized, improved and simplified code.

* Fixed USSD sending/receiving.
* Getting `ICCID` from SIM card.

    `IICD`: Integrated Circuit Card Identifier.

    It is possible to address device by `ICCID` (`j:` prefix):

    ```
    exten => s,n,Dial(Quectel/j:898600700907A6019125/+79139131234)
    ```

    Additional variable `QUECTELICCID` is also defined.

* Using [`CMake` build system](//github.com/RoEdAl/asterisk-chan-quectel/wiki/Building).
* Improved debug messages.

    Non-printable characters are C escaped using `ast_escape_c` function. For example:

    ```
    DEBUG[11643]: at_read.c:93 at_read: [quectel0] [1][\r\n+QIND: \"csq\",27,99\r\n]
    DEBUG[11654]: at_read.c:93 at_read: [quectel0] [1][\r\n+CPMS: 0,25,0,25,0,25\r\n\r\nOK\r\n]
    DEBUG[11654]: at_read.c:93 at_read: [quectel0] [1][\r\n+QPCMV: 0,2\r\n\r\nOK\r\n]
    DEBUG[13411]: at_queue.c:181 at_write: [quectel0] [AT+QSPN;+QNWINFO\r]
    ```

* Many small optimizations.


