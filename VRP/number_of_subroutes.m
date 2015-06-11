% !!! первый пункт - это и есть наша база
function [N] = number_of_subroutes(route)
base = route(1);
duplicates = 0;
%count first duplicate numbers in route if have
for i = 1:length(route) - 1
    if route(i) == route(i + 1)
        duplicates = duplicates + 1;
    else
        break; 
    end
end
N = length(find(route == base)) - 1 - duplicates;
end

