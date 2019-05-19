##################################################
## Name:    Lab4_Template.s  					##
## Purpose:	Interrupt Handling			 		##
##################################################

# Start of the data section
.data			
.align 4						# To make sure we start with 4 bytes aligned address (Not important for this one)
SEED:
	.word 0x1234				# Put any non zero seed
	
# The main function must be initialized in that manner in order to compile properly on the board
.text
.globl	main
main:
	# Put your initializations here
	li s0, 0					# Initializes s0 to be 0
	li s1, 0x7ff60000 			# assigns s1 with the LED base address (Could be replaced with lui s1, 0x7ff60)
	li s2, 0x7ff70000 			# assigns s2 with the push buttons base address (Could be replaced with lui s2, 0x7ff70)
	li s3, 0x4					# Push button two
	li s4, 0xFF
	li s5, 0x0
	# Enabling Interrupts from core side
	csrrsi zero, mstatus, 0x08 	#enable global interrupt
	csrrsi zero, 0x7C0, 0x02 	#enable push button interrupt line from core side	
	
	# Enable a specific push button interrupt from the PIO side (Check Appendix B)
	sw s3, 8(s2)
	li a1, 5		# 0.5 second delay
	# Write your functional code here
	FLASH:
		sw s5, 0(s1)
		jal DELAY
		xor s5, s5, s4
		jal RANDOM_NUM
		mv s7, a0
		beq s0,zero, FLASH
		bne s0, zero, DISPLAY
		
DISPLAY:
	li a1, 10 	# 1 second delay
	# Display the number in s0 until it becomes 0
	
	DISPLAY_NUM:
		sw s0, 0(s1)
		addi s0, s0, -10
		jal DELAY
		bge s0, zero, DISPLAY_NUM					
		li s0, 0					# set s0 back to 0 so that flash starts working again
		beq zero, zero, FLASH
# End of main function		




# Subroutines
DELAY:
   # Insert your code here to make a delay of a1 * 0.1 s
   li t1, 1331000            # lab 1-2 value = 1465
   mul t0, a1, t1         # calculate value of iterations of a1 * 0.1s
   decrement:
     addi t0,t0,-1        # subtract counter by 1
     bne zero, t0, decrement # if counter is not 0 then keep on decrementing
   jalr x0, 0(ra)

RANDOM_NUM:
	# This is a provided pseudo-random number generator no need to modify it, just call it using JAL (the random number is saved at a0)
	addi sp, sp, -4				# push ra to the stack
	sw ra, 0(sp)
	
	lw t0, 0(gp)				# load the seed or the last previously generated number from the data memory to t0
	li t1, 0x8000
	and t2, t0, t1				# mask bit 16 from the seed
	li t1, 0x2000
	and t3, t0, t1				# mask bit 14 from the seed
	slli t3, t3, 2				# allign bit 14 to be at the position of bit 16
	xor t2, t2, t3				# xor bit 14 with bit 16
	li t1, 0x1000		
	and t3, t0, t1				# mask bit 13 from the seed
	slli t3, t3, 3				# allign bit 13 to be at the position of bit 16
	xor t2, t2, t3				# xor bit 13 with bit 14 and bit 16
	li t1, 0x400
	and t3, t0, t1				# mask bit 11 from the seed
	slli t3, t3, 5				# allign bit 14 to be at the position of bit 16
	xor t2, t2, t3				# xor bit 11 with bit 13, bit 14 and bit 16
	srli t2, t2, 15				# shift the xoe result to the right to be the LSB
	slli t0, t0, 1				# shift the seed to the left by 1
	or t0, t0, t2				# add the XOR result to the shifted seed 
	li t1, 0xFFFF				
	and t0, t0, t1				# clean the upper 16 bits to stay 0
	sw t0, 0(gp)				# store the generated number to the data memory to be the new seed
	mv a0, t0					# copy t0 to a0 as a0 is always the return value of any function
	
	lw ra, 0(sp)				# pop ra from the stack
	addi sp, sp, 4
	jr ra

SCALE_VALUE:
	srli a0, a0, 10 # mask the upper 10 bits of 16 bit random number
	li t0, 3
	mul a0, a0, t0 # 63 * 3 = ~200
	addi a0, a0, 50
	jr ra
# Interrupt Service Routine
.text
.globl	isr
isr:
	addi sp, sp, -4
	sw ra, 0(sp)
	# De-bouncing (Due to the bouncing of mechanical switches, we need to de-bounce it to avoid entering the ISR many times for the same button press)
	li t1, 2000000
	debounce:
		addi t1, t1, -1
		bne t1, zero, debounce
		
	# Generate a number from 50 t0 255 and put it in S0	(You shouldn't call the RANDOM_NUM here, you should have called it in the main already and saved it in some register, you just need to make it fit the 50-255 requirement and save it to s0)
	mv a0, s7
	jal SCALE_VALUE #a0 has the scaled value
	mv s0, a0
	# s7 has scaled value
	#Clear push button interrupt PIO side to acknowledge handling the interrupt
	sw s3, 12(s2)
	# Wait until store takes place and read by the PIO
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	lw ra, 0(sp)
	addi sp, sp, 4
	mret					#return from interrupt

