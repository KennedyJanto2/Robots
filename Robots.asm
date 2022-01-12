####################################################################################
# Program: Robots final project  	          Programmer: Kennedy Janto
# Due Date: Dec 9, 2021			          Course: CS2640
####################################################################################
# Overall Program Functional Description:
#	Robot game that has a player that can move around a board to avoid obstacles
#	
#	NOTES TO PROFESSOR:
#	PHASE 1 AND 2 COMPLETED. user can move player in all direction required. 
#       click "j" after starting game to show player. If player touch
#	wall or robot, it dies and game ends. Board prints correctly
#
#       PHASE 3 PARTIALLY COMPLETED. All 20 robots are placed but they 
#	do not move toward player. They still kill player if touched.
#	Pause button works.
####################################################################################
# Register usage in Main:
# $v0 -- return variable.
# $a0 -- pass parameter
# $t0-$t8 -- holds temp variable
# $s5 -- holds robot lives
####################################################################################
# Pseudocode Description:
##	1. seeds the random number generator
#	2. Call initBoard to setup my board
#	3. Call addWalls to place wall at random place 
#	4. Call placeObj to place player
#	5. Adds 20 robots to the game 
#	6. Print message and ask player for movement input
#	7. Main loop
#		7a. each char entered from user corresponds to its correct movement
#		7b. prints board after movement
#	8. if player hit wall or robot, game over
#	9. If user enter q quit game	
#
###################################################################################
	    .globl main
	    .data
wid:        .word 39    # Length of one row, must be 4n - 1
hgt:        .word 30    # Number of rows
linelen:    .word 40    # wid + 1
boardlen:   .word 1200  # linelen * hgt
numwalls:   .word 50
byte:	    .word 4
numrobots:  .word 20    #How many robots to add to the game
numalive:   .word 20
offset:     .word 16
board:      .space 1204 # Extra space for the 0, yet still be aligned.	
buffer:     .space 4    # To hold player's move
object:     .space 340
hashtag:    .byte 35    # "#"
dollar:	    .byte 36	# "$"
X:	    .byte 88    # "X"
dot:	    .byte 46    #  "."
rubble:	    .byte 64	# "@"
newline:    .byte 10	# "\n"
zero:	    .byte 0	# "0"
space:	    .asciiz " "
seedQ:      .asciiz "Please enter a random seed: "
msg1: 	   .asciiz "u - move up, d - move down, i - move left, r - move right, p - pause, j - jump to a random location \n"
msg2:	   .asciiz "Please enter your movement: "
msg3:	   .asciiz "You hit a wall! \n\n"
msg4:	   .asciiz "You hit a robot! \n\n"	
msg5:	   .asciiz "GAME OVER"
msg6:	   .asciiz "You win!"
	    .align 2
	    .text    
main:
	la   $a0, seedQ	#ask for random seed
	li   $v0, 4
	syscall
	li   $v0, 5	#gets random seed from user
	syscall
	move $a0, $v0	#pass random seed as input
	jal  seedrand	#calls random seed

	jal initBoard	#calls initBoard function
	jal addWalls	#calls addWalls function
	
	
	#Add player to board by passing 1 to placeObj()
	move $a0, $zero		#set index to 0
	move $a1, $zero		#set type to 0
	addi $a1, $a1, 1	#Set type to 1 for player
	jal placeobj
	move $a0, $zero		#set index to 0
	jal moveJ		
	
	li $t8, 0 		#set loop counter to zero	

AddingRobot:	#loop to add robot
	addi $t8, $t8, 1 	#increment loop counter	
	move $a0, $zero		#set index to 0
	li $a1, 2		#Set type to 2 for robot
	jal placeobj
	move $a0, $zero		#set index to 0
	jal drawobj
	bne $t8, 20, AddingRobot #If not equal to 20, loop back	
	jal PrintBoard
	lw $s5, numalive	#set up counter for robot lives	
	
	#Ask user for movement (9)
	li $v0, 4
	la $a0, newline		#print newline
	syscall
	
	li $v0, 4     	 	
  	la $a0, msg1  		#print out options of movement
	syscall
		
	li $v0, 4
	la $a0, newline
	syscall 	
	
	move $a0, $zero		#set index to 0
	jal moveJ
mainLoop:		
	li $v0, 4     	 	
  	la $a0, msg2  		#ask user for movement input
	syscall	
				
	li $v0, 12   		#reads input
	syscall
		
	move $t8, $v0		#move user input to t8
	li $v0, 4     	 	
  	la $a0, newline		#print new line  	
	syscall	

