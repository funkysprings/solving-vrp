function [route] = delete_duplicates_stations(route)
    %find first duplications and delete them
    indcount = [];
    for i = 1:length(route) - 1
        if route(i) == route(i + 1)
            indcount(end + 1) = i;
        else
            break; 
        end
    end
    if ~isempty(indcount)
        route(indcount(1:end)) = [];
    end
end

