#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Nada Gamal Eldin, Student Number: 1007316762
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Make a second level that starts after the
#	player completes the first level.
# Done
# 2. Add sound effects for movement, collisions, game end and reaching the goal area.
# Done
# 3. Display a death/respawn animation each time the player loses a frog.
# Done
# 4. After final player death, display game over/retry screen. Restart the game if the “retry” option is chose
# Done
#5. Display the number of lives remaining
#Done
#6. Dynamic increase in difficulty (speed, obstacles, etc.) as game progresses
# Done
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
# moving latest
.data
displayAddress: .word 0x10008000
# Colors:
green: .word 0xa6ff8c
peach: .word 0xFADBD8
blue: .word 0x8cffff
brown: .word 0x915107
grey: .word 0xC9CECE
yellow: .word 0x2335A9
frogalive: .word 0x1E7C35
frogdead: .word 0x000000
frogwin: .word 0xFFAEE8
turtleColour: .word 0x7FD81B
lives: .word 0xCB4335
speed: .word 1500

# all x positions must be updated in multiples of 4
frogx: .word 64 
frogy: .word 56 # updated in multiples of 8 in interval {0, 56}
h: .word 64

log3x: .word 96 # bounded on [36, 96]
log3y: .word 8 # constant - very top row
log1x: .word 16  # bounded on [0, 60]
log1y: .word 16 # constant 
log2x: .word 96 # bounded on [36, 96]
log2y: .word 24 # constant

car1x: .word 0  # bounded on [0, 60]
car1y: .word 40 # constant
car2x: .word 96 # bounded on [36, 96]
car2y: .word 48 # constant

livesNumber: .word 0 # bounded on [0, 3]
win: .word 0 # bounded on [0, 1]

text: .asciiz "Press 'r' to restart, 'e' to exit"

.text
lw $s0, displayAddress # $s0 stores the base address for display

gameLoop:
#la $s6, win
#la $s7, livesNumber

keyboardFunctionality:
lw $t8, 0xffff0000
beq $t8, 1, keyboardInput

checkCollisionsMain: j checkCollisions

redrawScreen: j Draw

Wait: li $v0, 32
lw $a0, speed
syscall

lw $t6, livesNumber
li $t3, 3
beq $t6, $t3, Retry

backToStartScreen: j gameLoop

Draw:
# Final safe zone
lw $t3, win
beqz $t3, Green1
lw $t0 frogx
li $t1 0
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
lw $a0, frogwin
jal drawFrogFunc

# First green block
Green1: addi $a1, $s0, 0  
addi $a2, $a1, 512 
lw $a0, green
jal largeRec

# draw lives
lw $a0, lives
lw $a1, livesNumber

beqz $a1, three
li $t1, 1
beq $a1, $t1, two
li $t1, 2
beq $a1, $t1, one
li $t1, 3
beq $a1, $t1, River

#First life
one: sw $a0, 124($s0)
j River
#Second Life
two: sw $a0, 116($s0)
sw $a0, 124($s0)
j River
#Third Life
three: sw $a0, 108($s0)
sw $a0, 116($s0)
sw $a0, 124($s0)

# Logs and River
River: 
	addi $a1, $s0, 512 
	addi $a2, $a1, 512  
	lw $a0, brown
	jal largeRec

	addi $a1, $s0, 1024 
	addi $a2, $a1, 512  
	lw $a0, turtleColour
	jal largeRec

	addi $a1, $s0, 1536 
	addi $a2, $a1, 512  
	lw $a0, brown
	jal largeRec

# top row of logs
log5: lw $t0 log3x
lw $t1 log3y
lw $t2 h
mult $t1, $t2
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
li $a3, 32
li $v0, 96
lw $a0, blue
jal smallRect

# draw log 6
log6: sub $t3, $t3, 64
add $a1, $s0, $t3
addi $a2, $a1, 512
li $s1, 32
li $v0, 128
sub $s2, $t0, $s1
slti $s3, $s2, 32 
startx: bnez $s3, small5
li $a3, 32
li $v0, 96
jal smallRect
j log1
small5: sub $a3, $t0, $s1 
sub $v0, $v0, $a3 
add $a1, $s0, 512
addi $a2, $a1, 512
jal smallRect
sub $a3, $s1, $a3 
li $v0, 128
sub $v0, $v0, $a3 
li $s3, 512
add $s3, $s3, $v0
add $a1, $s0, $s3 
addi $a2, $a1, 512
jal smallRect

