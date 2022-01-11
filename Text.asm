INCLUDE Irvine32.inc
INCLUDE macros.inc
BUFFER_SIZE = 5000
.data
;------ ASCII Art ------;

asciBuffer BYTE BUFFER_SIZE DUP(0)
asciFile BYTE 'ASCII.txt', 0
asciFileHandle HANDLE ?
plagcount dword 0
three_word_shit byte 0

buffer BYTE BUFFER_SIZE DUP(0)
filename BYTE 80 DUP(0)
fileHandle HANDLE ?
buffer2 BYTE BUFFER_SIZE DUP (0)
filename2 BYTE 80 DUP(0)
fileHandle2 HANDLE ?
fileSize1 dword ?
fileSize2 dword ?
string1 byte 5000 DUP(0)
string2 byte 5000 DUP(0)
threewords byte 0
counter dword 0

first_word_count dword 0
second_word_count dword 0
similar_words dword 0

tempVar1 DWORD 0
tempVar2 DWORD 0

promptBad BYTE "Invalid input, please enter again",0
decNum    DWORD ?
same byte 1000 DUP(0)
pointer dword 0
.code

main PROC

mov edx,OFFSET asciFile
call OpenInputFile
mov asciFileHandle, eax

call Clrscr;

;mov  eax,black+(gray*16);
;call setTextColor

mov edx,OFFSET asciBuffer 
mov ecx,BUFFER_SIZE
call ReadFromFile
mov asciBuffer[eax],0 ; insert null terminator
mWriteString offset asciBuffer

call crlf
call crlf
call crlf
call crlf

mWrite "Do you want to enter the texts manually or want to read from file : "
call crlf
mWrite "Press 1 to enter text manually"
call crlf 
mWrite "Press 2 to read data from file"

read:  call ReadDec
       jnc  goodInput
	   cmp eax, 2
	   jle goodInput

       mov  edx,OFFSET promptBad
       call WriteString
       jmp  read        ;go input again

goodInput:
	cmp eax, 1
	je manualentry
	cmp eax, 2
	je fileEntry

manualentry:
	mWrite "Enter text 1: "
	mov edx, offset buffer
	mov ecx, 5000
	call ReadString
	mov buffer[eax], 0
	mWrite "Enter text 2: "
	mov edx, offset buffer2
	mov ecx, 5000
	call ReadString
	mov buffer2[eax], 0
	jmp processing



fileEntry :
	mWrite "Enter name for File 1:"
	mov edx,OFFSET filename
	mov ecx,SIZEOF filename
	call ReadString

	;-------------------------------------- 
	; Open the file for input.

	mov edx,OFFSET filename
	call OpenInputFile
	mov fileHandle,eax

	;--------------------------------------

	;--------------------------------------
	; Read the file into a buffer.

	mov edx,OFFSET buffer
	mov ecx,BUFFER_SIZE
	call ReadFromFile
	mov buffer[eax],0 ; insert null terminator
	;---------------------------------------

	;--------------------------------------
	mWrite "File1 size: "
	call WriteDec ; display file size
	mov fileSize1, eax
	call Crlf
	; Display the buffer.
	mWrite <"File1 Buffer:",0dh,0ah,0dh,0ah>
	mov edx,OFFSET buffer ; display the buffer
	call WriteString
	call Crlf
	mov eax,fileHandle
	call CloseFile
	;--------------------------------------



	mWrite "Enter name for File 2:"
	mov edx,OFFSET filename2
	mov ecx,SIZEOF filename2
	call ReadString

	;--------------------------------------
	; Open the file for input.
	mov edx,OFFSET filename2
	call OpenInputFile
	mov fileHandle2,eax
	;--------------------------------------

	;--------------------------------------
	; Read the file into a buffer.

	mov edx,OFFSET buffer2
	mov ecx,BUFFER_SIZE
	call ReadFromFile
	mov buffer2[eax],0 ; insert null terminator
	;---------------------------------------

	;--------------------------------------
	mWrite "File2 size: "
	call WriteDec ; display file size
	mov fileSize2, eax
	call Crlf
	; Display the buffer.
	mWrite <"File2 Buffer:",0dh,0ah,0dh,0ah>
	mov edx,OFFSET buffer2 ; display the buffer
	call WriteString
	call Crlf
	mov eax,fileHandle2
	call CloseFile
	;--------------------------------------

