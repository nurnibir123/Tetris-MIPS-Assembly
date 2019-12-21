# CSE 220 Programming Project #3
# erase this line and type your first and last name in a comment here
# erase this line and type your Net ID here (e.g., jmsmith) in a comment here
# erase this line and type your SBU ID # here (e.g., 111234567) in a comment here

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
initialize:
	move $t9, $a0
	blez $a1, initialize.invalid.args
	blez $a2, initialize.invalid.args
	
	move $v0, $a1
	sb $v0, 0($a0)
	addi $a0, $a0, 1
	move $v1, $a2
	sb $v1, 0($a0)
	addi $a0, $a0, 1
	mul  $t0, $a1, $a2			# get total length row*col
	
	li $t1, 0				# counter i = 0
	loop.initialize:
	bge $t1, $t0, exit.loop.initialize
	
	sb $a3, 0($a0)
	
	addi $a0, $a0, 1
	addi $t1, $t1, 1
	j loop.initialize
	
	
	initialize.invalid.args:
	li $v0, -1
	li $v1, -1
	
	exit.loop.initialize:
	move $a0, $t9
	jr $ra

load_game:
    move $s0, $a0		# state in $s0
    move $s1, $a1		# filename in $s1
    li $v0, 13			# open file syscall
    move $a0, $s1		# filename in $a0
    li $a1, 0 			# open for reading
    li $a2, 0		
    syscall
    li $t0, -1
    beq $v0, $t0, file.not.found
    move $s6, $v0		# save the file descriptor
    

    li $v0, 14 		# read file syscall
    move $a0, $s6	# file descriptor
    addi $sp, $sp, -1	# allocate one byte of memory to stack
    move $a1, $sp	# buffer
    li $a2, 1		# max chars 
    syscall 
    lb $t0, 0($sp)	# load byte into $t0


    li $v0,  14		# read file syscall
    syscall		
    lb $t1, 0($sp)
    li $t2, '\n'
    beq $t1, $t2, one.digit.row.number
    
    li $v0, 14
    syscall
    lb $t3, 0($sp)
    li $t2, '\n'
    beq $t3, $t2, two.digit.row.number
    
    one.digit.row.number:
    addi $t0, $t0, -48
    sb $t0, 0($s0)
    addi $s0, $s0, 1
    move $t5, $t0
    j get.column.number
    
    
    two.digit.row.number:
    addi $t0, $t0, -48
    addi $t1, $t1, -48
    li $t4, 10
    mul $t0, $t0, $t4
    add $t4, $t1, $t0
    sb $t4, 0($s0)
    addi $s0, $s0, 1
    move $t5, $t4
    j get.column.number
    
    
    
    get.column.number:
    li $v0, 14
    syscall
    lb $t0, 0($sp)	# load byte into $t0
    
    li $v0,  14		# read file syscall
    syscall		
    lb $t1, 0($sp)
    li $t2, '\n'
    beq $t1, $t2, one.digit.col.number
    
    
    li $v0, 14
    syscall
    lb $t3, 0($sp)
    li $t2, '\n'
    beq $t3, $t2, two.digit.col.number
    
    
    one.digit.col.number:
    addi $t0, $t0, -48
    sb $t0, 0($s0)
    addi $s0, $s0, 1
    move $t6, $t0 
    j create.state
    
    
    two.digit.col.number:
    addi $t0, $t0, -48
    addi $t1, $t1, -48
    li $t4, 10
    mul $t0, $t0, $t4
    add $t4, $t1, $t0
    sb $t4, 0($s0)
    move $t6, $t4 
    addi $s0, $s0, 1
    j create.state
    
    
    
    create.state:
    mul $t7, $t5, $t6				# store row*col in t7
    li $t8, 0					# counter i = 0
    li $t5, 0					# counter for invalid chars
    li $t6, 0					# counter for # of Os
    
    loop.for.create.state:
    bge $t8, $t7, exit.loop.for.create.state
    li $v0, 14 
    syscall
    lb $t0, 0($sp)
    li $t1, 'O'
    bne $t0, $t1, check.dot
    sb $t1, 0($s0)
    addi $s0, $s0, 1			
    addi $t8, $t8, 1				# counter++
    addi $t6, $t6, 1				# # of Os ++
    j loop.for.create.state
    
    
    check.dot:
    li $t1, '.'
    bne $t0, $t1, check.newLine.char
    sb $t1, 0($s0)
    addi $s0, $s0, 1			
    addi $t8, $t8, 1				# counter++
    j loop.for.create.state
    
    
    check.newLine.char:
    li $t1, '\n'
    beq $t0, $t1, loop.for.create.state
    
    
    li $t1, '.'
    sb $t1, 0($s0)
    addi $s0, $s0, 1
    addi $t8, $t8, 1
    addi $t5, $t5, 1
    j loop.for.create.state
    
	
    exit.loop.for.create.state:
    addi $sp, $sp, 1
    move $v0, $t6
    move $v1, $t5
    move $a1, $s0
    
    file.not.found:
    jr $ra


