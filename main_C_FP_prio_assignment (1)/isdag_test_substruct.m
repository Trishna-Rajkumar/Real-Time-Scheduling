function y= isdag_test_substruct(dag_struct)
[sp_m,~]= sparse_adj_WeightedEdges(dag_struct);
y= graphisdag(sp_m);
end