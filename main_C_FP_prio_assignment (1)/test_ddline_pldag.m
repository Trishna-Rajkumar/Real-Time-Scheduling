%function y = test_ddline_pldag()
clear all;
close all;
global MS_pldag;
global dag_ddline;
global no_reduction;
global final_dag;
global task;
global m;
global MS_other;
m = 8;

pass =1;
fail=0;
end_index= 1/m;
stepsize= 0.1/m;
F= [0:stepsize:end_index-stepsize];
%ddline_fctr_set= 0.65;
start_depth=4;
end_depth=8;
depth_arr= start_depth:1:end_depth;
test_results= struct('F_value', {},'test_dline_result',{},'margin_of_error', {}, 'test_MS_other',{}, 'dag_dl',{},'pldag_dl',{},'other_dl',{})
data_reqd= struct ('F_data', {},'succ_rate', {}, 'offshoot', {})
runs=15; 
% 
testrun=runs*length(F);
redux_runs=zeros(1,length(F));
tests=1;
%for tests= 1:testrun
 while(tests<=testrun)   
    ddline_fctr_set= F(ceil(tests/runs))
    index = runs;
    depth_set= 4; %depth_arr(index);
    main_func(ddline_fctr_set,depth_set)
    
   
                    if (~no_reduction) %no path reduction done when the generated DAG paths<=m;
                    test_results(tests).F_value=  ddline_fctr_set; 
                    test_results(tests).dag_dl=dag_ddline;
                    test_results(tests).pldag_dl= MS_pldag;
                    test_results(tests).other_dl= MS_other;
                    
                        if(MS_other<=dag_ddline)
                        test_results(tests).test_MS_other=1;

                        else
                        test_results(tests).test_MS_other=0;
                        end

                    
                          %generated dag has m or less paths
                        if (m< length(final_dag(1).path_num))  %path reduction terminated to prevent cycles  %unlikely case- to be removed later
                                  test_results(tests).test_dline_result= -2;


                        else

                                    if(MS_pldag<=dag_ddline)
                                        test_results(tests).test_dline_result= pass;
                                    else
                                        test_results(tests).margin_of_error= (MS_pldag-dag_ddline)/dag_ddline ;
                                        test_results(tests).test_dline_result=fail;
                                    end

                        end
                        tests=tests+1;
                    else
                        redux_runs(ceil(tests/runs))=redux_runs(ceil(tests/runs))+1 ;
                        if(tests>1)
                        tests=tests-1;
                        end
                    end
                        

                   

                        
end
  
for cnt = 1:length(F)
    
    
data_reqd(cnt).F_data = F(cnt);
data_reqd(cnt).offshoot= 100*(sum([test_results((runs*(cnt-1)+1):runs*cnt).margin_of_error]))/(runs-redux_runs(cnt)) %remove the runs when there was no reduction
data_reqd(cnt).succ_rate=100*(sum( [test_results((runs*(cnt-1)+1):runs*cnt).test_dline_result]))  /(runs-redux_runs(cnt))


end


save('results','test_results')
save('workspace_065')