get_slot:
    move $t0, $a0		# load struct into $t0
    lb $t1, 0($t0)		# get # of rows
    addi $t0, $t0, 1		
    lb $t2, 0($t0)		# get # of columns 
    addi $t0, $t0, 1
    bltz $a1, invalid.rowcol1.number
    bltz $a2, invalid.rowcol1.number
    bge $a1, $t1, invalid.rowcol1.number
    bge $a2, $t2, invalid.rowcol1.number
  
    mul $t3, $a1, $t2		# store row*col in t3
    add $t3, $t3, $a2
    add $t0, $t0, $t3		
    
    lbu $v0, 0($t0)		# store char into v0
    jr $ra
   
    invalid.rowcol1.number:
    li $v0, -1
    jr $ra
    
    
set_slot:
    move $t0, $a0		# load struct into $t0
    lb $t1, 0($t0)		# get row #
    addi $t0, $t0, 1		
    lb $t2, 0($t0)		# get col #
    addi $t0, $t0, 1
    bltz $a1, invalid.rowcol.number
    bltz $a2, invalid.rowcol.number
    bge $a1, $t1, invalid.rowcol.number
    bge $a2, $t2, invalid.rowcol.number
  
    mul $t3, $a1, $t2		# store row*col in t3
    add $t3, $t3, $a2
    add $t0, $t0, $t3		
    
    sb $a3, 0($t0)		# store char into v0
    move $v0, $a3
    jr $ra			
   
    invalid.rowcol.number:
    li $v0, -1
    jr $ra


