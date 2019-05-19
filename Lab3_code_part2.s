##################################################
## Name:    Lab3_Template.s  					##
## Purpose:	Reaction Time Measurement	 		##
##################################################

# Start of the data section
.data			
.align 4						# To make sure we start with 4 bytes aligned address (Not important for this one)
SEED:
	.word 0x1234				# Put any non zero seed
	
# The main function must be initialized in that manner in order to compile properly on the board
.text
.global	main
main:
	# Put your initializations here
	li s1, 0x7ff60000 			# assigns s1 with the LED base address (Could be replaced with lui s1, 0x7ff60)
	li s2, 0x7ff70000 			# assigns s2 with the push buttons base address (Could be replaced with lui s2, 0x7ff70)

	li a5, 0xFF				# a5 is set to the value of 255
	
	li a0, 0x3E8
	li t6, 0x0	
	counter:
		addi t6, t6, 1
		sw t6, 0(s1)
		jal DELAY
		bne t6, a5, counter
		li t6, 0x0
		j counter

	
	
	
	
# End of main function		
		







# Subroutines			
 DELAY:
   # Insert your code here to make a delay of a0 * 100 us
   li t1, 1350            # lab 1-2 value = 1465
   mul t0, a0, t1         # calculate value of iterations of a0 * 100 us
   decrement:
     addi t0,t0,-1        # subtract counter by 1
     bne zero, t0, decrement # if counter is not 0 then keep on decrementing
   jalr x0, 0(ra)
