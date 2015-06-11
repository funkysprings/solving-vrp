function [vehicles,demands,distances_stations,distances_bases] = INIT_VRP
    %%
    vehicles = [70 60 50 80];
    %%
    demands = [8 21 22 13 14 4 10 7 16 15 6 11 25 5 2 1 19 12 9 3 23 18 17 24];
    %%
    x = [23,16,2,6,15,13,19,18,20,14,21,12,25,1,22,4,5,11,24,10,7,3,8,17,9];
    y = [21,7,22,5,12,11,1,16,19,4,6,3,18,8,25,15,24,10,23,20,9,13,17,14,2];
    distances = from_coordinates_to_distances(x,y);
    distances_stations = distances(2:end,2:end);
    distances_bases = distances(1,2:end);
end