#draw log 1 
log1: lw $t0 log1x
lw $t1 log1y
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
lw $a0, blue
li $a3, 32
li $v0, 96
jal smallRect

#draw and shift log2
log2: add $t3, $t3, 64
add $a1, $s0, $t3
addi $a2, $a1, 512
li $s1, 32
li $v0, 128
sub $s2, $t0, $s1
slti $s3, $s2, 0

start: beqz $s3, small
li $a3, 32
li $v0, 96
jal smallRect
j log3

small: sub $a3, $s1, $s2  
sub $v0, $v0, $a3  
jal smallRect
add $a1, $s0, 1024
addi $a2, $a1, 512
add $a3, $zero, $s2  
li $v0, 128
sub $v0, $v0, $s2 
jal smallRect

log3: lw $t0 log2x
lw $t1 log2y
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
li $a3, 32
li $v0, 96
jal smallRect

log4: sub $t3, $t3, 64
add $a1, $s0, $t3
addi $a2, $a1, 512
li $s1, 32
li $v0, 128
sub $s2, $t0, $s1
slti $s3, $s2, 32 
start2: bnez $s3, small2
li $a3, 32
li $v0, 96
jal smallRect
j Rest
small2: sub $a3, $t0, $s1  
sub $v0, $v0, $a3 
add $a1, $s0, 1536
addi $a2, $a1, 512
jal smallRect
sub $a3, $s1, $a3 
li $v0, 128
sub $v0, $v0, $a3
li $s3, 1536
add $s3, $s3, $v0
add $a1, $s0, $s3 
addi $a2, $a1, 512
jal smallRect

# Middle Safe Zone
Rest: addi $a1, $s0, 2048 
addi $a2, $a1, 512 
lw $a0, peach
jal largeRec

# drawRoad and cars
drawRoad: addi $a1, $s0, 2560
addi $a2, $a1, 1024 
lw $a0, grey
jal largeRec

# draw car 1
car1: lw $t0 car1x
lw $t1 car1y
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
lw $a0, yellow
li $a3, 32
li $v0, 96
jal smallRect

# draw car2
car2: add $t3, $t3, 64
add $a1, $s0, $t3
addi $a2, $a1, 512
li $s1, 32
li $v0, 128
sub $s2, $t0, $s1
slti $s3, $s2, 0

#draw car 3
start3: beqz $s3, small3
li $a3, 32
li $v0, 96
jal smallRect
j car3

small3: sub $a3, $s1, $s2 
sub $v0, $v0, $a3  
jal smallRect
add $a1, $s0, 2560 
addi $a2, $a1, 512
add $a3, $zero, $s2  
li $v0, 128
sub $v0, $v0, $s2 
jal smallRect

car3: lw $t0 car2x
lw $t1 car2y
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
li $a3, 32
li $v0, 96
jal smallRect

car4: sub $t3, $t3, 64
add $a1, $s0, $t3
addi $a2, $a1, 512
li $s1, 32
li $v0, 128
sub $s2, $t0, $s1
slti $s3, $s2, 32
start4: bnez $s3, small4
li $a3, 32
li $v0, 96
jal smallRect
j drawStart

small4: sub $a3, $t0, $s1
sub $v0, $v0, $a3  
add $a1, $s0, 3072
addi $a2, $a1, 512
jal smallRect
sub $a3, $s1, $a3 
li $v0, 128
sub $v0, $v0, $a3
li $s3, 3072
add $s3, $s3, $v0
add $a1, $s0, $s3 
addi $a2, $a1, 512
jal smallRect

# Starting region
drawStart: addi $a1, $s0, 3584 
addi $a2, $a1, 512 
lw $a0, green
jal largeRec

# drawFrog
drawFrog: lw $t0 frogx
lw $t1 frogy
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
li $t3, 8
lw $a0, frogalive
jal drawFrogFunc

# Update car and log positions
shiftRow1:
lw $t0 log1x
la $t7 car1x
la $t8 log1x
li $t9 60
beq $t0, $t9, back
addi $t0, $t0, 4
sw $t0, 0($t8)
sw $t0, 0($t7)
j shiftRow2

