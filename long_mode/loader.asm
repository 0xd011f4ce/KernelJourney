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
	mov eax, 0xe820		; bios function for memory map
	mov edx, 0x534d4150	; smap signature
	mov ecx, 20		; size of memory map entry
	mov edi, 0x9000		; address to store memory map
	xor ebx, ebx		; clear ebx
	int 0x15		; call bios memory services
	jc error

get_memory_info:
	add edi, 20		; increment by 20 (size of memory map entry)
	mov eax, 0xe820		; call again function for memory map
	mov edx, 0x534d4150	; set smap signature again
	mov ecx, 20		; size of memory map entry
	int 0x15		; call bios memory services
	jc get_memory_done	; we are finished if carry flag is set

	test ebx, ebx		; test ebx
	jnz get_memory_info	; loop if ebx is not zero
get_memory_done:

	;; enable A20 line
	in al, 0x92
	or al, 2
	out 0x92, al

	xor ax, ax
	mov es, ax

set_video_mode:
	mov ax,3
	int 0x10
	
	mov si,message
	mov ax,0xb800
	mov es,ax
	xor di,di
	mov cx,message_len

print_message:
	mov al,[si]
	mov [es:di],al
	mov byte[es:di+1],0xa

	add di,2
	add si,1
	loop print_message

error:	
long_mode_not_supported:
end:
	hlt
	jmp end

drive_id:	db 0
message:	db "Text mode is set"
message_len:	equ $-message
read_packet:	times 16 db 0
