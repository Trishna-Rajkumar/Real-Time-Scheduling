function [y,temp_sibdag] = is_siblingbondformed_func(temp_sib_rcv,sibling_tocheck,sib_par) 

a0=sibling_tocheck(1);
a1=sibling_tocheck(2);
temp_sib= temp_sib_rcv;
orig_sibdag= temp_sib_rcv;
 if( ismember(a1,temp_sib(a0).succ)||...
    ismember(a0,temp_sib(a1).succ) ==false)%create the const btw siblings only when they dont have a parent-child relation among them
    
    temp_sib(a1).pred(end+1) = a0;
    temp_sib(a0).succ(end+1) = a1; 
 end
                
                
if (ismember(a0,temp_sib(a1).succ))
     temp_sib(a0).pred(temp_sib(a0).pred==(sib_par))= []; %a0 is the child that the parent cuts off its ties with
     temp_sib(sib_par).succ(temp_sib(sib_par).succ==a0)=[];
else

     temp_sib(a1).pred(temp_sib(a1).pred==(sib_par))= []; %a1 is the child that the parent cuts off its ties with
     temp_sib(sib_par).succ(temp_sib(sib_par).succ==a1)=[];
end
                
            
            
          %%%%%%%%%%%%%% CHECK FOR CYCLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
isdag=isdag_test_substruct(temp_sib);   %to be updated to check for reverse condition 
if(~isdag)
    y=false;
    temp_sibdag=orig_sibdag
else
    y=true;
    temp_sibdag= temp_sib;
end
    