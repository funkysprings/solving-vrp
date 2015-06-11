function create_init_plot_MDVRP(coordinates, clusters)
    
    legend('off');

    indc = 1;
    coordlen = length(coordinates.x);
    X = zeros(1,coordlen);
    Y = zeros(1,coordlen);
    for c = 1:length(clusters)
        demands = clusters(c).demands;
        stations = clusters(c).stations;
        stationslen = length(stations);
        for st = 1: stationslen
           X(indc) = coordinates.x(stations(st));
           Y(indc) = coordinates.y(stations(st));
           %добавим информацию о пунктах на график
           station = strcat('---',int2str(stations(st)));
           demand = int2str(demands(st));
           str = [station ' (' demand ')'];
           text(X(indc),Y(indc),str);
           indc = indc + 1; %индекс станции для координат
        end
        hold on;
        plot(nonzeros(X),nonzeros(Y),'o','color','b','MarkerFaceColor','b','MarkerSize',7);
        
        plot(coordinates.base(c,1),coordinates.base(c,2),'-o','color','k','MarkerFaceColor','k','MarkerSize',7)
        base_p = sprintf('   base #%d',c);
        text(coordinates.base(c,1),coordinates.base(c,2),base_p,'FontSize',12,'FontWeight','bold');
     end
    
    %нормируем оси графика
    axis auto;
    lim = axis;
    lim(2) = lim(2) + 2;
    axis(lim);
end

