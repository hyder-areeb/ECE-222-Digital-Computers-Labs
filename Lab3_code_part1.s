#################################################
# Name:    Lab3_Template.s                     ##
# Purpose:  Reaction Time Measurement          ##
#################################################
 
# Start of the data section
 .data      
 .align 4            # To make sure we start with 4 bytes aligned address (Not important for this one)
 SEED:
   .word 0x1234       # Put any non zero seed
   
# The main function must be initialized in that manner in order to compile properly on the board
 .text
 .globl  main
 main:
   # Put your initializations here
   li s1, 0x7ff60000       # assigns s1 with the LED base address (Could be replaced with lui s1, 0x7ff60)
   li s2, 0x7ff70000       # assigns s2 with the push buttons base address (Could be replaced with lui s2, 0x7ff70)
   
 
   li s3, 0x0              # We set the '0' into s3. We will later use this to turn the Led off
   li s4, 0x1              # We set the '1' into s4. We will later use this to turn the Led on
   li s5, 0xFF             # for masking 8 bits
 
 
   sw s3, 0(s1)            # We start by turning the led off
   jal RANDOM_NUM          # We jump to the RANDOM_NUM function which return the value in a0 
   jal SCALE               # return a0 with the value in the proper range 20k to 100k
    
    
   jal DELAY               # a0*100us delay
   sw s4, 0(s1)            # Since s4 holds the value 1, we turn on the LED
 
 
 

   jal REFLEX_TIME          # a1 is the reaction time counter
   jal DISPLAY_NUM          # Jump the procedure to display the reflex time on the leds
 
 # End of main function    
     
 
 
 #Subroutines    
 REFLEX_TIME:
  li a0, 1                 # set delay to 100us
  li a2, 14                # first button of the LED is what we're gonna press (1110)
  li a1, 0x0               # a1 is our counter that we will be incrementing
  addi sp, sp, -4          # clear space on the stack to store return address
  sw ra, 0(sp)      	   # store the return address on the stack
  counter:
    addi a1, a1, 1         # Increment the REFLEX_TIME by 1
    jal DELAY              # Call a 0.1ms delay
    lw t0, 0(s2)           # t0 stores the value memory address of the push buttoms
    bne t0, a2, counter    # Compare the value at the memory adress and the button being pushed
  lw ra, 0(sp)			   # load value from the stack
  addi sp, sp, 4		   # return the stack pointer to its original value
  jalr x0, 0(ra)           # jump back to the main method

 DELAY:
   # Insert your code here to make a delay of a0 * 100 us
   li t1, 1350            # lab 1-2 value = 1465
   mul t0, a0, t1         # calculate value of iterations of a0 * 100 us
   decrement:
     addi t0,t0,-1        # subtract counter by 1
     bne zero, t0, decrement # if counter is not 0 then keep on decrementing
   jalr x0, 0(ra)
 
 SCALE:
   srli a0, a0, 8        # shift right 8 bits in a0
   li t0, 310          
   mul a0, a0, t0        # multiply the value by 310
   
   li t1, 0              # counter to keep track of offset loop
   li t3, 10              # this value is 5 because 40000*5
   offset:
     addi a0, a0, 2000   # offset the delay value
     addi t1, t1, 1 
     bne t1, t3, offset    # offset value by 20000
  jalr x0, 0(ra)
 
 DISPLAY_NUM:
   #Insert your code here to display the 32 bits in a0 on the LEDs byte by byte (Least isgnificant byte first) with 2 seconds delay for each byte and 5 seconds for the last
   li a0, 50000        # sets 2 second delay
   mv t5,a1       
   #addi t5, t5, 0x0000
   li a3, 0
   li a4, 4
   display_loop:
     and t4,t5,s5       # Mask the least significant 8 bits from 32 bits of reaction counter
     sw t4, 0(s1)      # Display 8bits in LED
     srli t5,t5,8      # shift right by 8 bits
     addi a3,a3, 1
     jal DELAY        # add a 2 second delay in between displaying numbers
     bne a3, a4, display_loop
   
   li a0, 30000       # sets 3 second delay
   jal DELAY          # delay of (3+2)=5 seconds
   j DISPLAY_NUM      # repeatedly display the numbers
 
 
 
 RANDOM_NUM:
   # This is a provided pseudorandom number generator no need to modify it, just call it using JAL (the random number is saved at a0)
   addi sp, sp, -4        # push ra to the stack
   sw ra, 0(sp)
   
   lw t0, 0(gp)        # load the seed or the last previously generated number from the data memory to t0
   li t1, 0x8000
   and t2, t0, t1        # mask bit 16 from the seed
   li t1, 0x2000
   and t3, t0, t1        # mask bit 14 from the seed
   slli t3, t3, 2        # allign bit 14 to be at the position of bit 16
   xor t2, t2, t3        # xor bit 14 with bit 16
   li t1, 0x1000    
   and t3, t0, t1        # mask bit 13 from the seed
   slli t3, t3, 3        # allign bit 13 to be at the position of bit 16
   xor t2, t2, t3        # xor bit 13 with bit 14 and bit 16
   li t1, 0x400
   and t3, t0, t1        # mask bit 11 from the seed
   slli t3, t3, 5        # allign bit 14 to be at the position of bit 16
   xor t2, t2, t3        # xor bit 11 with bit 13, bit 14 and bit 16
   srli t2, t2, 15        # shift the xoe result to the right to be the LSB
   slli t0, t0, 1        # shift the seed to the left by 1
   or t0, t0, t2        # add the XOR result to the shifted seed 
   li t1, 0xFFFF        
   and t0, t0, t1        # clean the upper 16 bits to stay 0
   sw t0, 0(gp)        # store the generated number to the data memory to be the new seed
   mv a0, t0          # copy t0 to a0 as a0 is always the return value of any function
   
   lw ra, 0(sp)        # pop ra from the stack
   addi sp, sp, 4
   jr ra
 # Lab Report Questions


# Q1. 

# 8-bits =  ((2^8)-1)*0.0001 = 0.0255 s
# 16-bits = ((2^16)-1)*0.0001 = 6.5535 s
# 24-bits = ((2^24)-1)*0.0001 = 1677.7215 s
# 32-bits = ((2^32)-1)*0.0001 = 429496.7295 s

# Q2.
# The reaction time for humans is ~250 ms, so 16 bits would be the smallest value that works 
# for this because the largest value that you can store in 8 bits is 25 ms and the next largest
# is 16-bits
