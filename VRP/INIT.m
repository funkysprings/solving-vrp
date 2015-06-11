function [vehicles,demands,distances_stations,distances_bases] = INIT()
    vehicles = create_vehicles;
    demands = create_demands;
    [distances_stations,distances_bases] = create_distances;
end