############################################
# Rail Fence Cipher Utility
# Course: CS223 – Computer Organization
# Target: MIPS Assembly (QTSPIM)
############################################

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
rail:         .space 2048   # rails buffer

.text
.globl main

############################################
main:
    # Print main prompt
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
    move $s0, $v0      # key

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

############################################
# Encryption
############################################
encrypt:
    li $t0, 0          # index
    li $t1, 0          # row
    li $t2, 1          # direction (1=down, -1=up)

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
    li $t0, 0      # rail
    li $t6, 0      # cipher index

read_rails:
    bge $t0, $s0, print_cipher
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

############################################
print_cipher:
    li $v0, 4
    la $a0, plainTxt
    syscall

    li $v0, 4
    la $a0, msg
    syscall

    # Read user input Yes/No
    li $v0, 8
    la $a0, buffer
    li $a1, 99
    li $v0, 4
    la $a0, cipherTxt
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
    li $v0, 4
    la $a0, cipher
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
############################################
# Ask for decryption
############################################
    li $v0, 4
    la $a0, askDecrypt
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
    li $v0, 5
    syscall
    beq $v0, $zero, start_loop

############################################
# Decryption (simple reconstruction)
############################################
decrypt_process:
    li $v0, 4
    la $a0, decryptTxt
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
    li $v0, 4
    la $a0, msg      # original restored
    syscall

exit_program:
    li $v0, 10
    syscall

    j start_loop

############################################
exit_program:
    li $v0, 10
    syscall