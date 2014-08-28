#picaxe 14m2						       
symbol delay = w1			
symbol feed  = w2 		
delay = 50
feed = 1000							
dirsb=%00011111	 			
main:
	
	readadc C.0, delay
	
	if pinC.1 = 1 then
		goto drop 
	end if
	
	if pinC.2 = 1 then
		goto revers 
	end if
	
	pinsb=%00000000
	goto main 
	
	
drop:
	do
		for b1=0 to 3
			lookup b1,(%00110,%01100,%11000,%10010),pinsb		 'step outputs
			if pinC.2 = 0 then
				pauseus feed
			end if
			pauseus delay
		next b1
	loop while pinC.1 = 1
		
	goto main
	
revers:

	do
		for b1=0 to 3
			lookup b1,(%00110,%10010,%11000,%01100),pinsb		 'reverser
			if pinC.1 = 0 then
				pauseus feed
			end if
			pauseus delay
		next b1
  loop while pinC.2 = 1
		
	goto main