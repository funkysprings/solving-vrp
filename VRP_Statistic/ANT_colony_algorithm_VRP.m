% ��������� �������� ���������� ������� ��� ���������� ���������, ��
% ���������������(� �������� ���������� ���������) ���������
% �������� �� �����������, ������ �� ���������������� ��
function [ Route, Length_Route ] = ANT_colony_algorithm_VRP( ...
    distances, distances_bases, demands, param, vehicles_capacity ...
)
%clc
%waitBar = waitbar(0,'Please wait...');
%%
%������������� ������
iter_max = 5; % 100/������������ ���������� ��������

distances = add_bases_to_distances(distances, distances_bases);
vehicles_capacity = sort(vehicles_capacity,'descend'); %��������� ����������������� ����� � ��������� �������
demands = [vehicles_capacity(1) demands]; 
%������� ��������� ������ ��� ��, ��� ����� �������� ��
%���������������� � ��������
cell_capacities = vehicles_capacities_to_cellarray(vehicles_capacity); %��������� ���������������� ������� ��
vehicles = struct('capacity',cell_capacities,'route',cell(1,length(vehicles_capacity)));
%�������������� ��������� ���� ��� ���� ��
for i = 1:length(vehicles)
    vehicles(i).route = 1;
end
nvehicle = 1; %�������� � 1-�� ��

dim = length(distances); %���������� �������
Route = zeros(1,dim); %������� ������ ��� ������� �������
c = demands(1); %���������������� 1-��� ��
N_of_vehicles = length(vehicles);

evaporation_fer = param(1);%����������� ��������� �������� [0;1]
alpha = param(2); %��� alpha = 0 ����� ������ ��������� �����, ��� ������������� ������� ��������� � ������������ ������ �����������. ����
beta = param(3); %beta = 0, ����� �������� ���� ���������� ��������, ��� ������ �� ����� ������� ������������������� � ������ ��������������� �������.
tau0 = param(4); %���������� ��������
tau = zeros(dim); %������� ���������� ����������� ���������
eta = zeros(dim); %"���������" ������, ������������� ������� �������� ����� j �� ������ i � ��� ����� �����, ��� ������ ������� �������� ���.
Q = 0; %������� ����� ������������ ��������
N_ants = dim; %���������� ��������

ants_in_cities = zeros(1, N_ants); %������� � �������
route_ants = zeros(N_ants, 2*N_ants + 1); %������� ��� ������� �� ��������
length_route_ants = zeros(1, N_ants);%����� �������� ��� ������� �� ��������
entries_in_cities = zeros(1, dim); %������ ��� �����������, ��� �� ������� � ������(1 - ���, 0 - �� ���)

for i = 1:dim
    for j = 1:dim
        if i ~= j
            eta(i,j) = 1/distances(i,j); %���������
            tau(i,j) = tau0; %�������
        else
            tau(i,j) = 0;
        end
    end  
