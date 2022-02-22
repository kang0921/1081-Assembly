INCLUDE Irvine32.inc

.data
myID BYTE 4,0,7,2,6,1,1,2,8
sizeID = ($-myID)
myID_oddCount BYTE 0
myID_evenSum BYTE 0
myID_result BYTE 0


.code
main proc
	mov ecx, sizeID
	mov esi, 0
	L1:
		mov ebx, ecx				; ebx = 第幾個字
		and ebx, 1					; ebx = 第幾個字%2
		cmp ebx, 0					; if(ebx%2==0)
		jne L2						; if(ebx%2!=0) jump to L2 
		mov al,  myID[esi]			; al = 第esi個字的數字 (ebx%2==0)
		add myID_evenSum, al		; myID_evenCount += 第esi個字的數字 (ebx%2==0)
		jmp L3
			
	L2:
		mov al, myID[esi]
		add myID_oddCount, al
		jmp L3
	L3:
		add esi, TYPE BYTE			; esi += 1 BYTE
		mov eax, esi
		loop L1

	mov al, myID_oddCount			
	mov bl, myID_evenSum				
	mul bl							; al = al * bl
	mov myID_result, al				; myID_result = al
	call WriteDec					; print myID_result
	
	invoke ExitProcess,0
main endp
end main
