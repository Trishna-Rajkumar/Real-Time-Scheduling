function y= decision_func();
global intermediate_dag;
global final_dag;
global reduc_stg2_flag;
global children_with_cycles;
global MS_pldag;
global print;
pl_dag = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {});
 
global m;

persistent prev
if isempty (prev)
    prev = 0;
end

current= intermediate_dag(1).paths_n;

if(children_with_cycles)
    children_with_cycles=0;
    final_dag= intermediate_dag(1);
    MS_pldag = max(final_dag.path_weight);
    if(print)
    printTask(intermediate_dag(1).v1);
    title('PL-DAG -Single path reduc')
    end



else

    if (m < intermediate_dag(1).paths_n) % the '1'st dag is the selected dag in each iteration

        if(intermediate_dag(1).paths_n==1)
            final_dag= intermediate_dag(1);
            MS_pldag = max(final_dag.path_weight)
            if(print)
            printTask(intermediate_dag(1).v1);
            title('Final PL-DAG-single path') ;
            end
        else
           prev=0;
           set_artificial_constraints(intermediate_dag(1).v1)
        end


    else 

        final_dag= intermediate_dag(1);
        MS_pldag = max(final_dag.path_weight)
        if(print)
        printTask(intermediate_dag(1).v1);
        title('Final PL-DAG')
        end
    end  
end
end
