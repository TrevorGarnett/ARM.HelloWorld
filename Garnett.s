@ Filename: Quiz1.s
@ Author:   Trevor Garnett
@ Email: tjg0020@uah.edu
@ CS413-<<Section 1>><<Spring 2021>>
@ History:
@	Created 01/26/2021, adding comments when necessary
@
@ Use these commands to assemble, link, run and debug this program:
@    as -o Quiz1.o Quiz1.s
@    gcc -o Quiz1 Quiz1.o
@    ./Quiz1 ;echo $?
@    gdb --args ./Quiz1 

@ ****************************************************
@ The = (equal sign) is used in the ARM Assembler to get the address of a
@ label declared in the .data section. This takes the place of the ADR
@ instruction used in the textbook. 
@ ****************************************************

.equ READERROR, 0 @Used to check for scanf read error. 

.global main @ Have to use main because of C library uses. 

main:

@*******************
prompt:
@*******************

@ Ask the user to enter a number.

   ldr r0, =welcomeMessage @ Put the address of my string into the first parameter
   bl  printf              @ Call the C printf to display input prompt.

@*******************
get_input:
@*******************

@ Set up r0 with the address of input pattern
@ scanf puts the input value at the address stored in r1. We are going
@ to use the address for our declared variable in the data section - intInput. 
@ After the call to scanf the input is at the address pointed to by r1 which in this
@ case will be intInput. 

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored.
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r4, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r4, [r4]             @ Read the contents of intInput so we can use it

   cmp r4, #0		    @ Compare to 0
   blt NotInRange	    @ If less than 0, let NotInRange handle

   cmp r4, #10              @ Updating flags wrt 10. If the number entered is
   bgt NotInRange           @ greater than 10, let NotInRange handle

   b sayHi		    @ If it is within [0,10], then go to sayHi


@ This section is a loop that prints "Hello World" the required amount of times
sayHi:
   cmp r4, #0		    @ Compare r4, the number entered to 0
   beq myexit		    @ If equal, exit program
   ldr r0, =message	    @ If not equal, load in "Hello World" to r0
   bl printf		    @ Print the contents of r0
   sub r4, r4, #1	    @ Subtract 1 from the inputed number and save it
			    @ to represent "Hello World" was printed once
   b sayHi		    @ Go back in case "Hello World" needs to be printed again


@ This section is responsible for printing a message when an input is out of range
NotInRange:
   ldr r0, =badNumb	    @ Load in message
   bl printf		    @ Print message
   b prompt		    @ Go to prompt, so user can input number within the given range.


@***********
readerror:
@***********
@ Got a read error from the scanf routine. Clear out the input buffer then
@ branch back for the user to enter a value. 
@ Since an invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 

   ldr r0, =strInputPattern
   ldr r1, =strInputError   @ Put address into r1 for read.
   bl scanf                 @ scan the keyboard.
@  Not going to do anything with the input. This just cleans up the input buffer.  
@  The input buffer should now be clear so get another input.

   b prompt


@*******************
myexit:
@*******************
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @SVC call to exit
   svc 0         @Make the system call. 

.data

@ Declare the strings and data needed

.balign 4
welcomeMessage: .asciz "Welcome. Please enter an integer between 0 and 10, inclusive.\nThis program will print 'Hello World' that many times. \n"

.balign 4
message: .asciz "Hello World \n"

.balign 4
badNumb: .asciz "The number entered is not within the range of [0,10]. \n"

@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

.balign 4
intInput: .word 0   @ Location used to store the user input.



@ Let the assembler know these are the C library functions. 

.global printf
@  To use printf:
@     r0 - Contains the starting address of the string to be printed. The string
@          must conform to the C coding standards.
@     r1 - If the string contains an output parameter i.e., %d, %c, etc. register
@          r1 must contain the value to be printed. 
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed. 

.global scanf
@  To use scanf:
@      r0 - Contains the address of the input format string used to read the user
@           input value. In this example it is numInputPattern.  
@      r1 - Must contain the address where the input value is going to be stored.
@           In this example memory location intInput declared in the .data section
@           is being used.  
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed.
@ Important Notes about scanf:
@   If the user entered an input that does NOT conform to the input pattern, 
@   then register r0 will contain a 0. If it is a valid format
@   then r0 will contain a 1. The input buffer will NOT be cleared of the invalid
@   input so that needs to be cleared out before attempting anything else. 
@

@end of code and end of file. Leave a blank line after this.
