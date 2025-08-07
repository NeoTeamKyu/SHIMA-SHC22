
; ===============================================================
; ---------------------------------------------------------------
; Error handling and debugging modules
; 2016-2017, Vladikcomper
; ---------------------------------------------------------------
; Error handler functions and calls
; ---------------------------------------------------------------

; ---------------------------------------------------------------
; Error handler control flags
; ---------------------------------------------------------------

; Screen appearence flags
_eh_address_error	equ	$01		; use for address and bus errors only (tells error handler to display additional "Address" field)
_eh_show_sr_usp		equ	$02		; displays SR and USP registers content on error screen
_eh_disassemble		equ	$10		; disassembles the instruction where the error happened + vint and hint handlers

; Advanced execution flags
; WARNING! For experts only, DO NOT USES them unless you know what you're doing
_eh_return		equ	$20
_eh_enter_console	equ	$40
_eh_align_offset	equ	$80

; ---------------------------------------------------------------
; Errors vector table
; ---------------------------------------------------------------

; Default screen configuration
_eh_default			equ	0 ;_eh_show_sr_usp

; ---------------------------------------------------------------

BusError:
	__ErrorMessage "BUS ERROR", _eh_default|_eh_address_error|_eh_disassemble

AddressError:
	__ErrorMessage "ADDRESS ERROR", _eh_default|_eh_address_error|_eh_disassemble

IllegalInstr:
	__ErrorMessage "ILLEGAL INSTRUCTION", _eh_default|_eh_disassemble

ZeroDivide:
	__ErrorMessage "ZERO DIVIDE", _eh_default|_eh_disassemble

ChkInstr:
	__ErrorMessage "CHK INSTRUCTION", _eh_default|_eh_disassemble

TrapvInstr:
	__ErrorMessage "TRAPV INSTRUCTION", _eh_default|_eh_disassemble

PrivilegeViol:
	__ErrorMessage "PRIVILEGE VIOLATION", _eh_default|_eh_disassemble

Trace:
	__ErrorMessage "TRACE", _eh_default|_eh_disassemble

Line1010Emu:
	__ErrorMessage "LINE A EMULATOR", _eh_default|_eh_disassemble

Line1111Emu:
	__ErrorMessage "LINE F EMULATOR", _eh_default|_eh_disassemble

ErrorExcept:
	__ErrorMessage "ERROR EXCEPTION", _eh_default|_eh_disassemble

ErrorTrap:
	__ErrorMessage "ERROR TRAP", _eh_default

; ---------------------------------------------------------------
; Import error handler global functions
; ---------------------------------------------------------------

ErrorHandler.__global__error_initconsole equ ErrorHandler+$158
ErrorHandler.__global__errorhandler_setupvdp equ ErrorHandler+$25C
ErrorHandler.__global__console_loadpalette equ ErrorHandler+$AE2
ErrorHandler.__global__console_setposasxy_stack equ ErrorHandler+$B1E
ErrorHandler.__global__console_setposasxy equ ErrorHandler+$B24
ErrorHandler.__global__console_getposasxy equ ErrorHandler+$B50
ErrorHandler.__global__console_startnewline equ ErrorHandler+$B72
ErrorHandler.__global__console_setbasepattern equ ErrorHandler+$B9A
ErrorHandler.__global__console_setwidth equ ErrorHandler+$BAE
ErrorHandler.__global__console_writeline_withpattern equ ErrorHandler+$BC4
ErrorHandler.__global__console_writeline equ ErrorHandler+$BC6
ErrorHandler.__global__console_write equ ErrorHandler+$BCA
ErrorHandler.__global__console_writeline_formatted equ ErrorHandler+$C76
ErrorHandler.__global__console_write_formatted equ ErrorHandler+$C7A
ErrorHandler.__global__decode68k equ ErrorHandler+$CE6

; ---------------------------------------------------------------
; Error handler external functions (compiled only when used)
; ---------------------------------------------------------------


	if ref(ErrorHandler.__extern_scrollconsole)
ErrorHandler.__extern__scrollconsole:

	endc

	if ref(ErrorHandler.__extern__console_only)
ErrorHandler.__extern__console_only:
	dc.l	$46FC2700, $4FEFFFF2, $48E7FFFE, $47EF003C
	jsr		ErrorHandler.__global__errorhandler_setupvdp(pc)
	jsr		ErrorHandler.__global__error_initconsole(pc)
	dc.l	$4CDF7FFF, $487A0008, $2F2F0012, $4E7560FE
	endc

	if ref(ErrorHandler.__extern__vsync)
ErrorHandler.__extern__vsync:
	dc.l	$41F900C0, $000444D0, $6BFC44D0, $6AFC4E75
	endc

; ---------------------------------------------------------------
; Include error handler binary module
; ---------------------------------------------------------------

ErrorHandler:
	incbin	"Error Handler/ErrorHandler.bin"

; ---------------------------------------------------------------
; WARNING!
;	DO NOT put any data from now on! DO NOT use ROM padding!
;	Symbol data should be appended here after ROM is compiled
;	by ConvSym utility, otherwise debugger modules won't be able
;	to resolve symbol names.
; ---------------------------------------------------------------
