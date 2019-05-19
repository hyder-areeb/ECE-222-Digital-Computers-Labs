##################################################
## Name:    Lab1_Template.s  					##
## Purpose:	A Template for flashing LED 		##
##################################################

# The main function must be initialized in that manner in order to compile properly on the board
.text
.globl	main
main:
	# Put your initializations here
	lui s1, 0x7ff60 			# assigns s1 with the LED base address (Could be replaced with lui s1, 0x7ff60)
	li s6, 0x3FFFFF				# Store the counter value in register S6.
	addi s2, zero, 0x00 		# Initialize value to set LED to 00
	sw s2, 0(s1)				# Initialize the LED with value stored in s2
	add s3, zero, s6			# sets the counter max, you need to change that number to make the 500ms delay
    li s5, 0x1					# store the value with which we will xor to toggle the LED
    # an infinite loop, almost needed in any embedded systems code
	while_1:
		# You might write some code here
		decrement:
            addi s3, s3, -1			# decrement counter by one
		bne s3, zero, decrement # If counter != 0, then keep on decrementing
		#when counter == 0
        add s3, zero, s6	# restore counter value s3
        xor s2, s2, s5		# toggle the LED ending bits
		sw s2, 0(s1)		# store new value in LED

        
            
		# You might write some code here 
		# Also you might write another delay routine if using the long flowchart given in the lab manual
		
		
		j while_1				# j label is a pseudo-instruction equivalent to beq x0,x0,label
