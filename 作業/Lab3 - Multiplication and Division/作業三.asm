INCLUDE Irvine32.inc

.data

array  DWORD 1,2,3,4,5,6,7,8,9,0Ah,0Bh�@

.code
main proc

	�@�@
    mov   esi  , OFFSET array       ; �_�l��m
    mov   ecx , LENGTHOF array      ; ���ƭӼ�
    mov   ebx , TYPE array          ;  ���j�p
    call    DumpMem 

	invoke ExitProcess,0
main endp
end main
