@echo off
"AMPS\Includer.exe" ASM68K AMPS AMPS\.Data
IF EXIST SHIMAbuilt.gen move /Y SHIMAbuilt.gen SHIMAbuilt.prev.gen >NUL
asm68k /m /p /o ae-,v+ sonic.asm, SHIMAbuilt.gen, profiling\sonic.sym, .lst>.log
type .log
if not exist SHIMAbuilt.gen pause & exit
"AMPS\Dual PCM Compress.exe" AMPS\.z80 AMPS\.z80.dat SHIMAbuilt.gen _dlls\koscmp.exe
"Error Handler/ConvSym.exe" .lst SHIMAbuilt.gen -input asm68k_lst -inopt "/localSign=. /localJoin=. /ignoreMacroDefs+ /ignoreMacroExp- /addMacrosAsOpcodes+" -a
fixheadr.exe SHIMAbuilt.gen
del AMPS\.Data
pause