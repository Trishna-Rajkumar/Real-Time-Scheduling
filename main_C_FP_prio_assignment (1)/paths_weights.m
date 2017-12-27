function [paths_dag,weight_eachpath]= paths_weights(v)
global task;
global task_num;
global intermediate_dag;
global root;
global leaf;
% for x = 1:length(v)
%     if (isempty(v(x).pred))
%         root= x;
%     else
%     if (isempty(v(x).succ))
%         leaf= x;
%     end
%     end
% end


[~,adj_m] = sparse_adj_WeightedEdges(v);
paths_dag= pathbetweennodes(adj_m,root,leaf,false);
weight_eachpath = path_weights_func(v,paths_dag);