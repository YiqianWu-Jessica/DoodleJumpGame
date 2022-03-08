#####################################################################
#
# CSCB58 Fall 2020 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Yiqian Wu, Student Number: 1003784826
#
# Bitmap Display Configuration:
# - Unit width in pixels: 16					     
# - Unit height in pixels: 16
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
# I have reached Milestone 1/2/3/4(a,b,c)/ 5(a,d,e)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. when begin the game, nothing will move, until click "s"
# 2. After moving to the most left wall, press"j", it will no longer move to left
# 3. After moving to the most right wall, press"k", it will no longer move to right
# 4. After hitting the bottom of upper board, the doodle will change the direction of motion and rebound downward 
# 5. After doodle reaching the upper board, all the boards will fall down and a new board will be created
# 6. When the doodle reach the upper board on the third time, there will be a dynamic notification "good"
# 7. When the doodle reach the upper board on the fifth time, there will be a dynamic notification "+", and the doodle will speed up
# 8. When the doodle reach the upper board on the tenth time, will win the game, there is a win shown on the screen, the game will end
# 9. When the doodle fell to the ground before he reach the upper board ten times, the game will end, it will show end, and "H:" will show the score
# 10. When the game end, if the player click "S" in 6 seconds, he can restart the game, and the code will go back to the first step (it will wait for "s" to start the whole game)
# 11. Otherwise, the game will over, it will jump to "game over screen"
# 12. during the waiting time to click restart, there is a small yellow point used to remind player
# 13. a beautiful cloud will show on the top of the screen and its position is random
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). 
# Youtube link: https://youtu.be/yk5b0DaskRg
# MyMedia link: https://play.library.utoronto.ca/9f2917efca3d18bad44839bdb7f5c2dd
#
# Any additional information that the TA needs to know:
# 1: when begin the game, nothing will move, waiting for start
# 2: after click"s", the game will start
# 3: after click"j", the doodle will move to left, after moving to the most left wall, press"j", it will no longer move to left
# 4: after click"k", the doodle will move to right, after moving to the most right wall, press"k", it will no longer move to right
# 5: when the doodle moving up, after hitting the bottom of board3, it will change the direction of motion and rebound downward 
# 6：when the doodle moving down， and reach board3 successfully，board1,2,3 will all fall down 9 units, and a new board1 will be created
# 7: when the doodle reach the upper board on the third time, there will be a dynamic notification "good"
# 8: when the doodle reach the upper board on the fifth time, there will be a dynamic notification "+", and the doodle will speed up
# 9: when the doodle reach the upper board on the tenth time, will win the game, there is a win shown on the screen, the game will end
# 10: when the doodle fell to the ground before he reach the upper board ten times, the game will end, it will show end, and "H:" will show the score
# 11: when the game end, if the player click "S" in 6 seconds, he can restart the game, and the code will go back to the first step (it will wait for "s" to start the whole game)
# 12: otherwise, the game will over, it will jump to game over screen
#	
#####################################################################

# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 16					     
# - Unit height in pixels: 16
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#

.data			
	displayAddress: .word	0x10008000         # base address            
	green:   .word     0x0000ff00      #board
	yellow:  .word     0x00ffff00       #Doodle
	blue:  .word       0x000000ff       #sky
	white:  .word      0xffffffff  
	black:  .word      0x00000000
.text			
	lw $t0, displayAddress		
			
Again:	addi $a1,$zero, 10		# the range of the random nunber
	jal  random		
	addi $t1, $s0, 256		# first board
	jal  random		
	addi $t2, $s0, 832		# second board
	jal  random		
	addi $t3, $s0, 1408		# third board
	addi $t4, $t0, 2004		# forth board
	addi $t6, $t0, 1888		# the position of the player
	jal  random		
	addi $t7, $s0, 128		# cloud
			
	addi $t5, $zero, 800		# the speed of the player, sleep 800 ms
	addi $t8, $zero, 12		# max jump 12 pixel 
	addi $t9, $zero, 0		# score
	addi $s1, $zero, 0		# the horizontal change of the player 
	addi $s3, $zero, 0		
	addi $s4, $zero, 106		#j
	addi $s5, $zero, 107		#k
	addi $s6, $zero, -32		# the most left (-8*4)
	addi $s7, $zero, 28		# the most right(7*4)
	addi $a3, $t0,  1984		# the bottom
	jal paint		

