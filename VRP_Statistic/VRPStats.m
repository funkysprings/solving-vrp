function VRPStats
clc;

number_of_tasks = 20;
stations = 30;

vehicles = [stations*4 stations*2 stations*3 stations*3];
parfor taskN = 1:number_of_tasks
fid = fopen(sprintf('results_st-%d-0.2_0.5_task-%d.txt',stations,taskN),'w');
    %% Initialization
    demands = randperm(stations - 1);

          x = randperm(stations * 10);
          y = randperm(stations * 10);
          x = x(1:stations);
          y = y(1:stations);
        distances = from_coordinates_to_distances(x,y);
    distances_stations = distances(2:end,2:end);
    distances_bases = distances(1,2:end);
    
    min_route_length = stations*999999;%
    
    %% Main
    e = 0;
    e_step = 0.1;
    for en = 1:11
        tau0 = 0.01;
        tau0_step = 0.2;
        for tn = 1:10
            beta = 0.01;
            beta_step = 0.2;
            for bn = 1:10
                alpha = 0.01;
                alpha_step = 0.2;
                for an = 1:10
                    %% Run
                    [~,RouteLength] = ANT_colony_algorithm_VRP( distances_stations, ...
                                        distances_bases, demands, [e alpha beta tau0], vehicles);
                    if RouteLength <= min_route_length
                        if RouteLength < min_route_length
                        min_route_length = RouteLength;
                        params = [e alpha beta tau0];
                            fclose(fid);
                            fid = fopen(sprintf('results_st-%d-0.2_0.5_task-%d.txt',stations,taskN),'w');
                            fprintf(fid,'_______________________________________________\r\n\t%g\r\n%s\r\n', ...
                                min_route_length, mat2str(params));
                        else
                            fprintf(fid,'%s\r\n', ...
                                 mat2str([e alpha beta tau0]));
                        end
                    end
                    
                    %fprintf('Task #%d params: %s len: %g\n', taskN, ...
                    %mat2str([e alpha beta tau0]), RouteLength);
                    if an > 5
                        alpha_step = 0.5;
                    end
                    alpha = alpha + alpha_step;
                end
                if bn > 5
                    beta_step = 0.5;
                end
                beta = beta + beta_step;
            end
            if tn > 5
                tau0_step = 0.5;
            end
            tau0 = tau0 + tau0_step;
            fprintf('Task #%d: e = %g | tau0 = %g\n', taskN, e, tau0);
        end
        e = e + e_step;
    end
    %fprintf(fid,'______________________(the minimum)_________________________\r\n\t%s\r\n\t%g\r\n', ...
    %    mat2str(params), min_route_length);
    
fclose(fid);                   
end

end