moveUp:		
	bne $t8, 117, moveDown  #if input not "u", skip next
	move $a0, $zero		#set index to 0
	jal eraseobj
	move $a0, $zero		#set index to 0		
	jal moveN
	jal checkmove
	move $a0, $zero		#set index to 0		
	jal drawobj
	j PrintAfter

moveDown:			
	bne $t8, 100, moveLeft	#If input not "d", skip next
	move $a0, $zero		#set index to 0
	jal eraseobj
	move $a0, $zero		#set index to 0
	jal moveS
	jal checkmove	
	move $a0, $zero		#set index to 0	
	jal drawobj
	j PrintAfter

moveLeft:	
	bne $t8, 108, moveRight	#If input not "l", skip next
	move $a0, $zero		#set index to 0
	jal eraseobj
	move $a0, $zero		#set index to 0
	jal moveW
	jal checkmove	
	move $a0, $zero		#set index to 0		
	jal drawobj
	j PrintAfter

moveRight:
	bne $t8, 114, moveJump	#If input not "r", skip next
	move $a0, $zero		#set index to 0 
	jal eraseobj
	move $a0, $zero		#set index to 0
	jal moveE
	jal checkmove
	move $a0, $zero		#set index to 0		
	jal drawobj
	j PrintAfter

moveJump:
	bne $t8, 106, Pause	#If input not "j", skip next
	move $a0, $zero		#set index to 0
	jal eraseobj
	move $a0, $zero		#set index to 0
	jal moveJ
	move $a0, $zero		#set index to 0				
	jal drawobj
	j PrintAfter
	
Pause:
	bne $t8, 112, QuitGame #If input not "p", skip next
	j PrintAfter
	
QuitGame:	
	bne $t8, 113, mainLoop #If input not any above, ask again
	j Exit3
	
checkmove:
	addiu $sp, $sp, -4 	#push stack down
	sw $ra, 0($sp)		#Save the return address on the stack
	move $a0, $zero		#set index to 0
	jal whatthere
	lw $ra, 0($sp)	   	#Restore the return address	
	addiu $sp, $sp, 4  	#restore stack pointer
	jr $ra
	
PrintAfter:	
	#Robot movement 
	li $t8, 0	 	#set loop counter to 0
	move $a0, $zero		#set index to 0
	lw $t7, offset		#Load our offset to correct index (10h)	
MoveRobotLoop:
	addi $t8, $t8, 1 	#increment loop counter
	mult $t7, $t8		#Correct the offset by 16 (10h)
	mflo $a0           	#a0 holds index to be passed
	jal moveRobot
	beq $v0, 1, Exit2
	bne $t8, 20 MoveRobotLoop #If not equal to 20, loop back	

	jal PrintBoard
	j mainLoop 		#loop back whole main loop
	
Exit:	#hit a wall
	li $v0, 4     	 		
  	la $a0, msg3  		#tell player they hit a wall	
	syscall
	li $v0, 4     	 		
  	la $a0, msg5  		#print game over	
	syscall
	li, $v0, 10		#finishes program
	syscall
Exit2:	#hit a robot
	li $v0, 4     	 		
  	la $a0, msg4  		#tell player they hit a robot
	syscall
	li $v0, 4     	 	
  	la $a0, msg5  		#print game over
	syscall
	li, $v0, 10		#finishes program
	syscall	
Exit3:	#quit game
	li $v0, 4     	 	
  	la $a0, msg5  		#print game over
	syscall
	li, $v0, 10		#finishes program
	syscall
Win: 	#all robots die
	li $v0, 4     	 		
  	la $a0, msg6  		#print win statement	
	syscall
	li, $v0, 10		#finishes program
	syscall	
	
PrintBoard:
	la $a0, board		#prints board
	li $v0, 4
	syscall
	la $a0, newline		#prints newline
	li $v0, 4
	syscall
	jr $ra
	
#########################################################
#-----------------PHASE 1-------------------------------#
#########################################################