rotate:
    addi $sp, $sp, -24
    sw $s0, 0($sp)		# piece 	
    sw $s1, 4($sp)		# rotation
    sw $s2, 8($sp)		# rotated piece
    sw $s3, 12($sp)		# # of rows
    sw $s4, 16($sp)		# # of colms
    sw $s5, 20($sp)		# rotated piece 
    sw $ra, 24($sp)
    
    move $s5, $a2
    
    move $s0, $a0		# piece in s0
    move $s1, $a1		# rotation in s1
    move $s2, $a2 		# rotated piece in s2
    
 
    blez $s1, invalid.rotation
    lbu $s3, 0($s0)		# get # of rows		
    lbu $s4, 1($s0)		# get # of colms
   
    li $t1, 2
    beq $s3, $t1, check.if.square.piece
    
    check.if.square.piece:
    li $t1, 2
    beq $s4, $t1, is.square.piece
   
    li $t1, 1
    beq $s3, $t1, if.rowscols.is.one
    beq $s4, $t1, if.rowscols.is.one
    j is.not.O.or.I
    
    
    if.rowscols.is.one:
    sb $s3, 0($s2)
    sb $s4, 1($s2)
    li $t1, 'O'
    sb $t1, 2($s2)
    sb $t1, 3($s2)
    sb $t1, 4($s2)
    sb $t1, 5($s2)
    li $t1, '.'
    sb $t1, 6($s2)
    sb $t1, 7($s2)
    
    li $t1, 0		# counter for loop
    loop.for.I.piece:
    bge $t1, $s1, exit.loop.for.I.piece
    move $t2, $s3	# copy s3 into t2
    move $s3, $s4	# copy s4 into s3
    move $s4, $t2	# copy s3 into s4
    
    sb $s3, 0($s2)
    sb $s4, 1($s2)
    
    addi $t1, $t1, 1	# counter++
    j loop.for.I.piece
    
    
    exit.loop.for.I.piece:
    move $a2, $s2
    move $v0, $s1
    j exit.rotate
    

    is.square.piece:
    li $t1, 2
    sb $t1, 0($s2)
    sb $t1, 1($s2)
    li $t1, 'O'
    sb $t1, 2($s2)
    sb $t1, 3($s2)
    sb $t1, 4($s2)
    sb $t1, 5($s2)
    li $t1, '.'
    sb $t1, 6($s2)
    sb $t1, 7($s2)
    move $a2, $s2
    move $v0, $s1
    j exit.rotate
    
   
    is.not.O.or.I:
    li $t1, 2
    beq $s3, $t1, row.is.two.three    # check there are two rows
    li $t1, 3
    beq $s3, $t1, row.is.two.three
    
    
    row.is.two.three:
    li $s7, 0			# counter for loop i = 0
    j loop.for.two.three
   
    
    loop.for.two.three:
    bge $s7, $s1, exit.loop.for.two.three
    
    li $t1, 2
    beq $s3, $t1, if.row.is.two   
    li $t1, 3
    beq $s3, $t1, if.row.is.three


    if.row.is.two:
    move $t1, $s3		# copy $s3 into t1
    move $s3, $s4		# copy $s4 into $s3
    move $s4, $t1		# copy $s3 into $s4
	   
    move $a0, $s2		# copy rotated piece into a0
    move $a1, $s3		# put # of rows into a1
    move $a2, $s4		# put # of colms into a2
    li $a3, '.'			# fill rotated piece with '.'
   
   
    jal initialize
    move $s2, $a0		# put initialized rotated piece back into s2
    
    
    #getslot(1,0)
    move $a0, $s0		
    li $a1, 1
    li $a2, 0
    jal get_slot
    		
    #setslot(0,0)
    move $a0, $s2		# copy rotated piece into a0
    li $a1, 0
    li $a2, 0
    move $a3, $v0		# copy char of get_slot into a3
    jal set_slot
    move $s2, $a0
   
   
    #getslot(0,0)
    move $a0, $s0		
    li $a1, 0
    li $a2, 0
    jal get_slot
    
    
    #setslot(0,1)
    move $a0, $s2		# copy rotated piece into a0
    li $a1, 0
    li $a2, 1
    move $a3, $v0		# copy char of get_slot into a3
    jal set_slot
    move $s2, $a0
    
    
    #getslot(1,1)
    move $a0, $s0		
    li $a1, 1
    li $a2, 1
    jal get_slot
    
    
    #setslot(1,0)
    move $a0, $s2		# copy rotated piece into a0
    li $a1, 1
    li $a2, 0
    move $a3, $v0		# copy char of get_slot into a3
    jal set_slot
    move $s2, $a0
    
    #getslot(0,1)
    move $a0, $s0		
    li $a1, 0
    li $a2, 1
    jal get_slot
    
    
    #setslot(1,1)
    move $a0, $s2		# copy rotated piece into a0
    li $a1, 1
    li $a2, 1
    move $a3, $v0		# copy char of get_slot into a3
    jal set_slot
    move $s2, $a0
    
    
    #getslot(1,2)
    move $a0, $s0		
    li $a1, 1
    li $a2, 2
    jal get_slot
    
    
    #setslot(2,0)
    move $a0, $s2		# copy rotated piece into a0
    li $a1, 2
    li $a2, 0
    move $a3, $v0		# copy char of get_slot into a3
    jal set_slot
    move $s2, $a0
    
    
    #getslot(0,2)
    move $a0, $s0		
    li $a1, 0
    li $a2, 2
    jal get_slot
    
    
    #setslot(2,1)
    move $a0, $s2		# copy rotated piece into a0
    li $a1, 2
    li $a2, 1
    move $a3, $v0		# copy char of get_slot into a3
    jal set_slot
    move $s2, $a0

    
    lb $t0, 0($s2)
    sb $t0, 0($s0)
    lb $t0, 1($s2)
    sb $t0, 1($s0)
    lb $t0, 2($s2)
    sb $t0, 2($s0)
    lb $t0, 3($s2)
    sb $t0, 3($s0)
    lb $t0, 4($s2)
    sb $t0, 4($s0)
    lb $t0, 5($s2)
    sb $t0, 5($s0)
    lb $t0, 6($s2)
    sb $t0, 6($s0)
    lb $t0, 7($s2)
    sb $t0, 7($s0)
   
    addi $s7, $s7, 1
    j loop.for.two.three


    if.row.is.three:
    move $t1, $s3		# copy $s3 into t1
    move $s3, $s4		# copy $s4 into $s3
    move $s4, $t1		# copy $s3 into $s4
     
    move $a0, $s2		# copy rotated piece into a0
    move $a1, $s3		# put # of rows into a1
    move $a2, $s4		# put # of colms into a2
    li $a3, '.'		# fill rotated piece with '.'
    
    jal initialize
    move $s2, $a0		# put initialized rotated piece back into s2
    
    
    #getslot(2,0)
    move $a0, $s0		
    li $a1, 2
    li $a2, 0
    jal get_slot
    
    #setslot(0,0)
    move $a0, $s2		# copy rotated piece into a0
    li $a1, 0
    li $a2, 0
    move $a3, $v0		# copy char of get_slot into a3
    jal set_slot
    move $s2, $a0
    
    #getslot(1,0)
    move $a0, $s0		
    li $a1, 1
    li $a2, 0
    jal get_slot
    
    #setslot(0,1)
    move $a0, $s2		# copy rotated piece into a0
    li $a1, 0
    li $a2, 1
    move $a3, $v0		# copy char of get_slot into a3
    jal set_slot
    move $s2, $a0
    
    
    #getslot(0,0)
    move $a0, $s0		
    li $a1, 0
    li $a2, 0
    jal get_slot
    
    
    #setslot(0,2)
    move $a0, $s2		# copy rotated piece into a0
    li $a1, 0
    li $a2, 2
    move $a3, $v0		# copy char of get_slot into a3
    jal set_slot
    move $s2, $a0
    
    
    #getslot(2,1)
    move $a0, $s0		
    li $a1, 2
    li $a2, 1
    jal get_slot
    
    
    #setslot(1,0)
    move $a0, $s2		# copy rotated piece into a0
    li $a1, 1
    li $a2, 0
    move $a3, $v0		# copy char of get_slot into a3
    jal set_slot
    move $s2, $a0
    
    
    #getslot(1,1)
    move $a0, $s0		
    li $a1, 1
    li $a2, 1
    jal get_slot
    
    
    #setslot(1,1)
    move $a0, $s2		# copy rotated piece into a0
    li $a1, 1
    li $a2, 1
    move $a3, $v0		# copy char of get_slot into a3
    jal set_slot
    move $s2, $a0
    
    
    #getslot(0,1)
    move $a0, $s0		
    li $a1, 0
    li $a2, 1
    jal get_slot
    
    
    #setslot(1,2)
    move $a0, $s2		# copy rotated piece into a0
    li $a1, 1
    li $a2, 2
    move $a3, $v0		# copy char of get_slot into a3
    jal set_slot
    move $s2, $a0
    
    
    lb $t0, 0($s2)
    sb $t0, 0($s0)
    lb $t0, 1($s2)
    sb $t0, 1($s0)
    lb $t0, 2($s2)
    sb $t0, 2($s0)
    lb $t0, 3($s2)
    sb $t0, 3($s0)
    lb $t0, 4($s2)
    sb $t0, 4($s0)
    lb $t0, 5($s2)
    sb $t0, 5($s0)
    lb $t0, 6($s2)
    sb $t0, 6($s0)
    lb $t0, 7($s2)
    sb $t0, 7($s0)
   
    addi $s7, $s7, 1
    j loop.for.two.three
    
    
    exit.loop.for.two.three:
    
    move $a2, $s5
    move $v0, $s7
    j exit.rotate
    
    
    invalid.rotation:
    li $v0, -1
    j exit.rotate
    
    
    exit.rotate:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 24

    jr $ra

