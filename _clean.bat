@echo off

dir /AD /b /s > temp.txt
@for /F "delims=" %%x in (temp.txt) do call :process "%%x"
goto :exit

:process

@echo Cleaning %1
if EXIST %1\*.~* del %1\*.~*
if EXIST %1\*.dcu del %1\*.dcu
if EXIST %1\*.opt del %1\*.opt
if EXIST %1\*.dsm del %1\*.dsm
if EXIST %1\*.ddp del %1\*.ddp
if EXIST %1\*.dsk del %1\*.dsk
if EXIST %1\*.map del %1\*.map
if EXIST %1\*.o del %1\*.o
if EXIST %1\*.bak del %1\*.bak
if EXIST %1\*.ppu del %1\*.ppu
if EXIST %1\*.bdsproj.local del %1\*.bdsproj.local
if EXIST %1\*.dproj.local del %1\*.dproj.local
if EXIST %1\*.groupproj.local del %1\*.groupproj.local
if EXIST %1\*.identcache del %1\*.identcache
if EXIST %1\*.drc del %1\*.drc
goto :eof

:exit

del temp.txt
del *.dsk
del *.dcu
del *.~*

:eof
