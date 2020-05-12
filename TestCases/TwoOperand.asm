# all numbers in hex format
# we always start by reset signal
#this is a commented line
.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
10
#you should ignore empty lines

.ORG 2  #this is the interrupt address
100

.ORG 10
in   R1       #add 5 in R1
in   R2       #add 19 in R2
in   R3       #FFFD
in   R4       #F320
IADD R5,R3,2  #R5 = FFFF , flags no change
ADD  R4,R1,R4    #R4= F325 , C-->0, N-->1, Z-->0   #3ndna 2l N mt3'er4
SUB  R6,R5,R4    #R4= 0CDA , C-->1, N-->0,Z-->0    #3ndna 2l C mt3'er4
AND  R6,R7,R6    #R6= 00000000 , C-->no change, N-->0, Z-->1   #Feh Stalls Kter 7slt ben 2l instruction dh w elly 2blo m4 3aref leh 
OR   R1,R2,R1    #R1=1D  , C--> no change, N-->0, Z--> 0
SHL  R2,2     #R2=64  , C--> 0, N -->0 , Z -->0
SHR  R2,3     #R2=0C  , C -->1, N-->0 , Z-->0
SWAP R2,R5    #R5=0C ,R2=FFFF  ,no change for flags
ADD  R2,R5,R2    #R2= 1000B (C,N,Z= 0)