wait:	li   $v0, 32			# sleep 2000 ms
	li   $a0, 2000	
	syscall	
	lw $s3, 0xffff0000	 	# judge whether there is any input
	bne   $s3, 1,  wait	
	addi  $s3,  $zero,  0	
	lw $s0, 0xffff0004 		# if the input is "s" then start
	beq $s0, 115, main	
	j wait				
			
main:	lw $s3, 0xffff0000		# judge whether there is any input
	bne   $s3, $zero, Input		# if there is any start then go to input, "J" will go left, and "K" will go right
	bge $t9, 9, win			# if the score is larger than 9 than win directly
			
move:	beq $t8, $zero, down		# after jump 12 pixel, then moving down
			
	addi $t6, $t6, -64		# else, then still moving up
	addi $t8,$t8,-1		
	
	addi  $s2, $t3,  0		# if hit board3, then moving down
	addi $s3, $zero, 5		
compare1:	beq  $t6, $s2, down		
	addi $s2, $s2, 4		
	addi $s3, $s3, -1		
	bne  $s3, $zero, compare1		
			
	jal paint		
	j main		
			
down:	addi $t8,$zero,0		# when moving down, if stand on the board3 ,then go to reposition all the boards
	addi $t6, $t6, 64		
	addi  $s2, $t3,  -64		
	addi $s3, $zero, 5		
compare2:	beq  $t6, $s2, repos		
	addi $s2, $s2, 4		
	addi $s3, $s3, -1		
	bne  $s3, $zero, compare2		
			
	addi  $s2, $t4,  -64		# if still stand on board4, then go to up, and moving up again
	addi $s3, $zero, 5		
compare3:	beq  $t6, $s2, up		
	addi $s2, $s2, 4		
	addi $s3, $s3, -1		
	bne  $s3, $zero, compare3		
			
	bge   $t6, $a3,  Exit		# if not stand on board4, and the position of the player is larger then the bottom, 
	jal     paint			# which means the player has failed, then go to Exit
	j   main		
			
Exit:	li   $s0,  0x000000ff		# background----- blue
	addi  $s2, $t0, 2048
L2:	sw  $s0  -4($s2)
	addi  $s2, $s2, -4
	bne $s2, $t0, L2
	
	li   $s0,  0x00ffff00		# END-----yellow
	sw   $s0,  900($t0)
	sw   $s0,  964($t0)
	sw   $s0,  1028($t0)
	sw   $s0,  1092($t0)
	sw   $s0,  1156($t0)
	sw   $s0,  1220($t0)
	sw   $s0,  1284($t0)
	sw   $s0,  904($t0)
	sw   $s0,  908($t0)
	sw   $s0,  972($t0)
	sw   $s0,  1036($t0)
	sw   $s0,  1100($t0)
	sw   $s0,  1096($t0)
	sw   $s0,  1288($t0)
	sw   $s0,  1292($t0)

	sw   $s0,  916($t0)
	sw   $s0,  980($t0)
	sw   $s0,  1044($t0)
	sw   $s0,  1108($t0)
	sw   $s0,  1172($t0)
	sw   $s0,  1236($t0)
	sw   $s0,  1300($t0)
	sw   $s0,  920($t0)
	sw   $s0,  924($t0)
	sw   $s0,  988($t0)
	sw   $s0,  1052($t0)
	sw   $s0,  1116($t0)
	sw   $s0,  1180($t0)
	sw   $s0,  1244($t0)
	sw   $s0,  1308($t0)

	sw   $s0,  1124($t0)
	sw   $s0,  1188($t0)
	sw   $s0,  1252($t0)
	sw   $s0,  1316($t0)
	sw   $s0,  1128($t0)
	sw   $s0,  1320($t0)
	sw   $s0,  940($t0)
	sw   $s0,  1004($t0)
	sw   $s0,  1068($t0)
	sw   $s0,  1132($t0)
	sw   $s0,  1196($t0)
	sw   $s0,  1260($t0)
	sw   $s0,  1324($t0)

	li   $s0, 0x0000ff000 		# H: ----- green
	sw   $s0,  84($t0)
	sw   $s0,  148($t0)
	sw   $s0,  212($t0)
	sw   $s0,  276($t0)
	sw   $s0,  340($t0)
	sw   $s0,  404($t0)
	sw   $s0,  468($t0)
	sw   $s0,  280($t0)
	sw   $s0,  92($t0)
	sw   $s0,  156($t0)
	sw   $s0,  220($t0)
	sw   $s0,  284($t0)
	sw   $s0,  348($t0)
	sw   $s0,  412($t0)
	sw   $s0,  476($t0)

	sw   $s0,  356($t0)
	sw   $s0,  484($t0)

	beq $t9, 0, zero		# depends on different score, show different number
	beq $t9, 1, one			# the score is between 0-9, when the score is larger than 9, then it will go to win directly
	beq $t9, 2, two
	beq $t9, 3, three
	beq $t9, 4, four
	beq $t9, 5, five
	beq $t9, 6, six
	beq $t9, 7, seven
	beq $t9, 8, eight
	beq $t9, 9, nine
	
