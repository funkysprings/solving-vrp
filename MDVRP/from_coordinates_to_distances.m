% с координатами x(1) и y(1) находятся координаты стартового пункта
function [ distances ] = from_coordinates_to_distances( X, Y )
distances = zeros(length(X));
if length(X) == length(Y)
    for i = 1: length(distances)
        for j = 1: length(distances)
            if i ~= j
                d = sqrt((X(i) - X(j))^2 + (Y(i) - Y(j))^2);
                distances(i,j) = d;
                distances(j,i) = d;
            end
        end
    end
end
end

