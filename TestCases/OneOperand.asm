.ORG 0  
10

.ORG 2  
100

.ORG 10


########################## Original CODE (Case 3) + Case 2 #############################################
#NOT R1         #R1 =FFFFFFFF , C--> no change, N --> 1, Z --> 0
#NOP            #No change
#inc R1	       #R1 =00000000 , C --> 1 , N --> 0 , Z --> 1
#in R1	       #R1= 5,add 5 on the in port,flags no change	
#in R2          #R2= 10,add 10 on the in port, flags no change
#NOT R2	       #R2= FFFFFFEF, C--> no change, N -->1, Z-->0     
#inc R1         #R1= 6, C --> 0, N -->0, Z-->0
#Dec R2         #R2= FFFFFFEE,C-->1 , N-->1, Z-->0     #==> 3ndna 2l carry mt3'er4
#out R1
#out R2

########################## CASE 1 CODE #############################################

#NOT R1         #R1 =FFFFFFFF , C--> no change, N --> 1, Z --> 0
#NOP            #No change
#NOP
#inc R1	       #R1 =00000000 , C --> 1 , N --> 0 , Z --> 1                   #Add one NOP before inc
#in R1	       #R1= 5,add 5 on the in port,flags no change	
#in R2          #R2= 10,add 10 on the in port, flags no change
#NOP	
#NOP
#NOT R2	       #R2= FFFFFFEF, C--> no change, N -->1, Z-->0   				 #Add two NOP before NOT 
#inc R1         #R1= 6, C --> 0, N -->0, Z-->0
#NOP
#Dec R2         #R2= FFFFFFEE,C-->1 , N-->1, Z-->0     						 #Add one NOP before DEC
#out R1
#NOP
#out R2																		 #Add one NOP before OUT

#Case 4 ==> No JZ 