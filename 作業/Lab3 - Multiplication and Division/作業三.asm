INCLUDE Irvine32.inc

.data

array  DWORD 1,2,3,4,5,6,7,8,9,0Ah,0Bh　

.code
main proc

	　　
    mov   esi  , OFFSET array       ; 起始位置
    mov   ecx , LENGTHOF array      ; 元數個數
    mov   ebx , TYPE array          ;  單位大小
    call    DumpMem 

	invoke ExitProcess,0
main endp
end main
