.ORG 0  
10

.ORG 2 
100

.ORG 10

########################## Original CODE (Case 3) + Case 2 #############################################
LDM R2,0A #R2=0A
LDM R0,0  #R0=0
LDM R1,50 #R1=50
LDM R3,20 #R3=20
LDM R4,2  #R4=2
NOP
JMP R3    #Jump to 20						#27tgt NOP wa7da 34an LDM 2 Words f lma 2l JMP kant fl fetch => LDM R3 kant fl memory f 2stnet cycle l7d ma wslt 2l write back
.ORG 20
SUB R5,R0,R2 #check if R0 = R2
JZ R1 #jump if R0=R2 to 50
ADD R4,R4,R4 #R4 = R4*2
NOP
NOP
OUT R4										#M7tag 2 NOP 34an 2l ADD tkon l72t ktbt 2l R4 f 2l Register
INC R0										#27tgt NOP hna 34an lma 2l INC deh tb2a fl Write back 2l SUB tb2a fl execute, 2na 3aezha tb2a fl decode 34an tl72 t2ra R0
NOP
JMP R3 #jump to 20
.ORG 50
LDM R0,0 #R0=0
LDM R2,8 #R2=8
LDM R3,60 #R3=60
LDM R4,3  #R4=3
NOP
JMP R3 #jump to 60						#27tgt NOP wa7da 34an LDM 2 Words f lma 2l JMP kant fl fetch => LDM R3 kant fl memory f 2stnet cycle l7d ma wslt 2l write back
.ORG 60
ADD R4,R4,R4 #R4 = R4*2
NOP
NOP
OUT R4									#M7tag 2 NOP 34an 2l ADD tkon l72t ktbt 2l R4 f 2l Register
INC R0
NOP
NOP									
AND R5,R0,R2 #when R0 < R2(8) answer will be zero			#M7tag 2 NOP 34an 2l INC tkon l72t ktbt 2l R4 f 2l Register
JZ R3 #jump if R0 < R2 to 60
INC R4
NOP
NOP	
OUT R4			#M7tag 2 NOP 34an 2l INC tkon l72t ktbt 2l R4 f 2l Register



########################## Original CODE (Case 3) + Case 2 #############################################
#LDM R2,0A #R2=0A
#LDM R0,0  #R0=0
#LDM R1,50 #R1=50
#LDM R3,20 #R3=20
#LDM R4,2  #R4=2
#JMP R3    #Jump to 20
#.ORG 20
#SUB R5,R0,R2 #check if R0 = R2
#JZ R1 #jump if R0=R2 to 50
#ADD R4,R4,R4 #R4 = R4*2
#OUT R4
#INC R0
#JMP R3 #jump to 20
#.ORG 50
#LDM R0,0 #R0=0
#LDM R2,8 #R2=8
#LDM R3,60 #R3=60
#LDM R4,3  #R4=3
#JMP R3 #jump to 60
#.ORG 60
#ADD R4,R4,R4 #R4 = R4*2
#OUT R4
#INC R0
#AND R5,R0,R2 #when R0 < R2(8) answer will be zero
#JZ R3 #jump if R0 < R2 to 60
#INC R4
#OUT R4