function create_plot_route(distances, route, demands)
    Radius = 1;
    
    X = zeros(1,length(route));
    Y = zeros(1,length(route));
    prev = 1;
    len = length(route);

    angle = (2*pi)/len;
    K = angle * len;

    for i = 1: len
        if route(i) == 1
            X(i) = 0;
            Y(i) = 0;
        else
           dist = distances(route(i),prev);
           X(i) = Radius * cos(K) * dist;
           Y(i) = Radius * sin(K) * dist;
        end
        K = K + angle;
        prev = route(i);
    end
    
    plot(X,Y,'-bo','MarkerFaceColor','b','MarkerSize',5);
    axis equal;
    base_p = strcat('\bf\leftarrow base','(',int2str(demands(1)),')');
    text(0,0,base_p);
    for j = 1: length(route)
        if route(j) ~= 1
            p = strcat('---',int2str(route(j)));
            d = int2str(demands(route(j)));
            str = [p ' (' d ')'];
            text(X(j),Y(j),str);
        end
    end
end