back: sw $zero, 0($t8)
sw $zero, 0($t7)
j shiftRow2

shiftRow2:
lw $t0 log2x
la $t7 car2x
la $t8 log2x
la $t2 log3x
li $t9 36
beq $t0, $t9, forward
subi $t0, $t0, 4
sw $t0, 0($t8)
sw $t0, 0($t7)
sw $t0, 0($t2)
j Win
forward: li $t0, 96
sw $t0, 0($t8)
sw $t0, 0($t7)
sw $t0, 0($t2)
j Win

# draw win area
Win: lw $t3, win
beq $t3, $zero, w
lw $t0 frogx
li $t1 0
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
lw $a0, frogwin
jal drawFrogFunc
la $t3, win
sw $zero, 0($t3)

w: j Wait


#Keyboard input:
keyboardInput: 
addi $t8, $zero, 0
lw $t2, 0xffff0004
beq $t2, 0x77, respondToW
beq $t2, 0x73, respondToS
beq $t2, 0x61, respondToA
beq $t2, 0x64, respondToD
j checkCollisions

respondToW:
lw $t0 frogy 
la $t8 frogy
beqz $t0, paint
subi $t0, $t0, 8
sw $t0, 0($t8)
li $t2, 0

li $a0, 70  # sound
li $a1, 1500
li $a2, 6
li $a3, 50
li $v0, 31     
syscall
j checkCollisions
paint: li $t0, 56
sw $t0, 0($t8)
la $t3, win
li $t0, 1
sw $t0, 0($t3)
la $t3, livesNumber
sw $zero, 0($t3)
li $a0, 33  # sound
li $a1, 5000
li $a2, 85
li $a3, 127
li $v0, 31     
syscall
lw $a0, speed
la $t0, speed
subi $a0, $a0, 500
beq $a0, 500, re
sw $a0, 0($t0)
j redrawScreen

# redraw screen
re:
li $a0, 500
sw $a0, 0($t0)
j redrawScreen

respondToS:
lw $t0 frogy
la $t8 frogy
li $t3, 56
beq $t0, $t3, browno2
addi $t0, $t0, 8
sw $t0, 0($t8)
li $t2, 0



li $a0, 70  # sound
li $a1, 1500
li $a2, 6
li $a3, 50
li $v0, 31     
syscall
browno2: 
j checkCollisions

respondToA:
lw $t0 frogx
la $t8 frogx
beq $t0, $zero, browno3
subi $t0, $t0, 16
sw $t0, 0($t8)
li $t2, 0

li $a0, 70  # sound
li $a1, 1500
li $a2, 6
li $a3, 50
li $v0, 31     
syscall
browno3: j checkCollisions

respondToD:
lw $t0 frogx
la $t8 frogx
li $t3, 112
beq $t0, $t3, browno4
addi $t0, $t0, 16
sw $t0, 0($t8)
li $t2, 0

li $a0, 70  # sound
li $a1, 1500
li $a2, 6
li $a3, 50
li $v0, 31     
syscall
browno4: j checkCollisions

# Check colisions
checkCollisions:
la $t8 frogy
lw $t0, frogy
lw $t1, car1y
lw $t2, log1y 
lw $t3, car2y 
lw $t4, log2y 
lw $t9, log3y
beq $t0, $t1, c1
beq $t0, $t2, l1
beq $t0, $t3, c2
beq $t0, $t4, l2
beq $t0, $t9, l3
j redrawScreen

# top car row:
c1: lw $t0, frogx #fx1
lw $t1, car1x # cx1
addi $t2, $t1, 32 # cx2
addi $t4, $t1, 96 # cx4

slti $s1, $t1, 32 # 1: fx1 < 32
bnez $s1, check2 # 0 != s1 = 1 -> [0,28]

addi $t3, $t2, 16 # cx2+16
addi $t5, $t4, 16 # cx4+16


slt $s1, $t0, $t2 
slt $s2, $t3, $t0
beqz $s1, helper
bnez $s2, helper
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j redrawScreen

helper: slt $s1, $t0, $t4 
slt $s2, $t5, $t0 
beqz $s1, exitHelper
bnez $s2, exitHelper
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall

