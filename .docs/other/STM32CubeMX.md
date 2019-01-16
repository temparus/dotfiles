# STM32CubeMX

## Install instructions

*Make sure that Java is installed on your system*

1. Install the software on a Windows machine.
2. Copy the installed files to `/opt/STM32CubeMX` on your linux system.
3. Run `unzip STM32CubeMX.exe` and `rm STM32CubeMX.exe`
4. Create the file `/usr/bin/STM32CubeMX` and set its permissions to `755`.

```bash
#!/bin/bash
java -cp /opt/STM32CubeMX/ com.st.microxplorer.maingui.STM32CubeMX
```