end
%��������� ������� ������� � �������� ��������� ����� 
ants_in_cities = randperm(N_ants);
%�������� �������-���������� ������� Route � ����������� ��� �����
Route = ants_in_cities;
Length_Route = length_of_route(Route, distances) * 10; %��� �����������, ��� ��� ����� �� '���������'
Q = Length_Route;
P = zeros(1, dim); %����������� ��������� ������� �� 1-�� ������ �� dim-�� ������
%%
%----------------------��������� ����---------------------------------------
for iter = 1: iter_max
    
    for ant = 1: N_ants
        %��������� ���������������� ��
        nvehicle = 1;
        c = vehicles(nvehicle).capacity; 
    %-----------------��� ������� ������� ������ ������� � ������������ ��� �����--------
        i = ants_in_cities(ant); %������� ��������� ����� �������
        q2 = demands(i); % ������� ������ ��������� �� ������(�����������, ��� ������ ���������� ������ �� ��������� ��������������� ������)
        entries_in_cities(i) = 1;
        route_ants(ant, 1) = i;
        ind_city_for_route_ant = 1; %���������� ����� ������ � ��������
        while ~all(entries_in_cities) %���� ���� �� ���������� ������
                ind_city_for_route_ant = ind_city_for_route_ant + 1; %��������� � ������� ����. ������
                for j = 1: dim
                    %������� ����������� ������ � ������ �� ���������� �����
                    if entries_in_cities(j) == 0 %���� �� ���������� �����
                        sum = 0;
                        for el = 1: dim
                            if entries_in_cities(el) == 0
                                sum = sum + (tau(i,el)^alpha * eta(i,el)^beta);
                            end
                        end
                        P(j) = (tau(i,j)^alpha * eta(i,j)^beta)/sum;
                    end
                end
                P(1) = 0; %�������� ���� � ��������, ��� ��������������� �����
                %///////////////////////////////////////////////////////
                [~, city_ind_P_max] = max(P);%������� ������������ ������� � �������-������������
                q1 = demands(city_ind_P_max);
                if q1 + q2 <= c 
                    route_ants(ant, ind_city_for_route_ant) = city_ind_P_max; %��������� ����� � ������� �������� �������
                    entries_in_cities(city_ind_P_max) = 1;
                    i = city_ind_P_max; %����. ����� ������������ � ���. �����������
                    q2 = q2 + q1;
                else
                    route_ants(ant, ind_city_for_route_ant) = 1; %������� �� ���� �������
                    entries_in_cities(1) = 1;
                    i = 1; %������� �� ���� 
                    q2 = 0;
                    nvehicle = get_No_vehicle(nvehicle,N_of_vehicles);
                    c = vehicles(nvehicle).capacity; 
                end
                %//////////////////////////////////////////////////////
                %__________________________________________________________
                P = zeros(1, dim); %�������� ��� ����������� � �������
                %___________________________________________________________
        end
        route = [1, route_ants(ant, :)];
        route(route == 0) = []; %������� �������� ���� 
        route(end + 1) = 1; %������� �� ���� 
        length_route_ants(ant) = length_of_route(route, distances); %������� ����� �������� �������� �������
        entries_in_cities = zeros(1, dim); %�������� ��� ��������� ������� ����������� �������
    %-------------------------------------------------------------------------------------
    
    %res = ((iter - 1)+(ant/N_ants))/(iter_max);
    %waitbar(res,waitBar,sprintf('Processing... %d %%',round(res*100)));
    
    end
    %___________________________������� �� �������?_____________________
    [min_length_route, ind_min_len_route] = min(length_route_ants);
    if Length_Route > min_length_route %���� ������� ����� �������� ������ ���������� ������������
        Length_Route = min_length_route; %��������� ����� �������� ��������
        route = [1, route_ants(ind_min_len_route, :)];
        route(route == 0) = []; 
        Route = [route, 1]; %��������� ��������� �������
        Route = delete_duplicates_stations(Route);
        Q = Length_Route;
    end
    %__________________________________________________________________
    %-----------��������� ����� ��������--------------------------------
    sum_delta_tau = zeros(dim);
    for ant = 1: N_ants
        delta_tau = zeros(dim); %���������� �������� �� ������ �� �����
        for w = 1:length(route_ants(ant, :)) - 1
            Ri = route_ants(ant, w); Ri(Ri == 0) = [];
            Rj = route_ants(ant, w + 1); Rj(Rj == 0) = [];
            i = Ri;
            j = Rj;
            delta_tau(i,j) = Q/length_route_ants(ant);
        end
        sum_delta_tau = sum_delta_tau + delta_tau;
    end
    tau = (1 - evaporation_fer) * tau + sum_delta_tau;
    tau(1,1) = 0;
    %-------------------------------------------------------------------
    route_ants(:,:) = 0;
end

%%
%delete(waitBar);

%%

%vehicles = create_routes_for_vehicles(vehicles,Route);

%vehicles(1:end).route %���������� � ��������� ��� ������� ��
%Length_Route
%create_plot_route_with_vehicles(distances,vehicles,demands);
%_______________________________________________________________________
%��� ������ �������� ������������
% sum_demands = 0;
% for i = 1:length(Route)
%    if Route(i) == 1
%       sum_demands
%       sum_demands = 0;
%    else
%       sum_demands = sum_demands + demands(Route(i));
%    end
% end
%_______________________________________________________________________
end

function [vehicles] = create_routes_for_vehicles(vehicles,ROUTE)
    nvehicle = 1; %�������� � 1-�� �� 
    N_of_vehicles = length(vehicles);
    bases = find(ROUTE == 1); %���� ������� � ����� � �������� 
    for i = 1:length(bases) - 1
        ind_start = bases(i) + 1;
        ind_end = bases(i + 1);
        vehicles(nvehicle).route = [ vehicles(nvehicle).route ROUTE(ind_start:ind_end)];
        nvehicle = get_No_vehicle(nvehicle, N_of_vehicles);
    end
end

%�������� ����� ��(���������������)
function [nvehicle] = get_No_vehicle(nvehicle, N_of_vehicles)
    nvehicle = nvehicle + 1;                
    if nvehicle > N_of_vehicles
    	nvehicle = 1; %�������� � 1-�� �� 
    end
end

%��������� ������������� ����� �������� ��� ��
function [ length_of_path ] = length_of_route_for_vehicles( vehicles, distances)
    length_of_path = 0;
    for k = 1:length(vehicles)
        route = vehicles(k).route;
        for i = 1:length(route) - 1
            length_of_path = length_of_path + distances(route(i),route(i + 1)); 
        end
    end
end

%��������� ������������� ����� ��������
function [ length_of_path ] = length_of_route( route, distances)
    length_of_path = 0;
    for m = 1:length(route) - 1
       length_of_path = length_of_path + distances(route(m),route(m + 1)); 
    end
end
