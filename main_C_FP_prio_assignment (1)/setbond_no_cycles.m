function [y,dag_to_send]= setbond_no_cycles(temp,arti_constr_pair)

[first_choice,test_dag1] = is_bondformed_func(temp,arti_constr_pair(x1,:))

if(first_choice==true)
y=true
dag_to_send=test_dag1;
else
    [second_choice,test_dag2]= is_bondformed_func(temp,arti_constr_pair(x1,:))
    if(second_choice==true)
        y=true
        dag_to_send=test_dag2;
    else
        y=false
    end
end