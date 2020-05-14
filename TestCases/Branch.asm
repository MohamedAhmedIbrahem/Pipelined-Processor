.ORG 0  
10

.ORG 2 
100

########################## Original CODE (Case 3)  #############################################

.ORG 10
IN R1    
IN R2    
IN R3     
IN R4     
IN R6    
IN R7    
Push R4   
JMP R1 
INC R7	 
.ORG 30
AND R5,R1,R5  
JZ  R2       							
INC R7  
.ORG 500
NOP
NOP
.ORG 50
JZ R3      									
NOT R5 
NOP #Stall
NOP #Stall   
INC R5   
in  R6
NOP #Stall
NOP #Stall
NOP #Stall      
JZ  R6    					   
INC R1   
.ORG 200
POP R6
NOP #Stall
NOP #Stall
NOP #Stall   
Call R6   			
INC R6	  
NOP
NOP
.ORG 300
Add R6,R3,R6 
Add R1,R1,R2 
ret
INC R7  

########################## Case 2  #############################################
#in R1     #R1=30
#in R2     #R2=50
#in R3     #R3=100
#in R4     #R4=300
#in R6     #R6=FFFFFFFF 
#in R7     #R7=FFFFFFFF   
#Push R4   #sp=7FD, M[7FE, 7FF]=300
#JMP R1 
#INC R7	  # this statement shouldn't be executed,
#check flag forwarding  
#.ORG 30
#AND R5,R1,R5  #R5 = 0 , Z = 1
#JZ  R2        #Jump taken, Z = 0						##Hna 2l Prediction mfdne4 b 7aga 34an 2na 3aml initial_state = Weakly Not Taken						
#INC R7     	  #this statement shouldn't be executed
#check on flag updated on jump
#.ORG 50
#JZ R3      #Jump Not taken								##Hna 2l Prediction fadny one clock cycle 34an 2na 3aml initial_state = Weakly Not Taken	
#check destination forwarding
#NOT R5     #R5=FFFFFFFF, C--> not change, N=1, Z= 0
#INC R5     #R5=0,  C=1, N=0, Z=1,
#in  R6     #R6=200, flag no change
#NOP
#NOP
#JZ  R6     #jump taken, Z = 0							##Hna be jump 3la R6 f hn7tag 2 NOP bs l7d ma in R6 e3dy 2l ALU w 22dr 23ml forwarding				   
#INC R1   #this statement shouldn't be executed
#.ORG 100
#ADD R0,R0,R0    #C=1,N=0,Z=1
#out R6
#rti
#check on load use
#.ORG 200
#POP R6    #R6 = 300, SP=7FF
#NOP
#NOP
#NOP
#Call R6   #SP = 7FD, M[7FF]=half next PC,M[7FE]=other half next PC			##Hna Hb2 M7tag 3 NOP brdo  34an 2l POP memory instruction f kda kda lazm 2stnah l7d ma ewsl ll write back w 2l forwarding m4 hefdny			
#INC R6	  #R6 = 401, this statement shouldn't be executed till call returns, C--> 0, N-->0,Z-->0
#NOP
#NOP
#.ORG 300
#Add R6,R3,R6 #R6=400
#Add R1,R1,R2 #R1=80, C->0,N=0, Z=0
#ret
#INC R7           #this should not be executed
#.ORG 500
#NOP
#NOP


########################## Case 1  #############################################
#in R1     #R1=30
#in R2     #R2=50
#in R3     #R3=100
#in R4     #R4=300
#in R6     #R6=FFFFFFFF 
#in R7     #R7=FFFFFFFF   
#Push R4   #sp=7FD, M[7FE, 7FF]=300
#JMP R1 
#INC R7	  # this statement shouldn't be executed,
#check flag forwarding  
#.ORG 30
#AND R5,R1,R5  #R5 = 0 , Z = 1
#JZ  R2        #Jump taken, Z = 0							##Hna 2l Prediction mfdne4 b 7aga 34an 2na 3aml initial_state = Weakly Not Taken
#INC R7     	  #this statement shouldn't be executed
#check on flag updated on jump
#.ORG 50
#JZ R3      #Jump Not taken									##Hna 2l Prediction fadny one clock cycle 34an 2na 3aml initial_state = Weakly Not Taken
#check destination forwarding
#NOT R5     #R5=FFFFFFFF, C--> not change, N=1, Z= 0		
#NOP
#NOP	
#INC R5     #R5=0,  C=1, N=0, Z=1,							##Hna M7tag Two NOP
#in  R6     #R6=200, flag no change
#NOP
#NOP
#NOP
#JZ  R6     #jump taken, Z = 0							    ##Hna be jump 3la R6 f hn7tag 3 NOP l7d ma in R6 ewsl ll write back , 7ta lma gab R6 34an hwa initially Not Taken w2f wa7da fl JZ mfdne4
#INC R1   #this statement shouldn't be executed
#.ORG 100
#ADD R0,R0,R0    #C=1,N=0,Z=1
#out R6
#rti
#check on load use
#.ORG 200
#POP R6    #R6 = 300, SP=7FF
#NOP
#NOP
#NOP
#Call R6   #SP = 7FD, M[7FF]=half next PC,M[7FE]=other half next PC				##Hna Hb2 M7tag 3 NOP brdo  Call fl fetch w POP fl Write back
#INC R6	  #R6 = 401, this statement shouldn't be executed till call returns, C--> 0, N-->0,Z-->0
#NOP
#NOP
#.ORG 300
#Add R6,R3,R6 #R6=400
#Add R1,R1,R2 #R1=80, C->0,N=0, Z=0
#ret
#INC R7           #this should not be executed
#.ORG 500
#NOP
#NOP




         

