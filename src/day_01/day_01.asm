# constants
FD_STOUT  = 1
O_RDONLY  = 0
SYS_CLOSE = 57
SYS_OPEN  = 62
SYS_READ  = 63
SYS_WRITE = 64
SYS_EXIT  = 93

    .data
filename:   .asciz "input.txt"
buffer:     .space 4096

    .text
    .globl _start

atoi:
    li t0, '0'
    sub a0, a0, t0
    ret

itoa:
    li t0, '0'
    add a0, a0, t0
    ret

_start:
    li a0, SYS_OPEN
    la a1, filename
    li a2, O_RDONLY
    ecall
    mv s0, a0            # Store file descriptor

read_chunk:
    li a0, SYS_READ
    mv a1, s0
    la a2, buffer
    li a3, 4096
    ecall

    beqz a0, end_program # Exit on EOF

    la t0, buffer        # Pointer to buffer
    li t1, 0

process_number:
    lbu t2, 0(t0)        # Load the current character
    beqz t2, print_sum   # If null terminator, print the sum

                         # Check if the character is a number
    li t3, '0'
    li t4, '9'
    blt t2, t3, not_a_number
    bge t2, t4, not_a_number

    jal atoi

    slli t1, t1, 3       # t1 = t1 * 8
    slli t1, t1, 1       # t1 = t1 * 2
    add t1, t1, a0

not_a_number:
    addi t0, t0, 1
    j process_number

print_sum:
    jal itoa
    li a0, SYS_WRITE
    li a1, FD_STOUT
    mv a2, a0
    li a3, 1
    ecall

    li a0, SYS_WRITE
    li a1, FD_STOUT
    li a2, 10            # newline
    li a3, 1
    ecall

    j read_chunk

end_program:
    li a0, SYS_CLOSE
    mv a1, s0            # File descriptor
    ecall

    li a0, 0             # Exit code 0
    li a7, SYS_EXIT
    ecall