processing:

	INVOKE Str_length, ADDR buffer
	mWrite "FILE 1 SIZE BEFORE TRIMMING : "
	call WriteDec
	call crlf
	cmp eax, 0
	je zeroFileSize
	INVOKE Str_length, ADDR buffer2
	mWrite "FILE 2 SIZE BEFORE TRIMMING : "
	call WriteDec
	call crlf
	cmp eax, 0
	je zeroFileSize


	; Cleaning the buffers from trailing spaces

	INVOKE Str_trim, ADDR buffer, ' '
	INVOKE Str_trim, ADDR buffer2, ' '
	INVOKE str_trim, ADDR buffer2, '.'
	INVOKE Str_trim, ADDR buffer, 0ah
	INVOKE Str_trim, ADDR buffer, 0dh
	INVOKE str_trim, ADDR buffer, '.'
	INVOKE Str_trim, ADDR buffer2, 0ah
	INVOKE Str_trim, ADDR buffer2, 0dh

	INVOKE Str_length, ADDR buffer
	mov ecx, eax
	inc ecx

	L1:
		INVOKE Str_trim, ADDR buffer, ' '
		INVOKE Str_trim, ADDR buffer, 0ah
	INVOKE Str_trim, ADDR buffer, 0dh
	INVOKE Str_trim, ADDR buffer, '.'
loop l1

INVOKE Str_length, ADDR buffer
mov ecx, eax
inc ecx

L2:
	INVOKE Str_trim, ADDR buffer2, ' '
	INVOKE Str_trim, ADDR buffer2, 0ah
	INVOKE Str_trim, ADDR buffer2, 0dh
	INVOKE Str_trim, ADDR buffer2, '.'
loop L2


INVOKE Str_length, ADDR buffer
mWrite "FILE 1 SIZE AFTER TRIMMING : "
call WriteDec
call crlf
cmp eax, 0
je zeroFileSize
INVOKE Str_length, ADDR buffer2
mWrite "FILE 2 SIZE AFTER TRIMMING : "

call WriteDec
call crlf
cmp eax, 0
je zeroFileSize
; replacing spaces, colon, semi-colon, commas, and fullstop with 0
INVOKE Str_length, ADDR buffer
mov ecx, eax
mov esi, 0
replace:
	push eax
	mov eax, 0
	mov al, ' '
	cmp buffer[esi], al
	je replacing
	mov al, 0ah
	cmp buffer[esi], al

	je replacing
	mov al, 0dh
	cmp buffer[esi], al
	je replacing_without_count
	mov al, ','
	cmp buffer[esi], al
	je replacing_without_count
	mov al, ';'
	cmp buffer[esi], al
	je replacing_without_count
	mov al, ':'
	cmp buffer[esi], al
	je replacing_without_count
	mov al, '.'
	cmp buffer[esi], al
	je replacing_without_count
	mov al, '!'
	cmp buffer[esi], al
	je replacing_without_count
	mov al, '?'
	cmp buffer[esi], al
	je replacing_without_count
after_replaced: inc esi
pop eax
dec ecx
cmp ecx, 0
jne replace

INVOKE Str_length, ADDR buffer2
mov ecx, eax
mov esi, 0
replace2:
	push eax
	mov eax, 0
	mov al, ' '
	cmp buffer2[esi], al
	je replacing2
	mov al, 0ah
	cmp buffer2[esi], al
	je replacing2
	mov al, 0dh
	cmp buffer2[esi], al
	je replacing_without_count2
	mov al, ','
	cmp buffer2[esi], al
	je replacing_without_count2
	mov al, ';'
	cmp buffer2[esi], al
	je replacing_without_count2
	mov al, ':'
	cmp buffer2[esi], al
	je replacing_without_count2
	mov al, '.'
	cmp buffer2[esi], al
	je replacing_without_count2
	cmp buffer2[esi], al
	je replacing_without_count2
	mov al, '!'
	cmp buffer2[esi], al
	je replacing_without_count2
	mov al, '?'
	cmp buffer2[esi], al
	je replacing_without_count2