########################################################################
# Function Name: initBoard
########################################################################
# Functional Description:
#    This routine initializes the board.  This will be a 2D array in
#    row-order.  The edges of the board will all be Wall characters ('#'),
#    and the center will be filled with '.'.  At the end of each row
#    will be a newline, and at the end of the array will be a 0 to terminate
#    the string.
#
########################################################################
# Register Usage in the Function:
#    -- This is a leaf function, so we don't need to save the $ra
#    -- register, and we are free to use any of the $t registers.
#    $t0 -- Pointer into the board
#    $t1 -- Value we are going to place on the board
#    $t7, $t8 -- Loop counters for the different loops we are forming.
#    
#    -- Note: we need to place 4 different characters at various places
#    -- of the board: #, ., newline, and 0.  We can store these four
#    -- values into different $t registers at the start of the routine.
########################################################################
# Algorithmic Description in Pseudocode:
#    Note: In the following, we say 'Place <char> on the board'.  This
#    means to do the following:
#        a. Have the value of <char> in register $t1
#        b. store byte the value in $t1 to 0($t0)
#        c. increment the value of of $t0.
#
#    1. Set $t0 to point to the board
#    2. Draw the top row of the board:
#        a. Looping 'wid' times, place '#' on the board.
#        b. Place newline on the board.
#    3. Draw the middle of the board.  Loop hgt - 2 times:
#        a. Place '#' on the board.
#        b. Looping wid - 2 times, place '.' on the board.
#        c. Place '#' on the board.
#        d. Place newline on the board.
#    4. Draw the bottom row of the board:
#        a. Looping wid times, place '#' on the board.
#        b. Place newline on the board.
#    5. End the string by placing 0 on the board.
#
######################################################################## 
initBoard:
	la $t0, board	#pointer to board
	la $t4, 39	#initialize width
	la $t5, 30  	#initialize height
	lb $t1, hashtag #set hashtag to add
	lb $t2, newline #set newline to add
	lb $t3, dot	#set dot to add
	lb $t9, zero	#set 0 to add
	li $t7, 0	#initialize loop counter
top:	
	bge $t7, $t4, mid	#loops wid (39) times, then moves to middle part
	sb $t1, 0($t0)		#places # on board
	addi $t0, $t0, 1	#increment $t0 to next element of array
	addi $t7,$t7, 1		#increment loop counter
	b top			#loops back

mid:	sb $t2, 0($t0)	#adds newline
	addi $t0, $t0, 1#increments to next array element
	li $t7,0 	#set outer loop counter
	addi $t5, $t5, -2  #hgt - 2 for looping
	addi $t4, $t4, -2  #wid - 2 for looping
outer:	bge $t7, $t5, outer_end	#loops hgt - 2 times
	li $t8, 0	#set inner loop counter
 	sb $t1, 0($t0)	#adds "#" to board
 	addi $t0, $t0, 1
 	inner:  bge $t8, $t4, inner_end  #loops wid-2 times
 		sb $t3, 0($t0)	#adds dot to board
 		addi $t8,$t8, 1
 		addi $t0, $t0, 1
		j inner
	inner_end:	#end of inner loop
	sb $t1, 0($t0)	#adds "#" to board
	addi $t0, $t0, 1
	sb $t2, 0($t0)	#adds newline to board
	addi $t0, $t0, 1
	addi $t7, $t7, 1 #increment outer loop by 1
        j outer		#loops back the outer loop

outer_end:
	li $t7, 0  #initialize loop counter
	li $t4, 39 #set wid back to 39
bottom:	#last line of board
	bge $t7, $t4, end	#loop wid (39) times
	sb $t1, 0($t0) 		#adds "#" to board
	addi $t7,$t7, 1		#increment loop counter
	addi $t0, $t0, 1	#increment array pointer
	j bottom

end:	#end of board construction
	sb $t9, 0($t0)
	addi $t0, $t0, 1
	jr $ra

########################################################################
# Function Name: addWalls
########################################################################
# Functional Description:
#    This routine adds extra walls in the middle of the board.  The global
#    numWalls indicates how many to add.  Since we randomly place these,
#    it is possible we will place some at the same spot, so there might
#    be somewhat fewer than numWalls.
#
########################################################################
# Register Usage in the Function:
#    -- Since this calls subroutines, we save $ra on the stack, then
#    -- restore it.  We also save $s0 and $s1 on the stack.
#    $a0, $v0 -- Subroutine parameter and return passing.
#    $s0 -- Loop counter: how many walls still to place
#    $s1 -- The x-coordinate of the wall
#    $t0 -- Pointer where to store the wall in the board
#    $t1 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Save the return address and S registers on the stack
#    2. Loop based on the number of walls to place:
#     2a. Get a random X coordinate (into $s0) and random Y coordinate.
#     2b. Compute Y * linelen + X
#     2c. Compute the final pointer by adding the 2b value to the address
#      of the board.
#     2d. Store a wall character at that pointer.
#    5. Restore the return address and S registers
#
########################################################################
addWalls:
	addi $sp, $sp, -8 #pushes stack pointer down 2 words
	sw   $ra, 0($sp)  #store return address on stack (-8)
	sw   $s0, 4($sp)  #store loop counter on stack (-4)
	sw   $s1, 8($sp)  #store x coordinate on stack (0)
	lb   $t5, hashtag #set hashtag to add
	li   $s3, 50	#initialize 50 walls to add
	li   $s0, 0	#loop counter of walls to put
