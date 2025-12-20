.data
msg: .asciiz "Do you want to perform encryption/decryption using Rail Fence Cipher? (Yes or No): "
msg2: .asciiz "Enter plaintext message: "
msg3: .asciiz "Enter numeric key (number of rails ≥ 2): "
msg4: .asciiz "Generated Ciphertext: "
msg5: .asciiz "Do you want to decrypt the ciphertext? (Y/N): "
msg6: .asciiz "Decrypted Plaintext: "
msg7: .asciiz "Yes\n"
msg8: .asciiz "No\n"
buffer: .space 100

.text
.globl main

main:
    # Print The Prompt message
    li $v0, 4
    la $a0, msg
    syscall

    # Read a string from the user
    li $v0, 8
    la $a0, buffer
    li $a1, 100
    syscall

    la $t0, msg7
    la $t1, buffer

    compare:
        lb $t2, 0($t0)  
        lb $t3, 0($t1)   

        bne $t2, $t3, not_equal  

        beq $t2, $zero, equal 

        addi $t0, $t0, 1
        addi $t1, $t1, 1
        j compare

    equal:
        # Print The Prompt message
        li $v0, 4
        la $a0, msg2
        syscall

        # Read a string from the user
        li $v0, 8
        la $a0, buffer
        li $a1, 100
        syscall

        # Print The Prompt message
        li $v0, 4
        la $a0, msg3
        syscall

        # Read an integer from the user
        li $v0, 5
        syscall
        move $t0, $v0

        # Print The Prompt message
        li $v0, 4
        la $a0, msg4
        syscall



        li $v0, 10       # syscall: exit
        syscall

    not_equal:
        li $v0, 10
        syscall