zero:	sw   $s0,  108($t0)
	sw   $s0,  172($t0)
	sw   $s0,  236($t0)
	sw   $s0,  300($t0)
	sw   $s0,  364($t0)
	sw   $s0,  428($t0)
	sw   $s0,  492($t0)
	sw   $s0,  112($t0)
	sw   $s0,  496($t0)
	sw   $s0,  116($t0)
	sw   $s0,  180($t0)
	sw   $s0,  244($t0)
	sw   $s0,  308($t0)
	sw   $s0,  372($t0)
	sw   $s0,  436($t0)
	sw   $s0,  500($t0)
	j last
one:	sw   $s0,  116($t0)
	sw   $s0,  180($t0)
	sw   $s0,  244($t0)
	sw   $s0,  308($t0)
	sw   $s0,  372($t0)
	sw   $s0,  436($t0)
	sw   $s0,  500($t0)
	j last
two:	sw   $s0,  108($t0)
	sw   $s0,  300($t0)
	sw   $s0,  364($t0)
	sw   $s0,  428($t0)
	sw   $s0,  492($t0)
	sw   $s0,  112($t0)
	sw   $s0,  496($t0)
	sw   $s0,  116($t0)
	sw   $s0,  180($t0)
	sw   $s0,  244($t0)
	sw   $s0,  308($t0)
	sw   $s0,  500($t0)
	sw   $s0,  304($t0)
	j last
three:	sw   $s0,  112($t0)
	sw   $s0,  304($t0)
	sw   $s0,  496($t0)
	sw   $s0,  116($t0)
	sw   $s0,  180($t0)
	sw   $s0,  244($t0)
	sw   $s0,  308($t0)
	sw   $s0,  372($t0)
	sw   $s0,  436($t0)
	sw   $s0,  500($t0)
	sw   $s0,  304($t0)
	j last
four:	sw   $s0,  108($t0)
	sw   $s0,  172($t0)
	sw   $s0,  236($t0)
	sw   $s0,  300($t0)
	sw   $s0,  116($t0)
	sw   $s0,  180($t0)
	sw   $s0,  244($t0)
	sw   $s0,  308($t0)
	sw   $s0,  372($t0)
	sw   $s0,  436($t0)
	sw   $s0,  500($t0)
	sw   $s0,  304($t0)
	j last
five:	sw   $s0,  108($t0)
	sw   $s0,  172($t0)
	sw   $s0,  236($t0)
	sw   $s0,  300($t0)
	sw   $s0,  492($t0)
	sw   $s0,  112($t0)
	sw   $s0,  496($t0)
	sw   $s0,  116($t0)
	sw   $s0,  304($t0)
	sw   $s0,  308($t0)
	sw   $s0,  372($t0)
	sw   $s0,  436($t0)
	sw   $s0,  500($t0)
	j last
six:	sw   $s0,  108($t0)
	sw   $s0,  172($t0)
	sw   $s0,  236($t0)
	sw   $s0,  300($t0)
	sw   $s0,  304($t0)
	sw   $s0,  364($t0)
	sw   $s0,  428($t0)
	sw   $s0,  492($t0)
	sw   $s0,  112($t0)
	sw   $s0,  496($t0)
	sw   $s0,  116($t0)
	sw   $s0,  308($t0)
	sw   $s0,  372($t0)
	sw   $s0,  436($t0)
	sw   $s0,  500($t0)
	j last
