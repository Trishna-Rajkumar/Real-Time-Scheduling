%check the arrangement of each pair of possible siblings for the creation of circles

function [y, temp_dag] = is_bondformed_func(temp,arti_constr_pair) 
global forbidden_pair;


       
        
        constr_par = arti_constr_pair(1,1);    %%parent and
        constr_child= arti_constr_pair(1,2);   %%child in the constraint pair
        temp_i= temp;
        original=temp;
        %%%%%%%%%%%%%% add path%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        temp_i(constr_par).succ(end+1) = constr_child;  
        temp_i(constr_child).pred(end+1)= constr_par;

        %%%%%%%%%%%%%%%%remove paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pred_temp = intersect(temp_i(constr_par).pred,temp_i(constr_child).pred);
        succ_temp = intersect(temp_i(constr_par).succ, temp_i(constr_child).succ);
        for p_rem = 1:length(pred_temp)
            parent_rem = pred_temp(p_rem);
            temp_i(parent_rem).succ( temp_i(parent_rem).succ == constr_child)= [];
            temp_i(constr_child).pred( temp_i(constr_child).pred== parent_rem)= [];
        end

        for s_rem = 1:length(succ_temp)
            succ_rem = succ_temp(s_rem);
            temp_i(constr_par).succ( temp_i(constr_par).succ == succ_rem)= [];
            temp_i(succ_rem).pred( temp_i(succ_rem).pred== constr_par)= [];

        end 
        
        %check for cycles
        isdag= isdag_test_substruct(temp_i);
        if(~isdag)
            forbidden_pair= [forbidden_pair;constr_par constr_child];
            y=false;
            temp_dag=original;
        else
            y=true;
            temp_dag=temp_i;            
                    
        end
            
            
        
        end
 