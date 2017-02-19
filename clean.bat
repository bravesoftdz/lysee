@ECHO OFF
cd source
DEL /S /F /Q *.exe *.dll *.so *.apk *.dbg
DEL /S /F /Q *a *.o *.ppu *.bak *.dcu *.obj *.tmp *.bpl .bpi *.dcp *.drc
DEL /S /F /Q *.or *.~* *~ *.a *.db *.map *.dres *.rsm *.tds *.lib *.ocx
DEL /S /F /Q *.cfg *.hpp *Resource.rc
DEL /S /F /Q *.local *.identcache *.projdata *.tvsconfig *.dsk *.compiled *.stat
DEL tools\lysee tools\lysee_cmd tools\lysee_pad
DEL /S /F /Q __history\*.* backup\*.* lib\*.* debug\*.* win32\*.* __recovery\*.*
RMDIR /S /Q __history backup lib debug win32 __recovery
cd ..\tools
DEL /S /F /Q *.exe *.dll *.so *.apk *.dbg
DEL /S /F /Q *a *.o *.ppu *.bak *.dcu *.obj *.tmp *.bpl .bpi *.dcp *.drc
DEL /S /F /Q *.or *.~* *~ *.a *.db *.map *.dres *.rsm *.tds *.lib *.ocx
DEL /S /F /Q *.cfg *.hpp *Resource.rc
DEL /S /F /Q *.local *.identcache *.projdata *.tvsconfig *.dsk *.compiled *.stat
DEL tools\lysee tools\lysee_cmd tools\lysee_pad
DEL /S /F /Q __history\*.* backup\*.* lib\*.* debug\*.* win32\*.* __recovery\*.*
RMDIR /S /Q __history backup lib debug win32 __recovery
cd ..
PAUSE
@ECHO ON