seven:	sw   $s0,  112($t0)
	sw   $s0,  116($t0)
	sw   $s0,  180($t0)
	sw   $s0,  244($t0)
	sw   $s0,  308($t0)
	sw   $s0,  372($t0)
	sw   $s0,  436($t0)
	sw   $s0,  500($t0)
	j last
eight:	sw   $s0,  108($t0)
	sw   $s0,  172($t0)
	sw   $s0,  236($t0)
	sw   $s0,  300($t0)
	sw   $s0,  364($t0)
	sw   $s0,  428($t0)
	sw   $s0,  492($t0)
	sw   $s0,  112($t0)
	sw   $s0,  496($t0)
	sw   $s0,  116($t0)
	sw   $s0,  180($t0)
	sw   $s0,  244($t0)
	sw   $s0,  308($t0)
	sw   $s0,  372($t0)
	sw   $s0,  436($t0)
	sw   $s0,  500($t0)
	sw   $s0,  304($t0)
	j last
nine:	sw   $s0,  108($t0)
	sw   $s0,  172($t0)
	sw   $s0,  236($t0)
	sw   $s0,  300($t0)
	sw   $s0,  492($t0)
	sw   $s0,  112($t0)
	sw   $s0,  496($t0)
	sw   $s0,  116($t0)
	sw   $s0,  180($t0)
	sw   $s0,  244($t0)
	sw   $s0,  308($t0)
	sw   $s0,  372($t0)
	sw   $s0,  436($t0)
	sw   $s0,  500($t0)
	sw   $s0,  304($t0)
	j last	

win:	li   $s0,  0x00000000
	sw   $s0,  520($t0)
	sw   $s0,  584($t0)
	sw   $s0,  648($t0)
	sw   $s0,  712($t0)
	sw   $s0,  776($t0)
	sw   $s0,  840($t0)
	sw   $s0,  844($t0)
	sw   $s0,  784($t0)
	sw   $s0,  720($t0)
	sw   $s0,  656($t0)
	sw   $s0,  852($t0)
	sw   $s0,  856($t0)
	sw   $s0,  792($t0)
	sw   $s0,  728($t0)
	sw   $s0,  664($t0)
	sw   $s0,  600($t0)
	sw   $s0,  536($t0)
	
	sw   $s0,  608($t0)
	sw   $s0,  736($t0)
	sw   $s0,  800($t0)
	sw   $s0,  864($t0)
	
	sw   $s0,  744($t0)
	sw   $s0,  808($t0)
	sw   $s0,  872($t0)
	sw   $s0,  748($t0)
	sw   $s0,  752($t0)
	sw   $s0,  816($t0)
	sw   $s0,  880($t0)
	
	addi $t9, $zero, 0
	j last
	
last:	addi  $s3,  $zero,  0          		#reset the value of $s3, and decide whether there are new inputs
        li   $v0, 32				# sleep 800ms, and if there is a new input "S" then will restart the game
	li   $a0, 800	
	addi  $t7, $zero,5
waiting:li   $s0,   0x00ffff00			# a small yellow points to show during the waiting time
        sw   $s0,  1632($t0)
	syscall	
	li   $s0,  0x000000ff
	sw   $s0,  1632($t0)
	syscall	
	addi $t7,$t7,-1
	bne $t7,$zero, waiting
	lw $s3, 0xffff0000			# if no input, then go to End directly
	bne   $s3, 1,  End	
	addi  $s3,  $zero,  0	
	lw $s0, 0xffff0004 			#if there is a new input "S" then will restart the game
	beq $s0, 83, Again
		

End:	li   $s0,  0x00000000			# blackground ----- black
	addi  $s2, $t0, 2048	
