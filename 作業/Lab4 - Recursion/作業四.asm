INCLUDE Irvine32.inc


mGotoxy MACRO X:REQ, Y:REQ
	push edx
	mov dh, Y
	mov dl, x
	call Gotoxy
	pop edx
ENDM

mReadString MACRO varName:REQ
	push ecx
	push edx
	mov edx, OFFSET varName
	mov ecx, SIZEOF varName
	call ReadString
	pop edx
	pop ecx
ENDM

mWrite MACRO text
	LOCAL string
	.data
	string BYTE text, 0
	.code
	push edx
	mov edx, OFFSET string
	call WriteString
	pop edx
ENDM

.data
acctNum BYTE 30 DUP(?)

.code

main PROC

	exit
main ENDP
END main
