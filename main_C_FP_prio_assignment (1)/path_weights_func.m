%AUTHOR: TRISHNA RAJKUMAR
function path_weights= path_weights_func(v,paths)

global task;
global task_num;
mysum=0;

for i=1:length(paths)
    for j=1:cellfun('length',paths(i))
%         mysum = mysum + task(task_num).v(j).C;
          mysum = mysum + v(j).C;

    end
weight_temp(i)= mysum;

mysum=0;
end
path_weights= weight_temp;


%diff= max(weight)- min(weight);

% each_path_weight= cellfun(@sum, paths);
% diff= max(each_path_weight)- min(each_path_weight);