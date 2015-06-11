function create_plot_route_with_vehicles(distances,vehicles,demands)
    Radius = 1;
    
    dim = 0;
    legend('off');
    capacities = cell(1,length(vehicles));
    for i = 1:length(vehicles)
        len = length(vehicles(i).route);
        dim = dim + len;
        if len > 1
            capacities{1,i} = sprintf('Vehicle#%d: %s',i,num2str(vehicles(i).capacity));
        else
            capacities{1,i} = sprintf('Vehicle#%d: %s',i,'N/A');
        end
    end
    
    prev_station = 1;
    
    angle = (2 * pi) / dim;
    K = angle * dim;

    colors = hsv(length(vehicles));
    for k = 1:length(vehicles)
        route = vehicles(k).route;
        if length(route) > 1 %если есть пустые маршруты
            len = length(route);
            X = zeros(1,len);
            Y = zeros(1,len);
            for i = 1: len
                if route(i) ~= 1 % если не база
                   dist = distances(route(i),prev_station);
                   X(i) = Radius * cos(K) * dist;
                   Y(i) = Radius * sin(K) * dist;
                   %добавим информацию о пунктах на график
                   station = strcat('---',int2str(route(i) - 1));
                   demand = int2str(demands(route(i)));
                   str = [station ' (' demand ')'];
                   text(X(i),Y(i),str);
                end
                K = K + angle;
                prev_station = route(i);
            end
            hold on;
            plot(X,Y,'-o','color',colors(k,:),'MarkerFaceColor',colors(k,:),'MarkerSize',7);
        else %если маршрут пуст
            X = 0;
            Y = 0;
            plot(X,Y);
        end
    end
    
    %выводим надписи
    legend(capacities);
    
    %нормируем оси графика
    axis auto;
    lim = axis;
    lim(2) = lim(2) + 2;
    axis(lim);
    
    base_p = '\bf\leftarrow base';
    text(0,0,base_p,'FontSize',12);
    
end