count_overlaps:
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp)
	
	move $s0, $a0		# copy state into $s0
	move $s1, $a1		# move row into $s1
	move $s2, $a2		# move colm into $s2
	move $s3, $a3		# move piece into $s3
	li $s4, 'O'
	li $s5, 0		# counter
	
	bltz $s1, invalid.count.overlaps
	bltz $s2, invalid.count.overlaps
	lbu $t0, 0($s0)				# get # of rows of state
	lbu $t1, 1($s0)				# get # of colms of state
	bge $s1, $t0, invalid.count.overlaps
	bge $s2, $t1, invalid.count.overlaps
	
	lb $t0, 0($s3)
	lb $t1, 1($s3)
	beq $t0, $t1, is.square.count.overlaps
	li $t2, 4
	beq $t0, $t2, is.I.4r.count.overlaps
	beq $t1, $t2, is.I.1r.count.overlaps
	
	j is.2or3.count.overlaps
	
	
	is.square.count.overlaps:
	# (row, colm)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	bne $v0, $s4, square1.count.overlaps
	addi $s5, $s5, 1			# counter++
	
	square1.count.overlaps:
	# (row+1, colm)
	move $a0, $s0
	move $a1, $s1
	addi $a1, $a1, 1
	move $a2, $s2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	bne $v0, $s4, square2.count.overlaps
	addi $s5, $s5, 1
	
	square2.count.overlaps:
	# (row, colm+1)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	addi $a2, $a2, 1
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	bne $v0, $s4, square3.count.overlaps
	addi $s5, $s5, 1
	
	square3.count.overlaps:
	# (row+1, colm+1)
	move $a0, $s0
	move $a1, $s1
	addi $a1, $a1, 1
	move $a2, $s2
	addi $a2, $a2, 1
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	bne $v0, $s4, exit.count.overlaps
	addi $s5, $s5, 1
	j exit.count.overlaps
	
	
	
	is.I.4r.count.overlaps:
	# (row, colm)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot
	
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	bne $v0, $s4, I.4r1.count.overlaps
	addi $s5, $s5, 1
	

	I.4r1.count.overlaps:
	# (row+1, colm)
	move $a0, $s0
	move $a1, $s1
	addi $a1, $a1, 1
	move $a2, $s2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	bne $v0, $s4, I.4r2.count.overlaps
	addi $s5, $s5, 1
	
	
	I.4r2.count.overlaps:
	# (row+2, colm)
	move $a0, $s0
	move $a1, $s1
	addi $a1, $a1, 2
	move $a2, $s2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	bne $v0, $s4, I.4r3.count.overlaps
	addi $s5, $s5, 1
	
	
	I.4r3.count.overlaps:
	# (row+3, colm)
	move $a0, $s0
	move $a1, $s1
	addi $a1, $a1, 3
	move $a2, $s2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	bne $v0, $s4, exit.count.overlaps
	addi $s5, $s5, 1
	j exit.count.overlaps
	
	
	
	is.I.1r.count.overlaps:
	# (row, colm)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	bne $v0, $s4, I.1r1.count.overlaps
	addi $s5, $s5, 1
	
	
	I.1r1.count.overlaps:
	# (row, colm+1)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	addi $a2, $a2, 1
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	bne $v0, $s4, I.1r2.count.overlaps
	addi $s5, $s5, 1
	
	
	I.1r2.count.overlaps:
	# (row, colm+2)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	addi $a2, $a2, 2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	bne $v0, $s4, I.1r3.count.overlaps
	addi $s5, $s5, 1
	
	
	I.1r3.count.overlaps:
	# (row, colm+3)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	addi $a2, $a2, 3
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	bne $v0, $s4, exit.count.overlaps
	addi $s5, $s5, 1
	j exit.count.overlaps
	
	
	
	is.2or3.count.overlaps:
	li $t3, 2
	bne $t0, $t3, other.3.2.count.overlaps
	# 2 3
	# (row, col)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	lbu $t0, 2($s3)
	bne $t0, $s4, other.2.3.1.count.overlaps
	bne $v0, $s4, other.2.3.1.count.overlaps
	addi $s5, $s5, 1
	
	
	other.2.3.1.count.overlaps:
	# (row, colm+1)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	addi $a2, $a2, 1
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	lbu $t0, 3($s3)
	bne $t0, $s4, other.2.3.2.count.overlaps
	bne $v0, $s4, other.2.3.2.count.overlaps
	addi $s5, $s5, 1
	
	
	other.2.3.2.count.overlaps:
	#  (row, colm+2)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	addi $a2, $a2, 2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	lbu $t0, 4($s3)
	bne $t0, $s4, other.2.3.3.count.overlaps
	bne $v0, $s4, other.2.3.3.count.overlaps
	addi $s5, $s5, 1
	
	
	other.2.3.3.count.overlaps:
	# (row+1, colm)
	move $a0, $s0
	move $a1, $s1
	addi $a1, $a1, 1
	move $a2, $s2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	lbu $t0, 5($s3)
	bne $t0, $s4, other.2.3.4.count.overlaps
	bne $v0, $s4, other.2.3.4.count.overlaps
	addi $s5, $s5, 1
	
	
	other.2.3.4.count.overlaps:
	# (row+1, colm+1)
	move $a0, $s0
	move $a1, $s1
	addi $a1, $a1, 1
	move $a2, $s2
	addi $a2, $a2, 1
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	lbu $t0, 6($s3)
	bne $t0, $s4, other.2.3.5.count.overlaps
	bne $v0, $s4, other.2.3.5.count.overlaps
	addi $s5, $s5, 1
	
	
	other.2.3.5.count.overlaps:
	move $a0, $s0
	move $a1, $s1
	addi $a1, $a1, 1
	move $a2, $s2
	addi $a2, $a2, 2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	lbu $t0, 7($s3)
	bne $t0, $s4, exit.count.overlaps
	bne $v0, $s4, exit.count.overlaps
	addi $s5, $s5, 1
	j exit.count.overlaps
	
	
	other.3.2.count.overlaps:
	# (row, colm)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	lbu $t0, 2($s3)
	bne $t0, $s4, other.3.2.1.count.overlaps
	bne $v0, $s4, other.3.2.1.count.overlaps
	addi $s5, $s5, 1
	
	
	other.3.2.1.count.overlaps:
	# (row, colm+1)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	addi $a2, $a2, 1
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	lbu $t0, 3($s3)
	bne $t0, $s4, other.3.2.2.count.overlaps
	bne $v0, $s4, other.3.2.2.count.overlaps
	addi $s5, $s5, 1	
	
	
	other.3.2.2.count.overlaps:
	# (row+1, colm)
	move $a0, $s0
	move $a1, $s1
	addi $a1, $a1, 1
	move $a2, $s2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	lbu $t0, 4($s3)
	bne $t0, $s4, other.3.2.3.count.overlaps
	bne $v0, $s4, other.3.2.3.count.overlaps
	addi $s5, $s5, 1
	
	
	other.3.2.3.count.overlaps:
	# (row+1, colm+1)
	move $a0, $s0
	move $a1, $s1
	addi $a1, $a1, 1
	move $a2, $s2
	addi $a2, $a2, 1
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	lbu $t0, 5($s3)
	bne $t0, $s4, other.3.2.4.count.overlaps
	bne $v0, $s4, other.3.2.4.count.overlaps
	addi $s5, $s5, 1
	
	
	other.3.2.4.count.overlaps:
	# (row+2, colm)
	move $a0, $s0
	move $a1, $s1
	addi $a1, $a1, 2
	move $a2, $s2
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	lbu $t0, 6($s3)
	bne $t0, $s4, other.3.2.5.count.overlaps
	bne $v0, $s4, other.3.2.5.count.overlaps
	addi $s5, $s5, 1
	
	
	other.3.2.5.count.overlaps:
	# (row+2, col+1)
	move $a0, $s0
	move $a1, $s1
	addi $a1, $a1, 2
	move $a2, $s2
	addi $a2, $a2, 1
	jal get_slot
	
	li $t0, -1
	beq $v0, $t0, invalid.count.overlaps
	lbu $t0, 7($s3)
	bne $t0, $s4, exit.count.overlaps
	bne $v0, $s4, exit.count.overlaps
	addi $s5, $s5, 1
	j exit.count.overlaps
	
	
	invalid.count.overlaps:
	li $v0, -1
	j exit2.count.overlaps
	
	
	exit.count.overlaps:
	move $v0, $s5
	
	
	exit2.count.overlaps:
	lw $s0, 0($sp)
    	lw $s1, 4($sp)
    	lw $s2, 8($sp)
    	lw $s3, 12($sp)
    	lw $s4, 16($sp)
    	lw $s5, 20($sp)
    	lw $ra, 24($sp)
    	addi $sp, $sp, 24
	jr $ra