L4:	sw  $s0  -4($s2)	
	addi  $s2, $s2, -4	
	bne $s2, $t0, L4
	
	li   $s0,  0xffffffff			# "over" ----- white
	sw  $s0,  580($t0)
	sw  $s0,  584($t0)
	sw  $s0,  588($t0)
	sw  $s0,  644($t0)
	sw  $s0,  652($t0)
	sw  $s0,  708($t0)
	sw  $s0,  716($t0)
	sw  $s0,  772($t0)
	sw  $s0,  780($t0)
	sw  $s0,  836($t0)
	sw  $s0,  844($t0)
	sw  $s0,  900($t0)
	sw  $s0,  908($t0)
	sw  $s0,  964($t0)
	sw  $s0,  968($t0)
	sw  $s0,  972($t0)
	
	sw  $s0,  596($t0)
	sw  $s0,  660($t0)
	sw  $s0,  724($t0)
	sw  $s0,  788($t0)
	sw  $s0,  852($t0)
	sw  $s0,  916($t0)
	sw  $s0,  984($t0)
	sw  $s0,  604($t0)
	sw  $s0,  668($t0)
	sw  $s0,  732($t0)
	sw  $s0,  796($t0)
	sw  $s0,  860($t0)
	sw  $s0,  924($t0)
	
	sw  $s0,  612($t0)
	sw  $s0,  616($t0)
	sw  $s0,  676($t0)
	sw  $s0,  740($t0)
	sw  $s0,  804($t0)
	sw  $s0,  808($t0)
	sw  $s0,  868($t0)
	sw  $s0,  932($t0)
	sw  $s0,  996($t0)
	sw  $s0,  1000($t0)
	
	sw  $s0,  624($t0)
	sw  $s0,  628($t0)
	sw  $s0,  632($t0)
	sw  $s0,  688($t0)
	sw  $s0,  696($t0)
	sw  $s0,  752($t0)
	sw  $s0,  756($t0)
	sw  $s0,  760($t0)
	sw  $s0,  816($t0)
	sw  $s0,  880($t0)
	sw  $s0,  884($t0)
	sw  $s0,  888($t0)
	sw  $s0,  944($t0)
	sw  $s0,  952($t0)
	sw  $s0,  1008($t0)
	sw  $s0,  1016($t0)
	
	li    $v0, 10	
	syscall	

	
random:	li  $v0,  42				# get a random number between 0-10
	li  $a0,  0	
	addi $a2,$zero,4	
	syscall	
	mult $a0,$a2				# the random horizontal postion is $t0 + 4*random_number
	mflo $s0	
	add $s0, $s0, $t0	
	jr  $ra	
		
paint:	addi $sp, $sp, -4			# background(sky) ----- blue
	sw  $ra, 4($sp)	
	li   $s0,  	0x000000ff
	addi  $s2, $t0, 2048	
L1:	sw  $s0  -4($s2)	
	addi  $s2, $s2, -4	
	bne $s2, $t0, L1	
		
	li   $s0, 0xffffffff  			# cloud ----- white
	sw   $s0,  0($t7)	
	sw   $s0,  4($t7)	
	sw   $s0,  8($t7)	
	sw   $s0,  12($t7)	
	sw   $s0,  16($t7)	
	sw   $s0,  -56($t7)	
	sw   $s0, -52($t7)	
		
	li   $s0, 0x00ffff00			# player ----- yellow
	sw   $s0,  0($t6)	
	sw   $s0,  64($t6)	
		
	li   $s0, 0x0000ff000			# board ----- green
	add $s2, $zero,$t1	
	jal bopaint	
	add $s2, $zero,$t2	
	jal bopaint	
	add $s2, $zero,$t3	
	jal bopaint	
	add $s2, $zero,$t4	
	jal bopaint	
		
	li   $v0, 32				# sleep ----- $t5, which decides the moving speed of the player
	add $a0, $zero, $t5	
	syscall	
	
	lw $ra, 4($sp)				# use stack to return back
	addi $sp, $sp, 4	
	jr  $ra	
		
bopaint:	
	sw  $s0  0($s2)	
	sw  $s0, 4($s2)	
	sw  $s0, 8($s2)	
	sw  $s0, 12($s2)	
	sw  $s0, 16($s2)	
	jr  $ra	

Input:	addi  $s3,  $zero,  0			# according to the input to decide it should go to "J" or "K"
	lw $s0, 0xffff0004 			 
	beq   $s0,  $s4, InJ			# if the input is "J", then go to InJ to go left
	beq   $s0,  $s5, Ink			# if the input is "K", then go to InJ to go right
	j     move	

