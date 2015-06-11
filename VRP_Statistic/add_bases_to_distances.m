function [D] = add_bases_to_distances(distances, bases)
    D = zeros(length(bases) + 1);
    D(2:end,1) = bases;
    D(1,2:end) = bases;
    D(2:end,2:end) = distances;
end