loop:
	bge $s0, $s3, done	#loop 50 times for amount of walls
	jal  randX	#call randX
	move $s1, $v0	#store random x coordinate in $s1

	jal randY	#call randY
	move $t1, $v0	#store random y coordinate in $t1
	la   $t0, board	#load pointer to board
	li $t2, 40	#initialize linelen
	mult $t1, $t2	# Y * linelen = result
	mflo $t3
	add $t3, $t3, $s1 # result + X
	add $t0, $t0, $t3 # added (Y * linelen + X) to pointer of board
	sb  $t5, 0($t0)   #adds wall to pointer
	addi $s0, $s0, 1  #increment loop counter
	j loop
done:
	lw $ra, 0($sp)	#restore return address
	lw $s0, 4($sp)	#restore s register
	lw $s1, 8($sp)	#resotre s register 2
	addi $sp, $sp, 8 #restore stack pointer	
	jr $ra

########################################################################
# Function Name: int randX
########################################################################
# Functional Description:
#    This routine gets a random number for the X coordinate, so the value
#    will be between 1 and wid - 1.
#
########################################################################
# Register Usage in the Function:
#    -- Since this calls rand, we save $ra on the stack, then restore it.
#    $a0 -- the value wid - 2 passed to rand
#    $v0 -- the return value from rand
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Save the return address on the stack
#    2. Get the value wid - 2
#    3. Pass this to rand, so we get a number between 0 and wid - 2
#    4. Add 1 to the result, so the number is between 1 and wid - 1
#    5. Restore the return address
#
########################################################################
randX:
	addi $sp, $sp, -4	#pushes stack pointer down 1 word
	sw $ra, ($sp)		#store return address onto stack
	lw $a0, wid
	addi $a0, $a0, -2	#initialize wid -2 (39-2) = 37
	jal rand		#calls rand function
	addi $v0, $v0, 1	#increment the random number to 1 - wid-1
	lw $ra, ($sp)		#loads return address from stack
	addi $sp, $sp, 4	#moves stack pointer back
	jr $ra			#returns random number in $v0

########################################################################
# Function Name: int randY
########################################################################
# Functional Description:
#    This routine gets a random number for the Y coordinate, so the value
#    will be between 1 and hgt - 1.
#
########################################################################
# Register Usage in the Function:
#    -- Since this calls rand, we save $ra on the stack, then restore it.
#    $a0 -- the value hgt - 2 passed to rand
#    $v0 -- the return value from rand
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Save the return address on the stack
#    2. Get the value hgt - 2
#    3. Pass this to rand, so we get a number between 0 and hgt - 2
#    4. Add 1 to the result, so the number is between 1 and hgt - 1
#    5. Restore the return address
#
########################################################################
randY:
	addi $sp, $sp, -4	#pushes stack pointer down 1 word
	sw $ra, ($sp)		#store return address onto stack
	lw $a0, hgt		
	addi $a0, $a0, -2       #initialize hgt - 2
	jal rand		#calls rand function
	addi $v0, $v0, 1	#increment the random number to 1 - wid-1
	lw $ra, ($sp)		#loads return address from stack
	addi $sp, $sp, 4	#moves stack pointer back
	jr $ra			#returns random number in $v0

########################################################################
# Function Name: int rand()
########################################################################
# Functional Description:
#    This routine generates a pseudorandom number using the xorsum
#    algorithm.  It depends on a non-zero value being in the 'seed'
#    location, which can be set by a prior call to seedrand.  For this
#    version, pass in a number N in $a0.  The return value will be a
#    number between 0 and N-1.
#
########################################################################
# Register Usage in the Function:
#    $t0 -- a temporary register used in the calculations
#    $v0 -- the register used to hold the return value
#    $a0 -- the input value, N
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Fetch the current seed value into $v0
#    2. Perform these calculations:
#       $v0 ^= $v0 << 13
#       $v0 ^= $v0 >> 17
#       $v0 ^= $v0 << 5
#    3. Save the resulting value back into the seed.
#    4. Mask the number, then get the modulus (remainder) dividing by $a0.
#
########################################################################
	.data
	seed: 	    .word 31415           # An initial value, in case seedrand wasn't called
	.text
