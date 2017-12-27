function y =selection_func(s_fctr)
global intermediate_dag;
n= length(intermediate_dag);

if(s_fctr<=1)
  switch s_fctr
      
      %%%%%%%prominence to path lenth%%%%%%%%%%%
    case 0
        for i=1:n 
            a(:,i)= intermediate_dag(i).paths_n ;
        end
        [~,dag_select]= min(a); %dag_select is the index of the dag
        intermediate_dag(1).v1= intermediate_dag(dag_select).v1;
        if (length (intermediate_dag)>1)
            i1=length (intermediate_dag)
            while(i1~=1)
                intermediate_dag(i1)=[]
                i1=i1-1;
            end
                
                
            
        end
        
        decision_func();
      %%%%%%%prominence to load-diff%%%%%%%%%%%%%
        
   case 1
        for i=1:n 
             a(:,i)= intermediate_dag(i).load_diff_inter ;
        end
        [~,dag_select]= min(a);
        intermediate_dag(1).v1= intermediate_dag(dag_select).v1;
        if (length (intermediate_dag)>1)
            i1=length (intermediate_dag)
            while(i1~=1)
                intermediate_dag(i1)=[]
                i1=i1-1;
            end
        end
        
        decision_func();
      %%%%%%%prominence to path and load-diff%%%%
        
   otherwise
         for i= 1:n
               a(:,i) = (intermediate_dag(i).paths_n )*(s_fctr) *(intermediate_dag(i).load_diff_inter )*(1-s_fctr);
         end 
         [~,dag_select]= min(a);
        intermediate_dag(1).v1= intermediate_dag(dag_select).v1;
        if (length (intermediate_dag)>1)
            i1=length (intermediate_dag)
            while(i1~=1)
                intermediate_dag(i1)=[]
                i1=i1-1;
            end
        end
        decision_func();
  end
else
    fprintf(2,'ERROR\n')
    fprintf(2,'Selection factor out of range, must be from 0 to 1\n')
end