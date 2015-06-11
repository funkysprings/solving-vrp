function [cells] = vehicles_capacities_to_cellarray(vehicles_capacity)
    cells = cell(1,length(vehicles_capacity));
    for i = 1:length(vehicles_capacity)
       cells{1,i} = vehicles_capacity(i); 
    end
end