rand:
    lw      $v0, seed       # Fetch the seed value
    sll     $t0, $v0, 13    # Compute $v0 ^= $v0 << 13
    xor     $v0, $v0, $t0
    srl     $t0, $v0, 17    # Compute $v0 ^= $v0 >> 17
    xor     $v0, $v0, $t0
    sll     $t0, $v0, 5     # Compute $v0 ^= $v0 << 5
    xor     $v0, $v0, $t0
    sw      $v0, seed       # Save result as next seed
    andi    $v0, $v0, 0xFFFF # Mask the number (so we know its positive)
    div     $v0, $a0        # divide by N.  The reminder will be
    mfhi    $v0             # in the special register, HI.  Move to $v0.
    jr      $ra             # Return the number in $v0

########################################################################
# Function Name: seedrand(int)
########################################################################
# Functional Description:
#    This routine sets the seed for the random number generator.  The
#    seed is the number passed into the routine.
#
########################################################################
# Register Usage in the Function:
#    $a0 -- the seed value being passed to the routine
#
########################################################################
seedrand:
    sw $a0, seed
    jr $ra
    
#########################################################
#-----------------PHASE 2-------------------------------#
#########################################################

########################################################################
# Function Name: placeobj(idx, type)
########################################################################
# Functional Description:
#    The $a0 register is the index of an object.  $a1 is the type for
#    this object.  Create a new object, then find a place for it on the
#    board.
#
########################################################################
# Register Usage in the Function:
#    $a0 -- Index of object in question
#    $s0 -- pointer to the object's structure.
#    $t0, $t1 -- general calculations.
#    $v0 -- subroutine linkage
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Save space on the stack for the return address and $s0
#    2. Set $s0 to the pointer to this object
#    3. Store the type of the object
#    4. Compute a random X and random Y for the object, storing these.
#    5. Compute the pointer to this location on the board.
#    6. See if the location is empty ('.').  If not, loop back to 4.
#
########################################################################
placeobj:
	addi 	$sp, $sp, -4  #pushes stack pointer down 1 word
	sw   	$ra, 0($sp)   #store return address on stack (-4)
newobj:	
	li $s0, 0		#set $s0 to zero
	sw $s0, object($s0)	#store index in object
	jal randX		#calls randomX, $v0 holds x value
	move $a0, $v0		#move x to $a0
	addi $s0, $s0 4		#increment to next item of object (x)
	sw $a0, object($s0)	#store x coordinate in object
	jal randY		#calls randomY, $v0 holds y value		
	move $a0, $v0		#move y to $a0
	addi $s0, $s0 4		#increment to next item of object (y)
	sw $a0, object($s0)	#store y coordinate in object
	addi $s0, $s0 4		#increment to next item of object (type)
	sw $a1, object($s0)	#store type in object
	
	addi $s0, $s0, -4	#decrement to last item of object (y)
	lw $t0, object($s0)	#load $t0 with y coordinate
	addi $s0, $s0, -4	#decrement to last item of object (x)
	lw $t1, object($s0)	#load $t1 with x coordinate
	lw $t2, linelen 	#load linelen with 40
	mult $t0, $t2		#multiply Y to linelen
	mflo $t0
	add $t0, $t0, $t1 	#(Y * linelen) + X (offset of address on board)
	#Save address to index 0
	addi $s0, $s0, -4 	#decrement to last item of object (address)
	sw $t0, object($s0)	#store object location to index 0		
	#test if  location is safe to add object
	lw $t0, object($s0) 	#Load player location into t0 	
	lb $t2, board($t0) 	#load item 
	lb $t5, hashtag 	#set hashtag to compare
	lb $t6, X 		#set char "X" to compare
	lb $t7, dollar 		#set char "$" to compare
	beq $t2, $t5, newobj	#if that loaction is a wall we get another location
	beq $t2, $t7, newobj	#if that loaction is a robot we get another location
	beq $t2, $t6, newobj    #if that loaction is a player we get another location
	
next:
	lw $ra, 0($sp)		#restore return address
	addi $sp, $sp, 4	#restore stack pointer
	jr $ra
########################################################################
# Function Name: drawobj(idx)
########################################################################
# Functional Description:
#    The $a0 register is the index of an object.  Draw the object's character
#    at that point on the board.
#
########################################################################
# Register Usage in the Function:
#    $a0 -- Index of object in question
#    $t0, $t1, $t2, $t3 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Compute the effective address of the object
#    2. Determine the character for this type of object
#    3. Place that character in the board at the object's location.
#
########################################################################
drawobj:
	lw  $t1, object($a0) 	#Load player location into t1
	addi $a0, $a0, 12     	#Check object type
	lw  $t3, object($a0) 	#Load player type into t3
	beq $t3, 1, player	#if type is player(1)
	beq $t3, 2, robot	#if type is robot(2)
	bne $t3, 2, skip	#if type is neither
	jr $ra
