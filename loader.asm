	[BITS 16]
	[ORG 0x7e00]

start:
	mov ah, 0x13
	mov al, 1
	mov bx, 0xa
	xor dx, dx
	mov bp, message
	mov cx, message_len
	int 0x10

end:
	hlt
	jmp end

message:	db "We are in the loader"
message_len:	equ $-message