InJ:	beq $s6, $s1,move			# if the player's position is on the most left, then do nothing
        nop	
	addi $s1,$s1,-4				# otherwise, let player go left, and record its horizontal change
	add $t6, $t6, -4	
	j     move	

Ink:	beq $s1, $s7, move			# if the player's position is on the most right, then do nothing
        nop	
	addi $s1,$s1,4				# otherwise, let player go right, and record its horizontal change
	add $t6, $t6, 4	
	j     move	
		
repos:	addi $t8,$zero,12			# reset the jump max value $t8 as 12
	addi $t9,$t9,1				# and add one more mark to the score
	beq $t9, 3, good			# if jump 3 boards, then show "good" to encourage
	beq $t9,5, speedup			# if jump 5 boards, then show an "add" sign and let the player move faster

t9back:	add $t4, $zero,$t3			# set board3 to board4, board2 to board3, board1 to board2, and create a new board1
	add $t3, $zero,$t2	
	add $t2, $zero,$t1	
	jal  random	
	addi $t1, $s0, 256	
		
	addi $s3, $zero, 9			# let all the boards going down and repaint the new screen
L3:	addi $t4, $t4, 64	
	addi $t3, $t3, 64	
	addi $t2, $t2, 64	
	addi $t6, $t6, 64			
	jal  paint	
	addi $s3, $s3,-1	
	bne $s3, $zero, L3	
	j main	
		
up:	addi $t8,$zero,12			# reset the jump max value $t8 as 12, repaint the screen and go to main to repeat the game
	jal     paint	
	j   main	
	
speedup:li   $s0,  0x00ffff00			# an "add" sign ----- yellow
	sw   $s0,  644($t0)	
	sw   $s0,  648($t0)	
	sw   $s0,  652($t0)	
	sw   $s0,  584($t0)	
	sw   $s0,  712($t0)	
	
	li   $v0,  32				# stop 500 ms
	li   $a0,  500
	syscall	
	
	li   $s0,  0x000000ff			# and then let the "add" sign despair
	sw   $s0,  644($t0)	
	sw   $s0,  648($t0)	
	sw   $s0,  652($t0)	
	sw   $s0,  584($t0)	
	sw   $s0,  712($t0)	
	
	add $t5,$zero, 300			# reset the $t5 sleeping time to 300, as 300<800, the sleeping time will slow down 
	j t9back				# the speed of the player will increse

good:	li   $s0,  0x00ffff00			# "good" ----- yellow
	sw   $s0,  456($t0)
	sw   $s0,  460($t0)
	sw   $s0,  520($t0)
	sw   $s0,  524($t0)
	sw   $s0,  588($t0)
	sw   $s0,  652($t0)
	sw   $s0,  716($t0)
	sw   $s0,  712($t0)
	
	sw   $s0,  468($t0)
	sw   $s0,  472($t0)
	sw   $s0,  532($t0)
	sw   $s0,  536($t0)
	
	sw   $s0,  480($t0)
	sw   $s0,  484($t0)
	sw   $s0,  544($t0)
	sw   $s0,  548($t0)
	
	sw   $s0,  432($t0)
	sw   $s0,  492($t0)
	sw   $s0,  496($t0)
	sw   $s0,  556($t0)
	sw   $s0,  560($t0)
	
	li   $v0, 32				# show 3000 ms
	li   $a0, 3000	
	syscall	
	
	li   $s0,  0x000000ff			# then disappear
	sw   $s0,  456($t0)
	sw   $s0,  460($t0)
	sw   $s0,  520($t0)
	sw   $s0,  524($t0)
	sw   $s0,  588($t0)
	sw   $s0,  652($t0)
	sw   $s0,  716($t0)
	sw   $s0,  712($t0)
	
	sw   $s0,  468($t0)
	sw   $s0,  472($t0)
	sw   $s0,  532($t0)
	sw   $s0,  536($t0)
	
	sw   $s0,  480($t0)
	sw   $s0,  484($t0)
	sw   $s0,  544($t0)
	sw   $s0,  548($t0)
	
	sw   $s0,  432($t0)
	sw   $s0,  492($t0)
	sw   $s0,  496($t0)
	sw   $s0,  556($t0)
	sw   $s0,  560($t0)
		
	j t9back


























































