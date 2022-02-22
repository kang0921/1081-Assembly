INCLUDE Irvine32.inc

.data
counter = 5 ;迴圈跑fib(3)~(7)
fib dword 7 DUP(?) ;設一個array儲存fib(1) ~ fib(7)

.code
main proc

	mov ecx, counter ;
	mov ebx,8 ;dword is 4bytes
	mov fib[0],1 ; initialize fib(1) = 1
	mov fib[4],1 ; initialize fib(2) = 1
L1:
	mov eax, fib[ebx-8] ; eax = fib[ebx-8]
	add eax, fib[ebx-4] ; eax = fib[ebx-8] + fib[eax-4]
	mov fib[ebx], eax ; fib[ebx] = eax = fib[ebx-8]  + fib[ebx-4]
	mov eax, fib[ebx]
	call WriteDec ;print it
	call Crlf ;print'\n'
	add ebx, 4 
	
	loop L1
	invoke ExitProcess,0
main endp
end main
