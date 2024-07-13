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
	mov dword [si+8], 0x06
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
	mov ax,0x3
	int 0x10

	cli			; clear interrupts
	lgdt [gdt32_ptr]	; load gdt
	lidt [idt32_ptr]	; load idt

	mov eax, cr0
	or eax, 1
	mov cr0, eax

	jmp 0x8:protected_mode

error:	
long_mode_not_supported:
end:
	hlt
	jmp end

	[BITS 32]
protected_mode:
	;; initialise registers
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov esp, 0x7c00

	mov byte [0xb8000], 'A'
	mov byte [0xb8001], 0xa

protected_mode_end:
	hlt
	jmp protected_mode_end

drive_id:	db 0
read_packet:	times 16 db 0

gdt32:
	dq 0
code32:	
	dw 0xffff
	dw 0
	db 0
	db 10011010b	; Type: Code, Descriptor type: Executable
	db 11001111b	; Granularity: 4KB, 32-bit
	db 0

data32:	
	; Data Segment Descriptor
	dw 0xffff
	dw 0
	db 0
	db 10010010b	; Type: Data, Descriptor type: Writable
	db 11001111b	; Granularity: 4KB, 32-bit
	db 0

gdt32_len: equ $-gdt32

gdt32_ptr:
	dw gdt32_len-1
	dd gdt32

idt32:			; IDT must be initialized here with proper entries for your system
idt32_ptr:
	dw 0
	dd 0
