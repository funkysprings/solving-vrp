function create_plot_of_base_MDVRP(coordinates, clusters, baseNo)

    legend('off');
    
    vehicles = clusters(baseNo).mdvrp.simpleVehicles;
    demands = [0 clusters(baseNo).demands];
    vehicles_in_cluster = clusters(baseNo).mdvrp.vehicles;
    
    %грузоподъеммность ТС (для описания для графика)
    capacities = cell(1,length(vehicles));
    for i = 1:length(vehicles)
        len = length(vehicles(i).route);
        if len > 1
            capacities{1,i} = sprintf('Vehicle#%d: %s',i,num2str(vehicles(i).capacity));
        else
            capacities{1,i} = sprintf('Vehicle#%d: %s',i,num2str(vehicles(i).capacity));
        end
    end
    
    %считаем кол-во ТС на всех базах (для цвета)
    num_of_vehicles = 0;
    for c = 1:length(clusters)
        if c == baseNo
            ncolor = num_of_vehicles + 1; %фиксируем цвет
        end
        num_of_vehicles = num_of_vehicles + length(clusters(c).mdvrp.simpleVehicles);
    end
    colors = hsv(num_of_vehicles);
    
    for v = 1:length(vehicles)
        route = vehicles(v).route;
        if length(route) > 1 %если есть пустые маршруты
            len = length(route);
            X = zeros(1,len);
            Y = zeros(1,len);
            for i = 1: len
                if route(i) ~= 1 % если не база
                   no_vehicle = vehicles_in_cluster(v).route(i);% # of vehicle 
                   X(i) = coordinates.x(no_vehicle);
                   Y(i) = coordinates.y(no_vehicle);
                   %добавим информацию о пунктах на график
                   station = strcat('---',int2str(no_vehicle));%route(i) - 1));
                   demand = int2str(demands(route(i)));
                   str = [station ' (' demand ')'];
                   text(X(i),Y(i),str);
                else %если база
                   X(i) = coordinates.base(baseNo,1);
                   Y(i) = coordinates.base(baseNo,2);
                end
            end
            hold on;
            plot(X,Y,'-o','color',colors(ncolor,:),'MarkerFaceColor',colors(ncolor,:),'MarkerSize',7);
        else %если маршрут пуст
            X = coordinates.base(baseNo,1);
            Y = coordinates.base(baseNo,2);
            plot(X,Y);
        end
        ncolor = ncolor + 1;
    end
    plot(coordinates.base(baseNo,1),coordinates.base(baseNo,2),'-o','color','k','MarkerFaceColor','k','MarkerSize',7)
    base_p = sprintf('   base #%d',baseNo);
    text(coordinates.base(baseNo,1),coordinates.base(baseNo,2),base_p,'FontSize',12,'FontWeight','bold');
    
    %выводим надписи
    legend(capacities);
        
    %нормируем оси графика
    axis auto;
    lim = axis;
    lim(2) = lim(2) + 2;
    axis(lim);
    
end