drop_piece:
	lw $t0, 0($sp)
    
    addi $sp, $sp, -28
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)        # stores row # of where piece will be dropped
    sw $s5, 20($sp)        # store rotated piece
    sw $s6, 24($sp)    
    sw $ra, 28($sp)    
    
    move $s5, $t0        # copy rotated piece into $s5
    move $s0, $a0        # copy state into $s0
    move $s1, $a1        # copy colm into $s1
    move $s2, $a2        # copy piece into $s2
    move $s3, $a3        # copy rotation into $s3
    li $s6, 'O'

    
    bltz $s1, invalid.col.drop.piece
    lbu $t0, 1($s0)
    bge $s1, $t0, invalid.col.drop.piece
    
    move $a0, $s2        # copy piece into $a0
    move $a1, $s3        # move rotation into $a1
    move $a2, $s5        # move piece into $a2
    
    jal rotate
    
    bltz $v0, invalid.rotation.drop.piece
    
    
    move $s5, $a2
    
    
    lbu $t0, 1($s5)        # get # of colms of rotated piece
    add $t1, $s1, $t0    # col + piece.num_colms
    lbu $t2, 1($s0)        # get num_cols of state
    bge $t1, $t2, out.of.bounds.drop.piece
    
    
    # check if piece can be added
    move $a0, $s0        # copy state into $a0
    li $a1, 0        # check row 0
    move $a2, $s1        # copy colm into a2
    move $a3, $s5        # copy rotated piece into a3
    jal count_overlaps
    bnez $v0, cant.drop.piece
    
    li $s7, 0        # row #
    loop.for.drop.piece:
    move $a0, $s0        # copy state into $a0
    move $a1, $s7        # check row 0
    move $a2, $s1        # copy colm into a2
    move $a3, $s5        # copy rotated piece into a3
    jal count_overlaps
    bnez $v0, decide.which.piece.drop
    addi $s7, $s7, 1
    j loop.for.drop.piece
    
    
    
    decide.which.piece.drop:
    lbu $t0, 0($s5)            # num_rows of rotated piece
    lbu $t1, 1($s5)            # num_colms of rotated piece
    addi $s7, $s7, -1
    beq $t0, $t1, square.drop.piece
    li $t2, 4
    beq $t0, $t2, I.4.1.drop.piece
    beq $t1, $t2, I.1.4.drop.piece
    
    j other.2or3.drop.piece
    
    
    square.drop.piece:
    # (row, col)
    move $a0, $s0            # copy state into $a0
    move $a1, $s7            # copy row # into a1
    move $a2, $s1            # copy colm into a2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    # (row+1, col)
    move $a0, $s0            # copy state into $a0
    move $a1, $s7            # copy row # into a1
    addi $a1, $a1, 1
    move $a2, $s1            # copy colm into a2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    # (row, col+1)
    move $a0, $s0            # copy state into $a0
    move $a1, $s7            # copy row # into a1
    move $a2, $s1            # copy colm into a2
    addi $a2, $a2, 1        
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    # (row+1, col+1)
    move $a0, $s0            # copy state into $a0
    move $a1, $s7            # copy row # into a1
    addi $a1, $a1, 1
    move $a2, $s1            # copy colm into a2
    addi $a2, $a2, 1        
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    j exit.drop.piece
    
    
    I.4.1.drop.piece:
    # (row, col)
    move $a0, $s0            # copy state into $a0
    move $a1, $s7            # copy row # into a1
    move $a2, $s1            # copy colm into a2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    
    # (row+1, col)
    move $a0, $s0            # copy state into $a0
    move $a1, $s7            # copy row # into a1
    addi $a1, $a1, 1
    move $a2, $s1            # copy colm into a2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    # (row+2, col)
    move $a0, $s0            # copy state into $a0
    move $a1, $s7            # copy row # into a1
    addi $a1, $a1, 2
    move $a2, $s1            # copy colm into a2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    # (row+3, col)
    move $a0, $s0            # copy state into $a0
    move $a1, $s7            # copy row # into a1
    addi $a1, $a1, 3
    move $a2, $s1            # copy colm into a2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    j exit.drop.piece
    
    
    I.1.4.drop.piece:
    # (row, col)
    move $a0, $s0            # copy state into $a0
    move $a1, $s7            # copy row # into a1
    move $a2, $s1            # copy colm into a2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    # (row, col+1)
    move $a0, $s0            # copy state into $a0
    move $a1, $s7            # copy row # into a1
    move $a2, $s1            # copy colm into a2
    addi $a2, $a2, 1
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    # (row, col+2)
    move $a0, $s0            # copy state into $a0
    move $a1, $s7            # copy row # into a1
    move $a2, $s1            # copy colm into a2
    addi $a2, $a2, 2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    
    # (row, col+3)
    move $a0, $s0            # copy state into $a0
    move $a1, $s7            # copy row # into a1
    move $a2, $s1            # copy colm into a2
    addi $a2, $a2, 3
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    j exit.drop.piece
    
    
    other.2or3.drop.piece:
    #lbu $t0, 0($s5)            # num_rows of rotated piece
    li $t1, 3
    bne $t0, $t1, other.23.drop.piece
    
    # 3 2 piece
    # get(0,0)
    move $a0, $s5            # copy rotated piece into a0
    li $a1, 0
    li $a2, 0
    jal get_slot
    bne $v0, $s6, other.32.drop.piece1
    # set(row, col)
    move $a0, $s0            # copy state into a0
    move $a1, $s7            # copy row into a1
    move $a2, $s1            # copy colm into a2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot    
    
    
    other.32.drop.piece1:
    # get(0, 1)
    move $a0, $s5            # copy rotated piece into a0
    li $a1, 0
    li $a2, 1
    jal get_slot
    bne $v0, $s6, other.32.drop.piece2
    # set(row, col+1)
    move $a0, $s0            # copy state into a0
    move $a1, $s7            # copy row into a1
    move $a2, $s1            # copy colm into a2
    addi $a2, $a2, 1
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
        
    other.32.drop.piece2:
    # get(1, 0)
    move $a0, $s5            # copy rotated piece into a0
    li $a1, 1
    li $a2, 0
    jal get_slot
    bne $v0, $s6, other.32.drop.piece3
    # set(row+1, col)
    move $a0, $s0            # copy state into a0
    move $a1, $s7            # copy row into a1
    addi $a1, $a1, 1
    move $a2, $s1            # copy colm into a2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot            
    
    
    
    other.32.drop.piece3:
    # get(1, 1)
    move $a0, $s5            # copy rotated piece into a0
    li $a1, 1
    li $a2, 1
    jal get_slot
    bne $v0, $s6, other.32.drop.piece4
    # set(row+1, col+1)
    move $a0, $s0            # copy state into a0
    move $a1, $s7            # copy row into a1
    addi $a1, $a1, 1
    move $a2, $s1            # copy colm into a2
    addi $a2, $a2, 1
    move $a3, $s6            # copy 'O' into a3
    jal set_slot        
    
    
    
    other.32.drop.piece4:
    # get(2, 0)
    move $a0, $s5            # copy rotated piece into a0
    li $a1, 2
    li $a2, 0
    jal get_slot
    bne $v0, $s6, other.32.drop.piece5
    # set(row+2, col)
    move $a0, $s0            # copy state into a0
    move $a1, $s7            # copy row into a1
    addi $a1, $a1, 2
    move $a2, $s1            # copy colm into a2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot        
    

    other.32.drop.piece5:
    # get(2, 1)
    move $a0, $s5            # copy rotated piece into a0
    li $a1, 2
    li $a2, 1
    jal get_slot
    bne $v0, $s6, exit.drop.piece
    # set(row+2, col)
    move $a0, $s0            # copy state into a0
    move $a1, $s7            # copy row into a1
    addi $a1, $a1, 2
    move $a2, $s1            # copy colm into a2
    addi $a2, $a2, 1
    move $a3, $s6            # copy 'O' into a3
    jal set_slot    

    j exit.drop.piece




    other.23.drop.piece:
    # get(0,0)
    move $a0, $s5            # copy rotated piece into a0
    li $a1, 0
    li $a2, 0
    jal get_slot
    bne $v0, $s6, other.23.drop.piece1
    # set(row, col)
    move $a0, $s0            # copy state into a0
    move $a1, $s7            # copy row into a1
    move $a2, $s1            # copy colm into a2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    
    other.23.drop.piece1:
    # get(0,1)
    move $a0, $s5            # copy rotated piece into a0
    li $a1, 0
    li $a2, 1
    jal get_slot
    bne $v0, $s6, other.23.drop.piece2
    # set(row, col+1)
    move $a0, $s0            # copy state into a0
    move $a1, $s7            # copy row into a1
    move $a2, $s1            # copy colm into a2
    addi $a2, $a2, 1
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    
    other.23.drop.piece2:
    # get(0,2)
    move $a0, $s5            # copy rotated piece into a0
    li $a1, 0
    li $a2, 2
    jal get_slot
    bne $v0, $s6, other.23.drop.piece3
    # set(row, col+2)
    move $a0, $s0            # copy state into a0
    move $a1, $s7            # copy row into a1
    move $a2, $s1            # copy colm into a2
    addi $a2, $a2, 2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    
    other.23.drop.piece3:
    # get(1,0)
    move $a0, $s5            # copy rotated piece into a0
    li $a1, 1
    li $a2, 0
    jal get_slot
    bne $v0, $s6, other.23.drop.piece4
    # set(row+1, col)
    move $a0, $s0            # copy state into a0
    move $a1, $s7            # copy row into a1
    addi $a1, $a1, 1
    move $a2, $s1            # copy colm into a2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    
    other.23.drop.piece4:
    # get(1,1)
    move $a0, $s5            # copy rotated piece into a0
    li $a1, 1
    li $a2, 1
    jal get_slot
    bne $v0, $s6, other.23.drop.piece5
    # set(row+1, col+1)
    move $a0, $s0            # copy state into a0
    move $a1, $s7            # copy row into a1
    addi $a1, $a1, 1
    move $a2, $s1            # copy colm into a2
    addi $a2, $a2, 1
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    
    
    other.23.drop.piece5:
    # get(1,2)
    move $a0, $s5            # copy rotated piece into a0
    li $a1, 1
    li $a2, 2
    jal get_slot
    bne $v0, $s6, exit.drop.piece
    # set(row+1, col+2)
    move $a0, $s0            # copy state into a0
    move $a1, $s7            # copy row into a1
    addi $a1, $a1, 1
    move $a2, $s1            # copy colm into a2
    addi $a2, $a2, 2
    move $a3, $s6            # copy 'O' into a3
    jal set_slot
    j exit.drop.piece
    
    
    exit.drop.piece:
    move $v0, $s7
    move $a0, $s0            
    j exit.drop.piece2
    

    cant.drop.piece:
    li $v0, -1
    j exit.drop.piece2
    
    
    out.of.bounds.drop.piece:
    li $v0, -3
    j exit.drop.piece2
    
    invalid.rotation.drop.piece:
    li $v0, -2
    j exit.drop.piece2
    
    invalid.col.drop.piece:
    li $v0, -2
    
    exit.drop.piece2:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $s6, 24($sp)
    lw $ra, 28($sp)
    addi $sp, $sp, 28
    jr $ra

	
