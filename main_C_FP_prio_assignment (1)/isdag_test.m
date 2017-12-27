function y= isdag_test(intermediate_dag(1).v1)
[sp_m,~]= sparse_adj_WeightedEdges(intermediate_dag(1).v1);
y= graphisdag(sp_m);
end