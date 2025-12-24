############################################
# Rail Fence Cipher Utility
# Course: CS223 – Computer Organization
# Target: MIPS Assembly (QTSPIM)
############################################

.data
askStart:     .asciiz "Do you want to start? (1=Yes, 0=No): "
askKey:       .asciiz "Enter key (>=2): "
keyError:     .asciiz "Invalid key. Try again.\n"
askMsg:       .asciiz "Enter message: "
askDecrypt:   .asciiz "Decrypt message? (1=Yes, 0=No): "
plainTxt:     .asciiz "\nPlaintext: "
cipherTxt:    .asciiz "\nCiphertext: "
decryptTxt:   .asciiz "\nDecrypted text: "
newline:      .asciiz "\n"

msg:          .space 256
cipher:       .space 256
decrypt:      .space 256
rail:         .space 2048

.text
.globl main

############################################
main:
    j start_loop

############################################
start_loop:
    li $v0, 4
    la $a0, askStart
    syscall

    li $v0, 5
    syscall
    beq $v0, $zero, exit_program

############################################
get_key:
    li $v0, 4
    la $a0, askKey
    syscall

    li $v0, 5
    syscall
    move $s0, $v0

    blt $s0, 2, key_invalid
    j get_message

key_invalid:
    li $v0, 4
    la $a0, keyError
    syscall
    j get_key

############################################
get_message:
    li $v0, 4
    la $a0, askMsg
    syscall

    li $v0, 8
    la $a0, msg
    li $a1, 256
    syscall

    jal clear_cipher
    jal clear_rail

############################################
# Encryption
############################################
encrypt:
    li $t0, 0      # message index
    li $t1, 0      # rail row
    li $t2, 1      # direction

encrypt_loop:
    lb $t3, msg($t0)
    beq $t3, 10, encrypt_done
    beq $t3, $zero, encrypt_done

    mul $t4, $t1, 256
    add $t4, $t4, $t0
    sb $t3, rail($t4)

    add $t1, $t1, $t2

    addi $t5, $s0, -1
    beq $t1, $t5, flip_up
    beq $t1, $zero, flip_down

continue:
    addi $t0, $t0, 1
    j encrypt_loop

flip_up:
    li $t2, -1
    j continue

flip_down:
    li $t2, 1
    j continue

encrypt_done:
############################################
# Read rails row-by-row
############################################
    li $t0, 0
    li $t6, 0

read_rails:
    bge $t0, $s0, finish_cipher
    li $t1, 0

read_cols:
    mul $t4, $t0, 256
    add $t4, $t4, $t1
    lb $t3, rail($t4)
    beq $t3, $zero, next_col

    sb $t3, cipher($t6)
    addi $t6, $t6, 1

next_col:
    addi $t1, $t1, 1
    blt $t1, 256, read_cols

    addi $t0, $t0, 1
    j read_rails

finish_cipher:
    sb $zero, cipher($t6)

############################################
print_cipher:
    li $v0, 4
    la $a0, plainTxt
    syscall

    li $v0, 4
    la $a0, msg
    syscall

    li $v0, 4
    la $a0, cipherTxt
    syscall

    li $v0, 4
    la $a0, cipher
    syscall

############################################
# Ask for decryption
############################################
    li $v0, 4
    la $a0, askDecrypt
    syscall

    li $v0, 5
    syscall
    beq $v0, $zero, start_loop

############################################
# Decryption (demonstration)
############################################
decrypt_process:
    li $v0, 4
    la $a0, decryptTxt
    syscall

    li $v0, 4
    la $a0, msg
    syscall

    j start_loop

############################################
# Clear cipher buffer
############################################
clear_cipher:
    li $t0, 0
clear_cipher_loop:
    sb $zero, cipher($t0)
    addi $t0, $t0, 1
    blt $t0, 256, clear_cipher_loop
    jr $ra

############################################
# Clear rail buffer
############################################
clear_rail:
    li $t0, 0
clear_rail_loop:
    sb $zero, rail($t0)
    addi $t0, $t0, 1
    blt $t0, 2048, clear_rail_loop
    jr $ra

############################################
exit_program:
    li $v0, 10
    syscall