after_replaced2: inc esi
pop eax
cmp ecx, 0
dec ecx
jne replace2
;
push eax
	mov eax, first_word_count
	mWrite "Words in first file : "
	call WriteDec
	mov eax, second_word_count
	call crlf
	mWrite "Words in second file : "
	call WriteDec
	call crlf
pop eax

; printing words 1 by 1
push ecx
mov ecx, first_word_count
inc ecx
mov esi, 0
checkingwords:
	mov edx, offset buffer
	after_increment:
	cmp buffer[esi], 0
	je increment_esi
	add edx, esi
	mov ebx, 0
	push ecx
	mov ecx, second_word_count
	inc ecx
	checkingwords2:
		after_increment3:
		cmp buffer[esi], 0
		je increment_esi2

		mov eax, offset buffer2
		after_increment2:
		cmp buffer2[ebx], 0
		je increment_ebx
		add eax, ebx
		push edx
			mov edx, eax
			call crlf
			call crlf
			call crlf
			push eax
			mov eax,pointer 
			call WriteDec
		pop eax
		pop edx
		INVOKE Str_compare, ADDR buffer2[ebx], ADDR buffer[esi]
		je increment_similar
			mov ebx, tempVar1
			mov esi, tempVar2
			cmp three_word_shit, 3
			jge printsame
after_print_same: mov three_word_shit, 0
			mov pointer, 0
			INVOKE Str_length, ADDR buffer2[ebx]
			add ebx, eax
after_increment_similar:

	cmp ecx, 0
	dec ecx
	jne checkingwords2
	pop ecx
	INVOKE Str_length, ADDR buffer[esi]
	add esi, eax
	dec ecx
	cmp ecx, 0
	jne checkingwords

	pop ecx
	mov eax, 0
	mov eax, first_word_count
	call WriteDec
	call crlf
	mov eax, second_word_count 
	call WriteDec
	call crlf
	mov eax, similar_words
	call WriteDec
	call crlf
	exit
zeroFileSize: call crlf
			call crlf
			exit
replacing_without_count:
	mov buffer[esi], 0
jmp after_replaced
replacing:
	mov buffer[esi], 0
	push ebx
	mov ebx, 0
	mov ebx, first_word_count
	inc ebx
	mov first_word_count, ebx 
	pop ebx
jmp after_replaced
exit

replacing_without_count2:
	mov buffer2[esi], 0
jmp after_replaced2
replacing2:
	mov buffer2[esi], 0
	push ebx
	mov ebx, 0
	mov ebx, second_word_count
	inc ebx
	mov second_word_count, ebx 
	pop ebx
jmp after_replaced2
exit

increment_esi:
	inc esi
jmp after_increment
exit
increment_ebx:
	inc ebx
jmp after_increment2
exit
increment_similar:
	cmp pointer,0
	je saving_ebx
	after_save:
	push eax
	mov eax, 0
	
		;;;INVOKE Str_compare, ADDR buffer2[ebx], ADDR buffer[esi]
		push esi
			inc three_word_shit
			mov esi, pointer
			;same[esi]
			INVOKE Str_copy, ADDR buffer2[ebx], ADDR same[esi]
			; length 

			INVOKE Str_length, ADDR buffer2[ebx]
			add esi, eax
			mov same[esi], ' '
			inc esi
			mov same[esi], ' '
			mov pointer, esi
		pop esi
		INVOKE Str_length, ADDR buffer2[ebx]
		add ebx, eax
		INVOKE Str_length, ADDR buffer[esi]
		add esi, eax

	inc similar_words
	;inc eax
	;mov similar_words, eax
	call crlf
	mov eax, similar_words
	pop eax
	call crlf
jmp after_increment_similar

printsame:
	mWrite "This line is the same in both text : "
	call crlf
	mWriteString offset same
	mov pointer, 0
jmp after_print_same
increment_esi2:
	inc esi
jmp after_increment3
saving_ebx :
	mov tempVar1, ebx
	mov tempVar2, esi
jmp after_save
main ENDP
END main