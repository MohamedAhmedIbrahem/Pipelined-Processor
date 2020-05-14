.ORG 0  
10

.ORG 2 
100

.ORG 10

########################## Original CODE (Case 3) + Case 2 #############################################


IN R2       
IN R3        
IN R4       
LDM R1,F5
NOP #Stall
NOP #Stall 
PUSH R1      			
PUSH R2      
POP R1       
POP R2
NOP #Stall   
STD R2,200   					
STD R1,202   
LDD R3,202   
LDD R4,200   

########################## CASE 1 CODE #############################################
#in R2        #R2=0CDAFE19 add 0CDAFE19 in R2
#in R3        #R3=FFFF
#in R4        #R4=F320
#LDM R1,F5    #R1=F5
#NOP
#NOP
#PUSH R1      #SP = 7FD, M[7FE, 7FF] = F5			#Add two NOP before PUSH R1
#PUSH R2      #SP = 7FB, M[7FC, 7FD] = 0CDAFE19
#POP R1       #SP=7FD,R1=0CDAFE19
#POP R2       #SP=7FF,R2=F5
#NOP
#STD R2,200   #M[200, 201] = F5						#Add one NOP before STD R2,200  
#STD R1,202   #M[202, 203] = 0CDAFE19
#LDD R3,202   #R3=0CDAFE19
#LDD R4,200   #R4=F5