exitHelper : j redrawScreen

check2: 
addi $t3, $t2, 16 
sub $t5, $t1, $t1 
subi $t6, $t1, 16 


slt $s1, $t0, $t2 
slt $s2, $t3, $t0 
beqz $s1, helper2
bnez $s2, helper2
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j redrawScreen

helper2: slt $s1, $t0, $t5 
slt $s2, $t6, $t0 
beqz $s1, exitHelper2
bnez $s2, exitHelper2
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
exitHelper2: j redrawScreen

# top log row:
l1: lw $t0, frogx 
lw $t1, log1x 
addi $t2, $t1, 32 
addi $t4, $t1, 96 

slti $s1, $t1, 32 
bnez $s1, check3 

addi $t3, $t2, 16 
addi $t5, $t4, 16 


slt $s1, $t0, $t2 
slt $s2, $t3, $t0 
beqz $s1, helper3
bnez $s2, helper3
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j redrawScreen

helper3 : 
slt $s1, $t0, $t4 
slt $s2, $t5, $t0 
beqz $s1, exitHelper3
bnez $s2, exitHelper3
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
exitHelper3: j redrawScreen

check3: 
addi $t3, $t2, 16 
sub $t5, $t1, $t1  
subi $t6, $t1, 16 


slt $s1, $t0, $t2 
slt $s2, $t3, $t0 
beqz $s1, helper4
bnez $s2, helper4
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j redrawScreen

helper4: slt $s1, $t0, $t5 
slt $s2, $t6, $t0 
beqz $s1, exitHelper4
bnez $s2, exitHelper4
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
exitHelper4: j redrawScreen

# bottom car row:
c2: lw $t0, frogx 
lw $t1, car2x 
subi $t2, $t1, 32 
subi $t3, $t1, 16 

slti $s1, $t1, 80 
bnez $s1, check5 

sub $t4, $t1, $t1  
subi $t5, $t1, 80


slt $s1, $t0, $t2 
slt $s2, $t3, $t0
beqz $s1, helper5
bnez $s2, helper5
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j redrawScreen

helper5: 
slt $s1, $t0, $t4 
slt $s2, $t5, $t0 
beqz $s1, exitHelper5
bnez $s2, exitHelper5
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
exitHelper5: j redrawScreen

check5:
addi $t3, $t1, 32 
addi $t4, $t1, 48 


slt $s1, $t0, $t2
slt $s2, $t3, $t0 
beqz $s1, helper6
bnez $s2, helper6
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j redrawScreen

helper6: slt $s1, $t0, $t4
slt $s2, $t5, $t0 
beqz $s1, exitHelper6
bnez $s2, exitHelper6
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
exitHelper6: j redrawScreen

# bottom log row:
l2: lw $t0, frogx 
lw $t1, log2x 
subi $t2, $t1, 32
subi $t3, $t1, 16

slti $s1, $t1, 80
bnez $s1, check6 

sub $t4, $t1, $t1  
subi $t5, $t1, 80 


slt $s1, $t0, $t2 
slt $s2, $t3, $t0 
beqz $s1, helper7
bnez $s2, helper7
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j redrawScreen

helper7: 
slt $s1, $t0, $t4 
slt $s2, $t5, $t0
beqz $s1, exitHelper7
bnez $s2, exitHelper7
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
exitHelper7: j redrawScreen

check6: 
addi $t3, $t1, 32 
addi $t4, $t1, 48


slt $s1, $t0, $t2 
slt $s2, $t3, $t0
beqz $s1, helper8
bnez $s2, helper8
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j redrawScreen

helper8: 
slt $s1, $t0, $t4 
slt $s2, $t5, $t0
beqz $s1, exitHelper8
bnez $s2, exitHelper8
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
exitHelper8: j redrawScreen

# first log row
l3: lw $t0, frogx 
lw $t1, log3x 
subi $t2, $t1, 32 
subi $t3, $t1, 16 

slti $s1, $t1, 80
bnez $s1, check7 

sub $t4, $t1, $t1 
subi $t5, $t1, 80


slt $s1, $t0, $t2
slt $s2, $t3, $t0
beqz $s1, operation
bnez $s2, operation
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j redrawScreen

