##################################################
## Name:    Lab2_Template.s            ##
## Purpose:  Morse Code Transmitter         ##
##################################################

# Start of the data section
.data      
.align 4            # To make sure we start with 4 bytes aligned address (Not important for this one)
InputLUT:            
  # Use the following line only with the board
  .ascii "SOS"        # Put the 5 Letters here instead of ABCDE
  
  # Use the following 2 lines only on Venus simulator
  #.asciiz "AQAHX"    # Put the 5 Letters here instead of ABCDE  
  #.asciiz "X"        # Leave it as it is. It's used to make sure we are 4 bytes aligned  (as Venus doesn't have the .align directive)

.align 4             # To make sure we start with 4 bytes aligned address (This one is Important)
MorseLUT:
  .word 0xE800
  .word 0xAB80
  .word 0xBAE0
  .word 0xAE00
  .word 0x8000
  .word 0xBA80
  .word 0xBB80
  .word 0xAA00
  .word 0xA000
  .word 0xEEE8
  .word 0xEB80
  .word 0xAE80
  .word 0xEE00
  .word 0xB800
  .word 0xEEE0
  .word 0xBBA0
  .word 0xEBB8
  .word 0xBA00
  .word 0xA800
  .word 0xE000
  .word 0xEA00
  .word 0xEA80
  .word 0xEE80
  .word 0xEAE0
  .word 0xEEB8
  .word 0xAEE0



# The main function must be initialized in that manner in order to compile properly on the board
.text
.globl  main
main:
  # Put your initializations here
  li s1, 0x7ff60000      # assigns s1 with the LED base address (Could be replaced with lui s1, 0x7ff60)
  li s2, 0x01            # assigns s2 with the value 1 to be used to turn the LED on
  la s3, InputLUT        # assigns s3 with the InputLUT base address
  la s4, MorseLUT        # assigns s4 with the MorseLUT base address
  li s6, 0x3FFFFF        # Store the 500ms counter value in s6
  sw zero, 0(s1)         # Turn the LED off
    
    ResetLUT:
    mv s5, s3            # assigns s5 to the address of the first byte  in the InputLUT

  NextChar:
    lbu a0, 0(s5)              # loads one byte from the InputLUT
    addi s5, s5, 1             # increases the index for the InputLUT (For future loads)
    bne a0, zero, ProcessChar  # if char is not NULL, jumps to ProcessChar
    # If we reached the end of the 5 letters, we start again
    li a0, 4                   # delay 4 extra spaces (7 total) between words to terminate
    jal DELAY        
    j ResetLUT                 # start again

  ProcessChar:
    jal CHAR2MORSE     		   # convert ASCII to Morse pattern in a0  
 jal  ra, RemoveZeros		   # Remove the zeroes at ending of the pattern
 mv a1, a0     				   # storing morse pattern into a different register
 jal ra, Shift_and_display     # jump to procedure to display the character

  RemoveZeros:
    # Write your code here to remove trailling zeroes until you reach a one
 shift_rem:
 andi t1,a0, 0x01 			   # t1 = last bit of a0
 bne t1, zero, return_rem
    srli a0, a0, 1
 j shift_rem
 return_rem:
 jr ra
  
  Shift_and_display:
    # Write your code here to peel off one bit at a time and turn the light on or off as necessary
    shift: 
  andi t1, a1, 0x01           # t1 = last bit of a0
  srli a1, a1, 1              # shift bits in a0 by 1 for next iteration
  bne t1, zero, turn_on      # if bit is 0 then turn off the led
  turn_off:
   jal ra, LED_OFF
   j delay
   
  turn_on:
   jal ra, LED_ON
   
	# Delay after the LED has been turned on or off
	delay:
	  addi a0, zero, 1
	  jal ra, DELAY

	# Test if all bits are shifted
	# If we're not done then loop back to Shift_and_display to shift the next bit
	beq a1, zero, return
	j shift
	# If we're done then branch back to get the next character
 return:
 jal ra, LED_OFF
 addi a0, zero, 3
 jal ra, DELAY
 j NextChar
# End of main function    
    







# Subroutines
LED_OFF:
  # Insert your code here to turn LED off
  sw zero, 0(s1) # set value of memory which is pointed to by s1 to zero
  jr ra

  
LED_ON:
  # Insert your code here to turn LED on
  sw s2, 0(s1) # set value of memory which is pointed to by s1 to s2
  jr ra


DELAY:
  # Insert your code here to make a delay of a0 * 500ms
  mul t0, a0, s6 # calculate value of iterations of a0 * 500ms
  decrement:
  addi t0,t0,-1  # subtract counter by 1
  bne zero, t0, decrement # if counter is not 0 then keep on decrementing
  jr ra


CHAR2MORSE:
  # Insert your code here to convert the ASCII code to an index and lookup the Morse pattern in the Lookup Table
  addi a0, a0, -65 # to get index of MorseLUT
li t0, 4
  mul a0, a0, t0   # multiply by 4 because of byte addressable memory
add t0, a0, s4   # get actual address where morse code is stored
lw a0, 0(t0)     # store in a0 the morse code
  jr ra
