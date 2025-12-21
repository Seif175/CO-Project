.data
msg:  .asciiz "Do you want to perform encryption/decryption using Rail Fence Cipher? (Yes or No): "
msg2: .asciiz "Enter plaintext message: "
msg3: .asciiz "Enter numeric key (number of rails ≥ 2): "
msg4: .asciiz "Generated Ciphertext: "
msg5: .asciiz "Do you want to decrypt the ciphertext? (Y/N): "
msg6: .asciiz "Decrypted Plaintext: "
msg7: .asciiz "Yes\n"
msg8: .asciiz "No\n"

buffer:.space 100
Ciphertext: .space 100

.text
.globl main

main:
    # Print main prompt
    li $v0, 4
    la $a0, msg
    syscall

    # Read a string from the user
    li $v0, 8
    la $a0, buffer
    li $a1, 100
    syscall

    la $t0, msg7        # "Yes\n"
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
    move $t0, $v0       # key (number of rails)

check_key:
    li $t4, 2
    blt $t0, $t4, invalid_key
    j start_encrypt

invalid_key:
    li $v0, 4
    la $a0, msg3        
    syscall

    li $v0, 5
    syscall
    move $t0, $v0
    j check_key

    # Encryption 
    la $t1, buffer        
    la $t2, Ciphertext   
start_encrypt:
    la $t1, buffer
    la $t2, Ciphertext
    li $t5, 0
rail_loop:
    bge $t5, $t0, encrypt_done

    la $t1, buffer
    add $t1, $t1, $t5      
read_loop:
    lb $t3, 0($t1)
    beq $t3, $zero, next_rail

    sb $t3, 0($t2)
    addi $t2, $t2, 1

    add $t1, $t1, $t0      # jump by key (rails)
    j char_loop

next_rail:
    addi $t5, $t5, 1
    j rail_loop

encrypt_done:
    sb $zero, 0($t2)   

# Print The Prompt message
    li $v0, 4
    la $a0, msg4
    syscall

    # Display the ciphertext on the console
    li $v0, 4
    la $a0, Ciphertext
    syscall

    # Ask for decryption
    li $v0, 4
    la $a0, msg5
    syscall

    # Read Yes / No for decryption
    li $v0, 8
    la $a0, buffer
    li $a1, 10
    syscall

    la $t0, msg7      # "Yes\n"
    la $t1, buffer

decrypt_compare:
    lb $t2, 0($t0)
    lb $t3, 0($t1)

    bne $t2, $t3, end_program
    beq $t2, $zero, decrypt_yes

    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j decrypt_compare

decrypt_yes:
    li $v0, 4
    la $a0, msg6
    syscall

    li $v0, 4
    la $a0, buffer
    syscall


    # Exit program
    li $v0, 10
    syscall

not_equal:
    li $v0, 10
    syscall