player:
	addi $a0, $a0, -12      #Back to player location
	lw $t0, object($a0)	#load address offset
	lb $t6, X 		#set char "X" to draw
	sb $t6, board($t0)	#places player on board	
	jr $ra
robot:
	addi $a0, $a0, -12      #Back to player location
	lw $t0, object($a0)	#load address offset
	lb $t6, dollar 		#set char "$" to draw
	sb $t6, board($t0)	#places robot on board	
	jr $ra
skip:			
	jr $ra		 	

########################################################################
# Function Name: eraseobj(idx)
########################################################################
# Functional Description:
#    The $a0 register is the index of an object.  Find the location of
#    that object on the board, then store floor ('.') at that spot.
#
########################################################################
# Register Usage in the Function:
#    $a0 -- Index of object in question
#    $t0, $t1, $t2 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Compute the effective address of the object
#    2. Store a '.' at that point of the board
#
########################################################################

eraseobj:		
	lw $t1, object($a0) 	#Load object location into t1
	lb $t2, dot		#set dot to add
	sb $t2, board($t1)	#adds dot onto board	
	jr $ra 	

########################################################################
# Function Name: char whatthere(idx)
########################################################################
# Functional Description:
#    The $a0 register is the index of an object.  Find the location of
#    that object on the board, then return the character at that location
#    on the map.
#
########################################################################
# Register Usage in the Function:
#    $a0 -- Index of object in question
#    $t0, $t1 -- general calculations.
#    $v0 -- return value
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Compute the effective address of the object
#    2. Fetch the value at that point of the board.
#
########################################################################

whatthere:
	lb $t5, hashtag 	#set hashtag to compare
	lb $t6, rubble		#set char "@" to compare
	lb $t7, dollar 		#set char "$" to compare
	
	lw $t1, object($a0) 	#Load player location into t1
	lb $t2, board($t1)	#Load char to make sure it is not wall
	beq $t2, $t5, Exit	#If it is wall
	beq $t2, $t6, Exit	#If it is rubble
	beq $t2, $t7, Exit2	#If it is robot
	jr $ra
	
########################################################################
# Function Name: moven(idx)
########################################################################
# Functional Description:
#    This routine moves one object north on the board (up the page).
#    The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
#    $a0 -- Index of object to move
#    $t0, $t1 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Compute the effective address of the object
#    2. Decrement the Y value
#    3. Decrement the pointer by the line length
#
########################################################################
moveN:
	move $t0, $a0			#move index of object to $t0
	lw $t1, object($t0) 		#Load player location into t1
	addi $t1, $t1, -40 		#Decrement the pointer by the line length * byte
	sw $t1, object($t0) 		#Save new player location value
	addi $t0, $t0, 8		#Set index to 8
	lw $t2, object($t0) 		#Load player Y value into t2	
	addi $t2, $t2, -1 
	sw $t2, object($t0) 		#Save new player location value
	jr $ra


########################################################################
# Function Name: moves(idx)
########################################################################
# Functional Description:
#    This routine moves one object south on the board (down the page).
#    The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
#    $a0 -- Index of object to move
#    $t0, $t1 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Compute the effective address of the object
#    2. Increment the Y value
#    3. Increment the pointer by the line length
#
########################################################################
moveS:
	move $t0, $a0
	lw $t1, object($t0) 	#Load player location into t1
	addi $t1, $t1 40 	#increment the pointer by the line length * 4
	sw $t1, object($t0) 	#Save new player location value
	addi $t0, $t0, 8	#Set index to 8
	lw $t2, object($t0) 	#Load player Y value into t6	
	addi $t2, $t2, 1 
	sw $t2, object($t0) 	#Save new player location value
	jr $ra

########################################################################
# Function Name: movew(idx)
########################################################################
# Functional Description:
#    This routine moves one object west on the board (to the left).
#    The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
#    $a0 -- Index of object to move
#    $t0, $t1 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Compute the effective address of the object
#    2. Decrement the X value
#    3. Decrement the pointer
#
########################################################################
moveW:
	move $t0, $a0
	lw $t1, object($t0) 	#Load player location into t1
	addi $t1, $t1 -1 	#Decrement the pointer value
	sw $t1, object($t0) 	#Save new player location value
	addi $t0, $t0, 4	#Set index to 4
	lw $t2, object($t0) 	#Load player X value into t6	
	addi $t2, $t2, -1 	#move left one
	sw $t2, object($t0) 	#Save new player location value
	jr $ra

