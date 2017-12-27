%AUTHOR: TRISHNA RAJKUMAR

function [sp,adj_m] = sparse_adj_WeightedEdges(v)
    global task_num;
    global task;
    sp = zeros(length(v));
    
    for i = 1 : length(v)
        for j = 1 : length(v(i).succ)
%             sp(i, v(i).succ(j)) = task(task_num).v(i).C;
              sp(i, v(i).succ(j)) = v(i).C;
        end
    end
      
    sp = sparse(sp);
    adj_m= full(sp);   %create adjacency matrix with weight of edges= execution time of parent
    
   

end

