INCLUDE Irvine32.inc

.data

Text BYTE 'Enter a 32 bit number:',0
X DWORD ?
Y DWORD ?

.code
main proc

	mov edx, OFFSET Text
	call WriteString
	call crlf

	call readint
	mov x, eax

	mov edx, OFFSET Text
	call WriteString
	call crlf

	call readint
	mov y, eax


	invoke ExitProcess,0
main endp
end main
