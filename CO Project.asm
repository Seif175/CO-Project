############################################
# Rail Fence Cipher (Encrypt + Decrypt)
# Course: CS223 – Computer Organization
# Target: MIPS Assembly (QTSPIM)
############################################

.data
askStart:      .asciiz "Do you want to start? (1=Yes, 0=No): "
askKey:        .asciiz "Enter key (>=2): "
keyError:      .asciiz "Invalid key. Try again.\n"
askMsg:        .asciiz "Enter message: "
askDecrypt:    .asciiz "Decrypt message? (1=Yes, 0=No): "
invalidChoice: .asciiz "Invalid choice. Please enter 0 or 1.\n"

plainTxt:   .asciiz "\nPlaintext: "
cipherTxt:  .asciiz "\nCiphertext: "
decryptTxt: .asciiz "\nDecrypted text: "

msg:        .space 256
cipher:     .space 256
decrypt:    .space 256
rail:       .space 256        # rail index per char
choiceBuf:  .space 4

.text
.globl main

############################################
main:
    j start_loop

############################################
# Start (0 / 1 validation)
############################################
start_loop:
    li $v0, 4
    la $a0, askStart
    syscall

    li $v0, 8
    la $a0, choiceBuf
    li $a1, 4
    syscall

    lb $t0, choiceBuf
    lb $t1, choiceBuf+1
    bne $t1, 10, invalid_start

    beq $t0, '0', exit_program
    beq $t0, '1', get_key

invalid_start:
    li $v0, 4
    la $a0, invalidChoice
    syscall
    j start_loop

############################################
# Get key
############################################
get_key:
    li $v0, 4
    la $a0, askKey
    syscall

    li $v0, 5
    syscall
    move $s0, $v0

    blt $s0, 2, bad_key
    j get_message

bad_key:
    li $v0, 4
    la $a0, keyError
    syscall
    j get_key

############################################
# Get message
############################################
get_message:
    li $v0, 4
    la $a0, askMsg
    syscall

    li $v0, 8
    la $a0, msg
    li $a1, 256
    syscall

    jal encrypt
    j print_encrypt

############################################
# Encryption
############################################
encrypt:
    li $t0, 0      # index
    li $t1, 0      # rail
    li $t2, 1      # direction

enc_loop:
    lb $t3, msg($t0)
    beq $t3, 10, enc_done
    beq $t3, $zero, enc_done

    sb $t3, decrypt($t0)
    sb $t1, rail($t0)

    add $t1, $t1, $t2
    addi $t4, $s0, -1
    beq $t1, $t4, flip_up
    beq $t1, $zero, flip_down

cont_enc:
    addi $t0, $t0, 1
    j enc_loop

flip_up:
    li $t2, -1
    j cont_enc

flip_down:
    li $t2, 1
    j cont_enc

enc_done:
    move $s1, $t0    # message length

    li $t0, 0
    li $t5, 0

read_rows:
    bge $t0, $s0, end_enc
    li $t1, 0

read_cols:
    bge $t1, $s1, next_row
    lb $t2, rail($t1)
    bne $t2, $t0, skip_col

    lb $t3, decrypt($t1)
    sb $t3, cipher($t5)
    addi $t5, $t5, 1

skip_col:
    addi $t1, $t1, 1
    j read_cols

next_row:
    addi $t0, $t0, 1
    j read_rows

end_enc:
    sb $zero, cipher($t5)
    jr $ra

############################################
# Print encryption
############################################
print_encrypt:
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
# Ask decrypt
############################################
ask_decrypt_loop:
    li $v0, 4
    la $a0, askDecrypt
    syscall

    li $v0, 8
    la $a0, choiceBuf
    li $a1, 4
    syscall

    lb $t0, choiceBuf
    lb $t1, choiceBuf+1
    bne $t1, 10, bad_decrypt

    beq $t0, '0', start_loop
    beq $t0, '1', decrypt_process

bad_decrypt:
    li $v0, 4
    la $a0, invalidChoice
    syscall
    j ask_decrypt_loop

############################################
# Decryption (CORRECT)
############################################
decrypt_process:
    li $t0, 0
    li $t4, 0

fill_rows_dec:
    bge $t0, $s0, reconstruct
    li $t1, 0

fill_cols_dec:
    bge $t1, $s1, next_row_dec
    lb $t2, rail($t1)
    bne $t2, $t0, skip_fill_dec

    lb $t3, cipher($t4)
    sb $t3, decrypt($t1)
    addi $t4, $t4, 1

skip_fill_dec:
    addi $t1, $t1, 1
    j fill_cols_dec

next_row_dec:
    addi $t0, $t0, 1
    j fill_rows_dec

############################################
# Reconstruct plaintext
############################################
reconstruct:
    li $t0, 0
recon_loop:
    bge $t0, $s1, end_dec
    lb $t1, decrypt($t0)
    sb $t1, msg($t0)
    addi $t0, $t0, 1
    j recon_loop

end_dec:
    sb $zero, msg($t0)

    li $v0, 4
    la $a0, decryptTxt
    syscall

    li $v0, 4
    la $a0, msg
    syscall

    j start_loop

############################################
exit_program:
    li $v0, 10
    syscall
