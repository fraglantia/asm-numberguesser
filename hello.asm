	SECTION .data				; data section

title: db "=== ASM NUMBER GUESSER ==="
lentitle: equ 26

diff: db "Difficulty:", 10, "[1]: Easy (1 number)", 10, "[2]: Medium (3 numbers)", 10, "[3]: Hard (5 numbers)", 10, "> "
lendiff: equ 81					;

round1: db "== ROUND ["
round2: db "] ==", 10
round3: db "Please input "
round4: db " number(s):", 10, "> "
lenround1: equ 10
lenround2: equ 5
lenround3: equ 13
lenround4: equ 14

verdict1: db "- Num ["
verdict2: db "]: "
verdicthigh: db " is too high!", 10
verdictlow: db " is too low!", 10
verdictcorrect: db " is correct!", 10
lenverdict1: equ 7
lenverdict2: equ 3
lenverdicthigh: equ 14
lenverdictlow: equ 13
lenverdictcorrect: equ 13

congrats1: db "Congrats! You guessed the answer in "
congrats2: db " round(s)!", 10
lencongrats1: equ 36
lencongrats2: equ 11

rng: db 0
nl: db 10

	SECTION .text				; code section

global _start					; make label available to linker 
global _printNum
global _readXNum
global _randNum
global _askDifficulty
global _newline
global _initXNum
global _roundStart
global _verdict

_start:							; standard  gcc  entry point
	push ebp
	mov ebp, esp
	sub esp, 24

	mov dword [ebp-4], 0
	mov dword [ebp-8], 0 		; int guess[8]
	mov dword [ebp-12], 0
	mov dword [ebp-16], 0 		; int ans[8]
	mov dword [ebp-20], 0 		; int curRound
	mov dword [ebp-24], 0 		; int numOfNums/diff

	mov	edx, lentitle
	mov	ecx, title
	mov	ebx, 1
	mov	eax, 4
	int	0x80

	call _newline
	call _askDifficulty

	mov [ebp-24], eax 			; diff = askDIfficulty()
	mov dword [ebp-20], 1 		; curRound=1
	
	lea ebx, [ebp-16]
	push ebx
	push eax
	call _initXNum

	mainloop:
		call _newline
		mov ebx, [ebp-24]
		push ebx
		mov eax, [ebp-20]
		push eax
		call _roundStart

		lea eax, [ebp-8]
		push eax
		call _readXNum

		mov eax, [ebp-24]
		push eax
		lea eax, [ebp-16]
		push eax
		lea eax, [ebp-8]
		push eax
		call _verdict
		inc dword [ebp-20] 		; round++
		test eax, eax
		jz mainloop


	dec dword [ebp-20]

	call _newline

	mov	edx,lencongrats1
	mov	ecx, congrats1
	mov	ebx, 1
	mov	eax, 4
	int	0x80

	mov eax, [ebp-20]
	push eax
	call _printNum

	mov	edx,lencongrats2
	mov	ecx, congrats2
	mov	ebx, 1
	mov	eax, 4
	int	0x80


	mov	ebx, 0					; exit code, 0=normal
	mov	eax, 1					; exit command to kernel
	int	0x80					; interrupt 80 hex, call kernel


