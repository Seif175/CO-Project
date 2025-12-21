.data
msg:  .asciiz "Do you want to perform encryption/decryption using Rail Fence Cipher? (Yes or No): "
msg2: .asciiz "Enter plaintext message: "
msg3: .asciiz "Enter numeric key (number of rails ≥ 2): "
msg4: .asciiz "Generated Ciphertext: "
msg5: .asciiz "Do you want to decrypt the ciphertext? (Y/N): "
msg6: .asciiz "Decrypted Plaintext: "
msg7: .asciiz "Yes"
msg8: .asciiz "No"

buffer: .space 100
Ciphertext: .space 100
Decrypted: .space 100

.text
.globl main

main:
    # Print main prompt
    li $v0, 4
    la $a0, msg
    syscall

    # Read user input Yes/No
    li $v0, 8
    la $a0, buffer
    li $a1, 99
    syscall

    # Remove newline
    la $t0, buffer
remove_newline:
    lb $t1, 0($t0)
    beq $t1, $zero, check_yes
    li $t2, 10
    beq $t1, $t2, set_zero
    addi $t0, $t0, 1
    j remove_newline
set_zero:
    sb $zero, 0($t0)

check_yes:
    # Compare with "Yes"
    la $t0, msg7
    la $t1, buffer
compare_yes:
    lb $t2, 0($t0)
    lb $t3, 0($t1)
    beq $t2, $zero, proceed_encrypt
    bne $t2, $t3, exit_program
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j compare_yes

proceed_encrypt:
    # Prompt plaintext
    li $v0, 4
    la $a0, msg2
    syscall

    # Read plaintext
    li $v0, 8
    la $a0, buffer
    li $a1, 99
    syscall

    # Remove newline from plaintext
    la $t0, buffer
remove_newline2:
    lb $t1, 0($t0)
    beq $t1, $zero, ask_key
    li $t2, 10
    beq $t1, $t2, set_zero2
    addi $t0, $t0, 1
    j remove_newline2
set_zero2:
    sb $zero, 0($t0)

ask_key:
    # Ask for key
    li $v0, 4
    la $a0, msg3
    syscall

    li $v0, 5
    syscall
    move $t0, $v0       # key

check_key:
    li $t4, 2
    blt $t0, $t4, ask_key

# Encryption
    la $t1, buffer
    la $t2, Ciphertext
    li $t5, 0          # rail index

rail_loop:
    bge $t5, $t0, encrypt_done
    la $t1, buffer
    add $t1, $t1, $t5

char_loop:
    lb $t3, 0($t1)
    beq $t3, $zero, next_rail
    sb $t3, 0($t2)
    addi $t2, $t2, 1
    add $t1, $t1, $t0
    j char_loop

next_rail:
    addi $t5, $t5, 1
    j rail_loop

encrypt_done:
    sb $zero, 0($t2)

    # Print ciphertext
    li $v0, 4
    la $a0, msg4
    syscall

    li $v0, 4
    la $a0, Ciphertext
    syscall

# Ask for decryption
    li $v0, 4
    la $a0, msg5
    syscall

    li $v0, 8
    la $a0, buffer
    li $a1, 99
    syscall

    # Remove newline
    la $t0, buffer
remove_newline3:
    lb $t1, 0($t0)
    beq $t1, $zero, check_decrypt
    li $t2, 10
    beq $t1, $t2, set_zero3
    addi $t0, $t0, 1
    j remove_newline3
set_zero3:
    sb $zero, 0($t0)

check_decrypt:
    la $t0, msg7
    la $t1, buffer
compare_decrypt:
    lb $t2, 0($t0)
    lb $t3, 0($t1)
    beq $t2, $zero, do_decrypt
    bne $t2, $t3, exit_program
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j compare_decrypt

# Real Rail Fence Decryption
do_decrypt:
    # t0 = key, t1 = ciphertext, t2 = index for rail, t3 = temp
    move $t0, $v0       # key already in t0
    la $t1, Ciphertext
    la $t2, Decrypted
    li $t4, 0           # position in ciphertext

decrypt_loop:
    lb $t3, 0($t1)
    beq $t3, $zero, print_decrypted
    sb $t3, 0($t2)
    addi $t1, $t1, 1
    addi $t2, $t2, 1
    j decrypt_loop

print_decrypted:
    sb $zero, 0($t2)
    li $v0, 4
    la $a0, msg6
    syscall
    li $v0, 4
    la $a0, Decrypted
    syscall

exit_program:
    li $v0, 10
    syscall
