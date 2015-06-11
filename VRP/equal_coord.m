function b = equal_coord(X,Y)
b = false;
for i = 1: length(X)
    for j = 1: length(X)
        if X(i) == Y(j)
            if Y(i) == X(j)
               b = true;
            end
        end
    end
end
end