; bool verdict(int* guess, int* ans, int diff) -> prints verdict for each guesses
_verdict:
	push ebp
	mov ebp, esp

	sub esp, 20

	mov eax, [ebp+8]
	mov ebx, [ebp+12]
	mov ecx, [ebp+16]
	xor edx, edx

	mov [ebp-4], eax 				; guess
	mov [ebp-8], ebx 				; ans
	mov [ebp-12], ecx 				; loop barrier/diff
	mov [ebp-16], edx 				; loop ctr
	mov dword [ebp-20], 0  			; correct ans

	verdictloop:
		mov edx, [ebp-16]
		mov ecx, [ebp-12]
		cmp ecx, edx
		jle vercheck

		mov	edx, lenverdict1
		mov	ecx, verdict1
		mov	ebx, 1
		mov	eax, 4
		int	0x80

		mov edx, [ebp-16]
		inc edx
		push edx
		call _printNum

		mov	edx, lenverdict2
		mov	ecx, verdict2
		mov	ebx, 1
		mov	eax, 4
		int	0x80

		mov edx, [ebp-16]
		mov eax, [ebp-4]
		lea eax, [eax+edx]
		mov eax, [eax]
		and eax, 0xff
		push eax

		call _printNum

		mov edx, [ebp-16]
		mov ebx, [ebp-8]
		lea ebx, [ebx+edx]
		mov ebx, [ebx]
		and ebx, 0xff

		cmp eax, ebx
		jg verhigh
		jl verlow
		jmp vercor

	verhigh:
		mov	edx, lenverdicthigh
		mov	ecx, verdicthigh
		jmp verprint

	verlow:
		mov	edx, lenverdictlow
		mov	ecx, verdictlow
		jmp verprint

	vercor:
		mov edx, [ebp-20]
		inc edx
		mov [ebp-20], edx
		mov	edx, lenverdictcorrect
		mov	ecx, verdictcorrect
		jmp verprint

	verprint:
		mov ebx, [ebp-16]
		inc ebx
		mov [ebp-16], ebx
		mov	ebx, 1
		mov	eax, 4
		int	0x80
		jmp verdictloop

	vercheck:
		mov edx, [ebp-20]
		mov ecx, [ebp-12]
		cmp edx, ecx
		jl verzero
		mov eax, 1
		jmp verdone

	verzero:
		xor eax, eax

	verdone:
		leave
		ret


; void roundStart(int roundNum, int difficulty) -> prints current round's instructions
_roundStart:
	push ebp
	mov ebp, esp

	mov	edx, lenround1
	mov	ecx, round1
	mov	ebx, 1
	mov	eax, 4
	int	0x80

	mov eax, [ebp+8]
	push eax
	call _printNum

	mov	edx, lenround2
	mov	ecx, round2
	mov	ebx, 1
	mov	eax, 4
	int	0x80

	mov	edx, lenround3
	mov	ecx, round3
	mov	ebx, 1
	mov	eax, 4
	int	0x80

	mov eax, [ebp+12]
	push eax
	call _printNum

	mov	edx, lenround4
	mov	ecx, round4
	mov	ebx, 1
	mov	eax, 4
	int	0x80

	leave
	ret

; void initXNum(int x, int* resArr) -> initializes x numbers to resArr
_initXNum:
	push ebp
	mov ebp, esp

	sub esp, 4
	mov dword [ebp-4], 0

	initxnumloop:
		call _randNum

		mov cl, byte [ebp-4]
		mov	ebx, [ebp+12]
		lea ebx, [ebx+ecx]
		mov byte [ebx], al

		inc ecx
		mov byte [ebp-4], cl

		mov	edx, [ebp+8]
		cmp ecx, edx
		jl initxnumloop

	leave
	ret

; void newline() -> prints a newline
_newline:
	push ebp
	mov ebp, esp

	mov	edx,1
	mov	ecx, nl
	mov	ebx, 1
	mov	eax, 4
	int	0x80

	leave
	ret

; int askDifficulty() -> returns how many numbers to be guessed (1=easy, 3=medium, 5=hard), according to input (1=easy, 2=medium, 3=hard)
_askDifficulty:
	push ebp
	mov ebp, esp

	sub esp, 4
	mov dword [ebp-4], 0
	
	mov	edx,lendiff				; arg3, length of string to print
	mov	ecx, diff				; arg2, pointer to string
	mov	ebx, 1					; arg1, where to write, screen
	mov	eax, 4					; write sysout command to int 80 hex
	int	0x80					; interrupt 80 hex, call kernel

	lea eax, [ebp-4]
	push eax
	call _readXNum

	xor eax, eax
	mov al, byte [ebp-4]

	cmp eax, 1
	je askDifficultyEasy
	cmp eax, 2
	je askDifficultyMedium
	cmp eax, 3
	je askDifficultyHard

	askDifficultyEasy:
		mov eax, 1
		jmp askDifficultyDone

	askDifficultyMedium:
		mov eax, 3
		jmp askDifficultyDone

	askDifficultyHard:
		mov eax, 5
		jmp askDifficultyDone

	askDifficultyDone:
		leave
		ret