operation: 
slt $s1, $t0, $t4 
slt $s2, $t5, $t0 
beqz $s1, exitOperation
bnez $s2, exitOperation
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
exitOperation: j redrawScreen

check7: 
addi $t3, $t1, 32 
addi $t4, $t1, 48 


slt $s1, $t0, $t2 
slt $s2, $t3, $t0 
beqz $s1, helper9
bnez $s2, helper9
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j redrawScreen


helper9: 
slt $s1, $t0, $t4 
slt $s2, $t5, $t0 
beqz $s1, quit
bnez $s2, quit
li $t0, 56
sw $t0, 0($t8)
lw $t1, livesNumber
la $s7, livesNumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
quit: j redrawScreen


# retry screen
Retry:
lw $t0, displayAddress
	lw $t2, lives
		
	# I
	addi $t1, $zero, 592
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 560
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 528
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 496
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
		
	addi $t1, $zero, 464
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
		
	# D
	addi $t1, $zero, 584
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 552
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 520
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 488
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
		
	addi $t1, $zero, 456
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	
	addi $t1, $zero, 585
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 554
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 522
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 490
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
		
	addi $t1, $zero, 457
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	# E
	addi $t1, $zero, 598
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	addi $t1, $zero, 599
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	addi $t1, $zero, 600
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 566
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 534
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	addi $t1, $zero, 535
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	addi $t1, $zero, 536
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 502
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
		
	addi $t1, $zero, 470
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	addi $t1, $zero, 471
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	addi $t1, $zero, 472
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
li $v0, 32
li $a0, 4000
syscall		
li $v0,4       
la $a0, text  
syscall
li $a0, 50  # sound
li $a1, 5000
li $a2, 55
li $a3, 127
li $v0, 31     
syscall

Draw2:
addi $a1, $s0, 0  
addi $a2, $a1, 512 
lw $a0, frogalive
jal largeRec
addi $a1, $s0, 512  
addi $a2, $a1, 512 
lw $a0, blue
jal largeRec
addi $a1, $s0, 1024  
addi $a2, $a1, 512 
lw $a0, green
jal largeRec
addi $a1, $s0, 1536  
addi $a2, $a1, 512 
lw $a0, peach
jal largeRec
addi $a1, $s0, 2048  
addi $a2, $a1, 512 
lw $a0, yellow
jal largeRec
addi $a1, $s0, 2560  
addi $a2, $a1, 512 
lw $a0, brown
jal largeRec
addi $a1, $s0, 3072  
addi $a2, $a1, 512 
lw $a0, frogwin
jal largeRec
addi $a1, $s0, 3072  
addi $a2, $a1, 512 
lw $a0, blue
jal largeRec
addi $a1, $s0, 3584 
addi $a2, $a1, 512 
lw $a0, frogalive
jal largeRec

lw $t8, 0xffff0000
beq $t8, 1, check_in

li $v0, 32
Waiting: li $a0, 500
syscall

j Draw2

check_in: addi $t8, $zero, 0
lw $t2, 0xffff0004
beq $t2, 0x65, Exit
beq $t2, 0x72, respondToR

respondToR:
la $t8 frogy
li $t0, 56
sw $t0, 0($t8)
la $t3, win
sw $zero, 0($t3)
la $t3, livesNumber
sw $zero, 0($t3)
li $a0, 33  # sound
li $a1, 5000
li $a2, 55
li $a3, 127
li $v0, 31     
syscall
j gameLoop

Exit: li $v0, 10        # terminate the program gracefully
syscall

# Functions:
largeRec:
Loop: beq $a1, $a2, Return
sw $a0, 0($a1)
addi $a1, $a1, 4
j Loop
Return: jr $ra

drawFrogFunc:
Loop4: beq $a1, $a2, Return3
addi $t1, $a1, 16
Loop5: beq $a1, $t1, y
sw $a0, 0($a1)
addi $a1, $a1, 4
j Loop5
y: addi $a1, $a1, 112
j Loop4
Return3: jr $ra

smallRect:
Loop2: beq $a1, $a2, Return2
add $t1, $a1, $a3 
Loop3: beq $a1, $t1, x
sw $a0, 0($a1)
addi $a1, $a1, 4
j Loop3
x: add $a1, $a1, $v0
j Loop2
Return2: jr $ra
