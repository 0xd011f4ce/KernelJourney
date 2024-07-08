	[BITS 16]
	[ORG 0x7e00]

start:
	mov [drive_id], dl

	;; check maximum function of the cpu
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb long_mode_not_supported

	mov eax, 0x80000001
	cpuid
	test edx, (1 << 29)
	jz long_mode_not_supported
	test edx, (1 << 26)
	jz long_mode_not_supported

	mov ah, 0x13
	mov al, 1
	mov bx, 0xa
	xor dx, dx
	mov bp, message
	mov cx, message_len
	int 0x10

long_mode_not_supported:
end:
	hlt
	jmp end

drive_id:	db 0
message:	db "long mode is supported"
message_len:	equ $-message