; int randNum() -> get 1 byte random
_randNum:
	push ebp
	mov ebp, esp
	
	sub esp, 4
	mov dword [ebp-4], 0

	lea ebx, [ebp-4]
	mov eax, 13
	int 0x80

	mov eax, [ebx] 			; a = time()
	add eax, [rng]
	mov ebx, 347 			; a*=347
	mul ebx
	add eax, 71 			; a+=71
	inc dword [rng]

	and eax, 0xff

	leave
	ret


; int readXNum(*int resArr) reads x numbers space seperated, returns the numbers read in an array
_readXNum:
	push ebp
	mov ebp, esp

	sub esp, 28
	mov dword [ebp-28], 0

	mov	edx, 24					; arg3, length of string to read
	lea	ecx, [ebp-24]			; arg2, pointer to string
	mov	ebx, 1					; arg1, where to write, screen
	mov	eax, 3					; read command to int 80 hex
	int	0x80					; interrupt 80 hex, call kernel

	xor edx, edx
	xor ecx, ecx 				; i=0
	xor eax, eax 				; n=0

	readxnumloop1:
		lea ebx, [ebp+ecx-24]
		mov dl, byte [ebx] 		; d = s[0]

		cmp dl, 0x20 			; if d==' '
		je done1 				; goto done1
		cmp dl, 0xa 			; if d=='\n '
		je done1 				; goto done1

		lea eax, [eax*4+eax] 	; n *= 10
		shl eax, 1

		sub dl, 48 				; d-='0'

		add al, dl 				; n+=d
		inc ecx 				; i++

		jmp readxnumloop1

	done1:
		mov byte [ebp-26], dl
		mov dl, byte [ebp-28] 		; j
		mov ebx, [ebp+8] 		; b = resArr
		mov [ebx+edx], eax 		; b[j] = n
		xor eax, eax 			; n=0
		inc ecx 				; i++
		inc edx 				; j++
		mov byte [ebp-28], dl
		
		mov dl, byte [ebp-26]
		cmp dl, 0xa 			; if d=='\n'
		je doneall 				; goto doneall

		jmp readxnumloop1

	doneall:
		leave
		ret


; void printNum(int n) -> prints n in base10
_printNum:
	push ebp
	mov ebp, esp

	sub esp, 8					; ebp-4 => buffer of number
	mov dword [ebp-4], 0
	mov dword [ebp-8], 0

	xor ecx, ecx				; i = 0

	xor eax, eax				; eax = 0
	mov eax, [ebp+8]			; eax = num

	printnumloop:
		xor edx, edx 			; d = 0

		mov ebx, 10
		div ebx					; edx = eax % 10
								; eax = eax / 10

		add edx, 48 			; d = eax%10+'0'
		lea ebx, [ebp-1]
		sub ebx, ecx 			; b = *s+4-i
		mov [ebx], dl 			; s[b] = d
		inc ecx 				; i++

		cmp eax, 0 				; if num!=0
		jne printnumloop 		; loop

	lea	edx,[ecx+1]				; arg3, length of string to print
	lea ecx, [ebp]				; arg2, pointer to string
	sub ecx, edx
	mov	ebx,1					; arg1, where to write, screen
	mov	eax,4					; write sysout command to int 80 hex
	int	0x80					; interrupt 80 hex, call kernel

	mov eax, [ebp+8]

	leave
	ret