########################################################################
# Function Name: movee(idx)
########################################################################
# Functional Description:
#    This routine moves one object east on the board (to the right).
#    The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
#    $a0 -- Index of object to move
#    $t0, $t1 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Compute the effective address of the object
#    2. Increment the X value
#    3. Increment the pointer
#
########################################################################
moveE:
	move $t0, $a0	
	lw $t1, object($t0) 	#Load player location into t5
	addi $t1, $t1, 1 	#increment the pointer value
	sw $t1, object($t0) 	#Save new player location value
	addi $t0, $t0, 4	#Set index to 4
	lw $t2, object($t0) 	#Load player X value into t6	
	addi $t2, $t2, 1 	#move right one
	sw $t2, object($t0) 	#Save new player location value
	jr $ra

########################################################################
# Function Name: movej(idx)
########################################################################
# Functional Description:
#    This routine moves one object to a random spot on the board.
#    The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
#    We save the $ra and $s0 registers on the stack
#    $a0 -- Index of object to move
#    $s0 -- pointer to the object
#    $t0, $t1 -- general calculations.
#    $v0 -- subroutine linkage
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Save $ra and $s0 on the stack
#    2. Set $s0 to be the pointer to the object
#    3. Get new random X and Y coordinates for the object
#    4. Compute the object's new board pointer
#    5. Restore $ra and $s0
#
########################################################################

moveJ:
	addiu $sp, $sp, -4 	#Save the return address on the stack
	sw $ra, 0($sp)	   	#Save the return address on the stack
again:
	move $s0, $zero		#set s0 to zero
	sw $t0, object($s0)     #save a zero to index 0 first 
	jal randX  		#call randX, x value in $v0	 
	move $t0, $v0  		#Move x value to t0 	 
	addi $s0, $s0, 4	#next item in object
	sw $t0, object($s0)     #Store X Value
	
	jal randY 		#call randY, y value in $v0
	move $t0, $v0   	#Move y value to t0 
	addi $s0, $s0, 4	#next item in object
	sw $t0, object($s0)     #Store Y Value
	addi $s0, $s0, 4	#next item in object
	addi $t1, $zero, 1 	#Save 1 for player type 
	sw $t1, object($s0)     #Store player type

	#find player location in board
	addi $t0, $zero, 8  	#Now we will load Y value to calculate
	lw $t1, object($t0) 	#Load Y into t1
	addi $t0, $zero, 0
	addi $t0, $t0, 4
	lw $t2, object($t0) 	#Load X into t2																							
	lw $t3, linelen 	#Move linelen into t3
	mult $t1, $t3		#Multiply Y to linelen
	mflo $t1        	#Result of Y * linelen
	add $t1, $t1, $t2 	#Result of (Y * linelen + X)

	addi $t0, $zero, 0 	#Set index to 0
	sw $t1, object($t0)	#store player location to index 0
		
	#test if location safe 
	lb $t7, hashtag		#set hashtag to compare
	lw $t5, object($t0) 	#Load player location into t5
	lb $t6, board($t5) 	#Load char of that location into t6
	beq $t6, $t7, again	#if wall, loop back
	
	lw $ra, 0($sp)        #Restore the return address
	addiu $sp, $sp, 4     #Restore stack pointer
	jr $ra 	

#########################################################
#-----------------PHASE 3-------------------------------#
#########################################################

########################################################################
# Function Name: bool moveRobot(idx)
########################################################################
# Functional Description:
#    The $a0 register is the index of an object (a robot or rubble).
#    This computes and moves the robot to take one step closer to the
#    person.  If the robot crashes, it becomes rubble.  This routine returns
#    1 if the person was killed by a robot; 0 otherwise.
#
########################################################################
# Register Usage in the Function:
#    $a0 -- Index of object in question
#    $s0 -- saved index of object in question.
#    $s1 -- pointer to the object's structure.
#    $s2    -- pointer to the player's structure.
#    $t0, $t1 -- general calculations.
#    $v0 -- subroutine linkage
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Save registers on stack
#    2. Compute pointers to object's struct and player's struct
#    3. If object is a robot:
#     3a. See what is in map at robot's location.  Normally it would be
#     the robot symbol.  But if another robot had crashed into
#     this one, it would be rubble.  If it is rubble, turn this
#     robot object into a rubble object.
#     3b.    Erase the robot from the map
#     3c. Move the robot one step vertically closer to player
#     3d. Move the robot one step horizontally closer to player
#     3e. See if there is a collision at this location
#     3f.    Draw robot back into map
#    4. Restore registers
#
########################################################################
moveRobot:
	addiu $sp, $sp, -4 # Save the return address on the stack
	sw $ra, 0($sp)	   # Save the return address on the stack
	
	lw $s1, object($a0)	# Store Object's pointer to $s1
	lw $s2, object($zero)	# Save player pointer to $s2

	addi $t0, $zero, 4	# move to player x value pointer	
	addi $a0, $s0, 4	# Move to robot x value pointer
	lw $t4, object($t0)	# Load player x value to $t4
	lw $s4, object($a0)	# load robot x value to $s4
	addi $t0, $t0, 4	# move to player y value pointer
	addi $a0, $a0, 4	# Move to robot y value pointer
	lw $t2, object($t0)	# Load player y value to $t4
	lw $s6, object($a0)	# load robot y value to $s4	

	#Check Type
	addi $a0, $a0, 4	#Move index to object's type
	lw $s7, object($a0) 	#Save type to $s3
	bne $s7, 2, Return	#If it is rubble exit moveRobot
	addi $a0, $a0, -12 	#set index back to erase
	jal eraseobj 
	beq $t4, $s4, GoUpDown 		# if robot x == player x, go vertically  
	beq $t2, $s6, GoLeftRight	# if robot y == player y, go horizontally  
		
		 	
	subu $s7, $t4, $s4	# Player x - robot x	
	subu $s3, $t2, $s6	# Player y - robot y	
		
	bgt $s7, $s3, GoUpDown		# if y value is closer to player go vertically 					
	bgt $s3, $s7, GoLeftRight	# if x value is closer to player go horizontally 	
		
