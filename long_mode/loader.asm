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

load_kernel:
	mov si, read_packet
	mov word [si], 0x10
	mov word [si+2], 100
	mov word [si+4], 0	; we load the kernel here, because we'll load the 64 bit kernel to 0x100000
	mov word [si+6], 0x1000	; 0x1000 * 16 = 0x10000
	mov dword [si+8], 6
	mov dword [si+0xc], 0
	mov dl, [drive_id]
	mov ah, 0x42
	int 0x13
	jc error

get_memory_info_start:
	mov eax, 0xe820
	mov edx, 0x534d4150
	mov ecx, 20
	mov edi, 0x9000
	xor ebx, ebx
	int 0x15
	jc error

get_memory_info:
	add edi, 20
	mov eax, 0xe820
	mov edx, 0x534d4150
	mov ecx, 20
	int 0x15
	jc get_memory_done

	test ebx, ebx
	jnz get_memory_info

get_memory_done:
	mov ah, 0x13
	mov al, 1
	mov bx, 0xa
	xor dx, dx
	mov bp, message
	mov cx, message_len
	int 0x10

error:	
long_mode_not_supported:
end:
	hlt
	jmp end

drive_id:	db 0
message:	db "memory info done"
message_len:	equ $-message

read_packet:	times 16 db 0
