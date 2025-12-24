############################################
# Rail Fence Cipher Utility (with Decryption)
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

    jal clear_cipher    # Clear cipher buffer
    jal clear_rail      # Clear rail buffer
    jal encrypt         # Encrypt immediately
    j print_cipher

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

continue_encrypt:
    addi $t0, $t0, 1
    j encrypt_loop

flip_up:
    li $t2, -1
    j continue_encrypt

flip_down:
    li $t2, 1
    j continue_encrypt

encrypt_done:
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
    jr $ra

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

    jal clear_decrypt   # Clear decrypt buffer
    jal decrypt_process # Call decryption
    j start_loop

############################################
# Decryption routine
############################################
decrypt_process:
    li $v0, 4
    la $a0, decryptTxt
    syscall

    # Step 1: Mark zig-zag pattern
    li $t0, 0
    li $t1, 0
    li $t2, 1
    li $t8, 0

mark_pattern:
    lb $t3, cipher($t0)
    beq $t3, $zero, fill_rails
    sb $t1, rail($t8)
    addi $t0, $t0, 1
    addi $t8, $t8, 1

    add $t1, $t1, $t2
    addi $t5, $s0, -1
    beq $t1, $t5, flip_up2
    beq $t1, $zero, flip_down2
    j mark_pattern

flip_up2:
    li $t2, -1
    j mark_pattern

flip_down2:
    li $t2, 1
    j mark_pattern

# Step 2: Fill rails row by row
fill_rails:
    li $t0, 0
    li $t6, 0

fill_loop:
    lb $t3, rail($t6)
    lb $t4, cipher($t0)
    sb $t4, decrypt($t6)
    addi $t0, $t0, 1
    addi $t6, $t6, 1
    lb $t5, cipher($t0)
    bnez $t5, fill_loop

# Step 3: Reconstruct plaintext zig-zag
    li $t0, 0
    li $t1, 0
    li $t2, 1

reconstruct_loop:
    lb $t3, rail($t0)
    beq $t3, $zero, reconstruct_done
    lb $t4, decrypt($t0)
    sb $t4, msg($t0)

    add $t1, $t1, $t2
    addi $t5, $s0, -1
    beq $t1, $t5, flip_up3
    beq $t1, $zero, flip_down3

    addi $t0, $t0, 1
    j reconstruct_loop

flip_up3:
    li $t2, -1
    j reconstruct_loop

flip_down3:
    li $t2, 1
    j reconstruct_loop

reconstruct_done:
    li $v0, 4
    la $a0, msg
    syscall
    jr $ra

############################################
# Clear buffers
############################################
clear_cipher:
    li $t0, 0
clear_cipher_loop:
    sb $zero, cipher($t0)
    addi $t0, $t0, 1
    blt $t0, 256, clear_cipher_loop
    jr $ra

clear_rail:
    li $t0, 0
clear_rail_loop:
    sb $zero, rail($t0)
    addi $t0, $t0, 1
    blt $t0, 2048, clear_rail_loop
    jr $ra

clear_decrypt:
    li $t0, 0
clear_decrypt_loop:
    sb $zero, decrypt($t0)
    addi $t0, $t0, 1
    blt $t0, 256, clear_decrypt_loop
    jr $ra

############################################
exit_program:
    li $v0, 10
    syscall