GoUpDown:
	sub $s3, $t2, $s6	# Player y - robot y
	blt $s3, $zero	goUp	# If the value is negative go up
	bgt $s3, $zero 	goDown	# If the value is postive go down

GoLeftRight:
	sub $s7, $t4, $s4	# Player x - robot x
	blt $s7, $zero	goLeft	# If the value is negative go left
	bgt $s7, $zero 	goRight	# If the value is postive go right		
		
goUp:	
	addi $s1, $s1 -40 	# Decrement the pointer by the line length
	jal CheckLocation 	# Check location before robot move	
	jal moveN		# Move the robot one step vertically closer to player 
	addi $a0, $a0, -8	# Move pointer back 
	jal drawobj		# Erase the robot from the map
	j Return	
goDown:
	addi $s1, $s1 40 	# increment the pointer by the line length
	jal CheckLocation 	# Check location before robot move
	jal moveS		# Move the robot one step vertically closer to player 
	addi $a0, $a0, -8	# Move pointer back 
	jal drawobj		# Erase the robot from the map
	j Return
					
goLeft:
	addi $s1, $s1 -1 	# Decrenebt the pointer value
	jal CheckLocation 	# Check location before robot move
	jal moveW		# Move the robot one step horizontally closer to player
	addi $a0, $a0, -4	# Move pointer back 
	jal drawobj		# Erase the robot from the map
	j Return
goRight:
	addi $s1, $s1 1 	# increment the pointer value
	jal CheckLocation 	#Check location before robot move	 
	jal moveE		# Move the robot one step horizontally closer to player
	addi $a0, $a0, -4	# Move pointer back 
	jal drawobj		# Erase the robot from the map
	j Return								
					
CheckLocation:
	addiu $sp, $sp, -4 	#Save the return address on the stack
	sw $ra, 0($sp)	   	#Save the return address on the stack
	lb $t1, hashtag		#set wall for comparison
	lb $t2, dollar		#set robot for comparison
	lb $t3, rubble		#set rubble for comparison
	lb $t4, X		#set player for comparison
	
	lb $t6, board($s1)	#Load that location value to make sure it is not wall
	beq $t6, $t1, RobotDie	#If it is wall robot die
	beq $t6, $t2, RobotDie	#If it is a robot,then robot die
	beq $t6, $t3, RobotDie	#If it is a rubble,then robot die
	beq $t6, $t4, PlayerDie	#Robot killed player
	lw $ra, 0($sp)	   	#Restore the return address	
	addiu $sp, $sp, 4  	#Restore the return address
	jr $ra 		   	#Return
RobotDie:
	addi $s5, $s5, -1	#Robot counter
	beqz $s5, Win		#If all robot die player win
	lw $t5, object($a0) 	# Load player location into t5
	lb $a0, rubble          # set Rubble to change
	addi $t4, $zero, 3	# Change robot type to 3
	addi $s0, $s0, 12	# Move pointer to type
	sw $t4, object($s0)	# Change robot to rubble
	sb $a0, board($t5)	# Change robot icon
	addi $a0, $a0, -12	# Move index back
	add $v0, $zero, 0 	# return 0	 
Return:		
	lw $ra, 0($sp)	   	#Restore the return address	
	addiu $sp, $sp, 4  	#Restore the return address
	jr $ra 		   	#Return	
	
PlayerDie:
	add $v0, $zero, 1 	# return 1
	j Return	