check_row_clear:
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	move $s0, $a0 			# copy state into s0
	move $s1, $a1			# copy row # into s1
	li $s2, 'O'
	
	bltz $s1, invalid.row.clear
	lbu $t0, 0($s0)
	bge $s1, $t0, invalid.row.clear
	
	lbu $s7, 1($s0)			# get # of colms of state
	addi $s7, $s7, -1		# colms - 1
			
	li $t0, 0
	loop.to.check.all.Os:
	bge $t0, $s7, exit.loop.for.all.Os
	move $a0, $s0
	move $a1, $s1
	move $a2, $s7
	jal get_slot
	
	bne $v0, $s2, dont.clear.row
	
	j loop.to.check.all.Os
	
	
	exit.loop.for.all.Os:
	
	
	move $s6, $s1			# get # of rows of state			
	lbu $s7, 1($s0)			# get # of colms of state
	outer.loop.row.clear:
	li $t0, 1
	blt $s6, $t0, exit.outer.loop.row.clear
		li $s5, 0		
		inner.loop.row.clear:
		bgt $s5, $s7, exit.inner.loop.row.clear
		move $a0, $s0
		move $a1, $s6
		addi $a1, $a1, -1
		move $a2, $s5
		jal get_slot
		
		move $a0, $s0
		move $a1, $s6
		move $a2, $s5
		move $a3, $v0
		jal set_slot
		
		addi $s5, $s5, 1
		j inner.loop.row.clear
	exit.inner.loop.row.clear:
	addi $s6, $s6, -1
	j outer.loop.row.clear
	
	
	exit.outer.loop.row.clear:
	
	li $s5, 0			# colms
	lbu $s6, 1($s0)			# get # of colms of state
	loop.clear.first.row:
	bge $s5, $s6, exit.final.loop.row.clear
	move $a0, $s0
	li $a1, 0
	move $a2, $s5
	li $a3, '.'
	jal set_slot
	addi $s5, $s5, 1
	j loop.clear.first.row
	
	
	exit.final.loop.row.clear:
	li $v0, 1
	move $a0, $s0
	j exit.check.row.clear


	dont.clear.row:
	li $v0, 0
	j exit.check.row.clear
	
	invalid.row.clear:
	li $v0, -1
	j exit.check.row.clear
	
	
	exit.check.row.clear:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	jr $ra

simulate_game:
	jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
