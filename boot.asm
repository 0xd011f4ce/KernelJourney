	[BITS 16]
	[ORG 0x7c00]

start:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00

test_disk_extension:
	mov [drive_id], dl
	
	mov ah, 0x41
	mov bx, 0x55aa
	int 0x13

	jc disk_extension_not_supported
	cmp bx, 0xaa55
	jne disk_extension_not_supported

print_message:
	mov ah, 0x13
	mov al, 1
	mov bx, 0xa
	xor dx, dx
	mov bp, message
	mov cx, message_len
	int 0x10

disk_extension_not_supported:	
end:
	hlt
	jmp end

drive_id:	db 0
message:	db "Disk Extension is supported"
message_len:	equ $-message

	times (0x1be-($-$$)) db 0

	db 80h			; boot indicator
	db 0, 2, 0		; starting chs
	db 0f0h			; type
	db 0ffh, 0ffh, 0ffh	; ending chs
	dd 1			; starting sector
	dd (20 * 16 * 63 - 1)	; size

	times (16 * 3) db 0	; fill with zeros

	db 0x55
	db 0xaa
