.ORG 0 
10

.ORG 2  
100

.ORG 10

########################## Original CODE (Case 3) + Case 2 #############################################
in   R1       #add 5 in R1
in   R2       #add 19 in R2#
in   R3       #FFFD
in   R4       #F320
IADD R5,R3,2  #R5 = FFFF , flags no change
ADD  R4,R1,R4    #R4 = F325 , C-->0, N-->1, Z-->0   
SUB  R6,R5,R4    #R6 = 0CDA , C-->1, N-->0,Z-->0    
AND  R6,R7,R6    #R6 = 00000000 , C-->no change, N-->0, Z-->1   
OR   R1,R2,R1    #R1 = 1D  , C--> no change, N-->0, Z--> 0
SHL  R2,2     #R2 = 64  , C--> 0, N -->0 , Z -->0
SHR  R2,3     #R2 = 0C  , C -->1, N-->0 , Z-->0
SWAP R2,R5    #R5 = 0C ,R2=0000FFFF  ,no change for flags
ADD  R2,R5,R2    #R2= 1000B (C,N,Z= 0)


########################## Case 1 #############################################
#in   R1       #add 5 in R1
#in   R2       #add 19 in R2
#in   R3       #FFFD
#in   R4       #F320
#IADD R5,R3,2  #R5 = FFFF , flags no change						#Hna m7sl4 Mo4kla 34an 2l IADD 2 Words
#ADD  R4,R1,R4    #R4 = F325 , C-->0, N-->1, Z-->0
#NOP
#NOP  
#SUB  R6,R5,R4    #R6 = 0CDA , C-->1, N-->0,Z-->0    			#Add two NOP before SUB
#NOP
#NOP 
#AND  R6,R7,R6    #R6 = 00000000 , C-->no change, N-->0, Z-->1   #Add two NOP before AND  => R7 = 0 SO any value for R6 will cause Output = 0
#OR   R1,R2,R1    #R1 = 1D  , C--> no change, N-->0, Z--> 0
#SHL  R2,2     #R2 = 64  , C--> 0, N -->0 , Z -->0
#NOP
#NOP
#SHR  R2,3     #R2 = 0C  , C -->1, N-->0 , Z-->0					#Add two NOP before SHR  
#NOP
#NOP 
#SWAP R2,R5    #R5 = 0C ,R2=0000FFFF  ,no change for flags		#Add two NOP before SWAP 
#NOP
#NOP 
#ADD  R2,R5,R2    #R2= 1000B (C,N,Z= 0)							#Add two NOP before ADD => mmkn mn3mlhom4 34an R2 + R5 = R5 + R2
