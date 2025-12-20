.data
msg: .asciiz "ttttt\n"

.text
.globl main

main:
    li $v0, 4        # syscall: print string
    la $a0, msg     # load address of msg
    syscall

    li $v0, 10       # syscall: exit
    syscall
