function [clusters, coordinates] = INIT
    vehicles = create_vehicles;
    demands = create_demands;
    [distances_stations,distances_bases] = create_distances;
    
    base1 = [23 21];
    base2 = [17 4];
    base3 = [10 15];
    x = [16,2,6,15,13,19,18,20,14,21,12,25,1,22,4,5,11,24,10,7,3,8,17,9];
    y = [7,22,5,12,11,1,16,19,4,6,3,18,8,25,15,24,10,23,20,9,13,17,14,2];
    
    bases = [base1;base2;base3];
    X = [x;y]';
    
    [idx,centroids] = kmeans(X,[],'start',bases,'display','final');
    
    %figure
    %plot(X(idx==1,1),X(idx==1,2),'r.')
    %hold on
    %plot(X(idx==2,1),X(idx==2,2),'b.')
    %plot(X(idx==3,1),X(idx==3,2),'g.')
    %plot(centroids(:,1),centroids(:,2),'kx')
    
    stations = struct('val',{find(idx == 1);find(idx == 2);find(idx == 3)});
    mdvrp = struct('length_route', [], ...
                   'vehicles', [], ...      %saved vehicles from real input data
                   'simpleVehicles', [], ...   %saved vehicles after running algorithms
                   'num_of_subroutes', []);
    coordinates = struct('x',x,'y',y,'base',bases);
    
    clusters = struct('vehicles_capacity',{vehicles(1).capacity;vehicles(2).capacity;vehicles(3).capacity}, ...
        'demands',{demands(stations(1).val);demands(stations(2).val);demands(stations(3).val)}, ...
        'diststations',{distances_stations(stations(1).val,stations(1).val);distances_stations(stations(2).val,stations(2).val);distances_stations(stations(3).val,stations(3).val)},...
        'distbases',{distances_bases(1,stations(1).val);distances_bases(2,stations(2).val);distances_bases(3,stations(3).val)},...
        'stations',{stations(1).val;stations(2).val;stations(3).val}, ...
        'mdvrp',mdvrp);
    
    %for c = 1:length(clusters)
        %[ R, LR, vehicles ] = Clark_Wright_VRP( clusters(c).demands,clusters(c).diststations, clusters(c).distbases, clusters(c).vehicles_capacity );
    %    [ R, LR, vehicles ] = ANT_colony_algorithm_VRP_minpath( clusters(c).diststations, clusters(c).distbases, clusters(c).demands, [0.1 0.2 0.4 0.2], clusters(c).vehicles_capacity );
        %[ R, LR, vehicles ] = ANT_colony_algorithm_VRP( clusters(c).diststations, clusters(c).distbases, clusters(c).demands, [0.1 0.2 0.4 0.2], clusters(c).vehicles_capacity );
        %[ R, LR, vehicles ] = ANT_colony_algorithm_VRP_with_elite_ants(clusters(c).diststations, clusters(c).distbases, clusters(c).demands, [0.1 0.2 0.4 0.2 5], clusters(c).vehicles_capacity );

        %меняем номера станций из алгоритма на номера станций по кластеру 
    %    vehicles_data = vehicles;
    %    len = length(vehicles);
    %    for v = 1:len
    %        vehicles(v).route(vehicles(v).route == 1) = 0;
    %        len_route = length(vehicles(v).route);
    %        for vr = 1:len_route
    %            if vehicles(v).route(vr) ~= 0 %если не база
    %                vehicles(v).route(vr) = clusters(c).stations(vehicles(v).route(vr)-1);
    %            end
    %        end
    %    end
    %    clusters(c).mdvrp.length_route = LR;
    %    clusters(c).mdvrp.vehicles = vehicles;
        
    %    create_plot_route_with_vehicles_MDVRP(add_bases_to_distances(clusters(c).diststations,clusters(c).distbases),vehicles_data,[0 clusters(c).demands],clusters(c).mdvrp.vehicles,c);
    %end
    
end
