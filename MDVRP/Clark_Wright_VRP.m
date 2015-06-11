%
%!�����, ��� ��������� ���� � ��������, ���������� � ������ � ������������(1, 1)
function [ route, length_of_all_pathway, vehicles ] = Clark_Wright_VRP( ...
    demands, distances, distances_bases, vehicles_capacity ...
)
clc
waitBar = waitbar(0,'Please wait...');
%%
% ������������� ������

Iter = 0;

distances = add_bases_to_distances(distances, distances_bases);
distances_and_savings = create_distances_and_savings(distances); %������� ���������� � ���������
vehicles_capacity = sort(vehicles_capacity,'descend'); %��������� ����������������� ����� � ��������� �������
demands = [vehicles_capacity(1) demands];

dim = length(distances_and_savings);
c = demands(1); %���������������� ������

matrix_of_entries = eye(dim, dim);%������� ��������� � ��������� �� ������� ��������� - ����� ������, ���� �� ����������� ������ (i,j) ����� � ���������
N_of_bases = 1; %���������� ��������� ������� � ����� ��������, ��� ��������� ����
N_of_stations = 1; %����� ���������� ������� �� ���� ���������, � �.�. ��������� ����� ��������

route = []; %������� ������ ��� ������� �������
route(1) = 1; %��������� ����� �������� - ��� ���� ���� � ��������

max_iter = dim * 2000;

%������� ��������� ������ ��� ��, ��� ����� �������� ��
%���������������� � ��������
cell_capacities = vehicles_capacities_to_cellarray(vehicles_capacity); %��������� ���������������� ������� ��
vehicles = struct('capacity',cell_capacities,'route',cell(1,length(vehicles_capacity)));
%�������������� ��������� ���� ��� ���� ��
for i = 1:length(vehicles)
    vehicles(i).route = 1;
end

%%
while N_of_stations ~= dim
%-step1----------������� ������������ ������� ���� � ������ � ���� ���������-----------------------------------------
    s_max = 0; max_i = 1; max_j = 1;
    for i = 1:dim
        for j = 2:dim
                if i < j || distances_and_savings(i, j) <= s_max %������������� ������ ������ ����������� �������, �.�. ������������ ��������
                    continue;
                elseif matrix_of_entries(i, j) == 0 %���� ������ �� ���� ����������� ����� 
                        s_max = distances_and_savings(i, j); %�������� �������� �� ������������ ���������
                        max_i = i;
                        max_j = j;
                end
        end
    end
%-end1------------------------------------------------------------------------
    %��������� 3 �������
    if ~is_in_array(max_i ,route) || ~is_in_array(max_j ,route)%���� ���� �� ���� �� ������� ������ � ������ ��������
        %---------------------------------------------------------------
        index_max_i = find(route == max_i); %������� ������ 1-�� ������ � ������� ������ ��������
        index_max_j = find(route == max_j); %������� ������ 2-�� ������ � ������� ������ ��������
        [start_ind, sub_route, end_ind] = subroute(index_max_i, index_max_j, route); %start_ind - ��������� ������ �����������, � ������� ��������� ���� �� �������, � ������� ������ ��������//(start_ind, end_ind) = (0, 0) - ���� �� ���� �� ������� �� ������ � ����� �������
        %--------------------------------------------------------------
        if isempty(sub_route) || ((max_i == sub_route(1) || max_i == sub_route(length(sub_route))) || (max_j == sub_route(1) || max_j == sub_route(length(sub_route))))%�������� ��������� �/��� �������� ������� ��� ���������, � ������ ������� ��� ������
            [nvehicle,vehicle_station_index,vehicle_station_to_add] = get_No_vehicle(max_i, ...
                max_j, vehicles); %�������� ����� ���������������� ��
%-step2--------------------------������� ��������� ����� ��������------------------------------
                if isempty(sub_route)
                   q1 = demands(max_i);
                   q2 = demands(max_j);
                else
                    is_in_the_end_of_route = false; %��������� �� ��, ��� ����� �� ��������� � ����� ��������
                    if ~isempty(index_max_i) %���� ����� max_i ��������� � ����� ��������
                        if max_i == sub_route(length(sub_route))
                            is_in_the_end_of_route = true;
                        end
                        q1 = sum_supplies_on_route(sub_route, demands);
                        q2 = demands(max_j);
                    else
                        if max_j == sub_route(length(sub_route))
                            is_in_the_end_of_route = true;
                        end
                        q1 = demands(max_i);
                        q2 = sum_supplies_on_route(sub_route, demands);
                    end
                end
                c = vehicles(nvehicle).capacity;
%-end2------------------------------------------------------------------------
%-step3-----------------------���������, ����� ��������� ����� �������� ��� �� ������ ���������������� ������----------------------------------
                    if q1 + q2 <= c 
%-end3------------------------------------------------------------------------
                        if ~isempty(sub_route) %���� �� ��������� ��� ��������
                            if ~isempty(index_max_i) %���� ����� max_i ��������� � ����� ��������
                                if is_in_the_end_of_route %� � ����� �����������
                                    sub_route(length(sub_route) + 1) = max_j;
                                else
                                    sub_route = [max_j sub_route];
                                end
                            else %�����, ����� max_j ��������� � ����� ��������
                                if is_in_the_end_of_route
                                    sub_route(length(sub_route) + 1) = max_i;
                                else
                                    sub_route = [max_i sub_route];
                                end
                            end
                        else %����� ������� ����� ����������
                            sub_route(1) = max_i;
                            sub_route(2) = max_j;
                        end
                       %��������� ����� ���������� � ����� ������� � �����(� ����� � � ������� ��)
                        if (length(sub_route) == 2 && start_ind ~= end_ind) || (length(sub_route) == 2 && start_ind == 0 && end_ind == 0)
                            route = create_new_subroute(route, sub_route);
                            vehicles = add_new_route_to_vehicle(vehicles,sub_route,nvehicle);
                            N_of_bases = N_of_bases + 1;% ���������� ��������� ������� � ����� ��������, ��� ��������� ����, ����������� �� 1
                        else %��������� ����� � ���������� ������ �������� � �����(� ����� � � ������� ��)
                            vehicles(nvehicle).route = find_and_replace_subroute_in_vehicle( ...
                                vehicles(nvehicle).route, vehicle_station_index, vehicle_station_to_add);
                            route = find_and_replace_subroute(sub_route, route, start_ind, end_ind);
                        end
                    end
        end
    end
    matrix_of_entries(max_i, max_j) = 1;% ������������� "������", ������� ��������, ��� ������ ��� ��������������
    %������� ���������� ������� � ��������
    N_of_stations = length(route) - N_of_bases + 1;
    Iter = Iter + 1;
    if Iter == max_iter
       delete(waitBar);
       msgbox('No solutions found! Please change the demands of stations or capacities of vehicles.', ...
           'Error','error');
       display('No solution!');
       error('No solution!');
    end
    
    perc = round((N_of_stations/dim)*100);
    waitbar(N_of_stations/dim,waitBar,sprintf('Processing... %d %%',perc));
end

%%
delete(waitBar);

%%
%vehicles(1:end).route %���������� � ��������� ��� ������� ��

%-step6--------------------------------------------------------------------
%������� ������������� ����� ����

%route = fliplr(route);
length_of_all_pathway = length_of_route(vehicles, distances_and_savings);

%-6------------------------------------------------------------------------
%Iter
%create_plot_route_with_vehicles(distances,vehicles,demands);



%____________________��� ������ �������� ������������ �� ������ ����������� ���������-----------------
%sum_demands = 0;
%for i = 1:length(route)
%   if route(i) == 1
%      sum_demands
%      sum_demands = 0;
%      warning('_______________');
%   else
%      sum_demands = sum_demands + demands(route(i));
%   end
%end
%___________________________________________________------------------
end

%�������� ���������� � ����� ��������, ���� ������� ����������
% � ������� ���������� ������(�������) ������ � ����� ����������� � ������� ������
% ��������
function [ start_ind, sub_route ,end_ind ] = subroute( index_p1, index_p2, route)
    if isempty(index_p1) && isempty(index_p2) %���� ����������� ��� � ����� ��������
        sub_route = [];
        start_ind = 0; end_ind = 0;
    else
        sub_route = zeros(1,length(route)); %�������� ������ ��� ����������-������ � ������
        i = 1;
        if isempty(index_p1) && ~isempty(index_p2) %���� ������ ����� ����������� � ����� ��������,� ������ ������������
            while route(index_p2 - 1) ~= 1 %�������� "�����" �� ������� ������ ��������, ���� �� �������� 1
               index_p2 = index_p2 - 1; 
            end
            start_ind = index_p2;
            while route(index_p2) ~=1 %������ �������� "������", ���� �� �������� 1
                sub_route(i) = route(index_p2); %��������� � ���������� ������ �� ������ ��������
                index_p2 = index_p2 + 1;
                i = i + 1;
            end
            end_ind = index_p2 - 1;
        else %�����, ���� ������ ����� ����������� � ����� ��������,� ������ ������������
            while route(index_p1 - 1) ~= 1
               index_p1 = index_p1 - 1; 
            end
            start_ind = index_p1;
            while route(index_p1) ~=1
                sub_route(i) = route(index_p1);
                index_p1 = index_p1 + 1;
                i = i + 1;
            end 
            end_ind = index_p1 - 1;
        end
        sub_route(sub_route == 0) = []; %������� �������� ����
    end
end

%������� ���������� � ��������, �������� ��� �� ����� � ���������� �����
% �������
function [ route ] = find_and_replace_subroute(sub_route, route, start_ind, end_ind)
    for i = 1: length(sub_route)
        route(start_ind + i - 1) = sub_route(i);
    end
    route_temp = [];
    for i = end_ind + 2: length(route)
        route_temp(i - (end_ind + 1)) = route(i);
    end
    route(end_ind + 2) = 1;
    for i = 1: length(route_temp)
        route(end_ind + 2 + i) = route_temp(i);
    end
end

%������� ���������� � �������� ��, �������� ��� �� ����� � ���������� �����
%������� ��
function [temp_route] = find_and_replace_subroute_in_vehicle(route, vehicle_station_index, ...
                            station_to_add)
    temp_route = zeros(1,length(route)+1);
    if(route(vehicle_station_index + 1) == 1)
        temp_route = [route(1:vehicle_station_index) station_to_add route(vehicle_station_index + 1:end)];
    else
        temp_route = [route(1:vehicle_station_index - 1) station_to_add route(vehicle_station_index:end)];
    end
end

%�������� ����� ��
function [nvehicle,vehicle_station_index,vehicle_station_to_add] = get_No_vehicle(station1, station2, vehicles)
    dim = length(vehicles);
    vehicle_station_index = -1;
    vehicle_station_to_add = -1;
    %���� ����� ������������ ���� �� � ����� �������� �.�.
    for i = 1:dim
        route = vehicles(i).route;
        ind_station1 = find(route == station1,1);
        ind_station2 = find(route == station2,1);
        if ~isempty(ind_station1) || ~isempty(ind_station2)
           if ind_station1 > 0
               vehicle_station_index = ind_station1;
               vehicle_station_to_add = station2;
           else
               vehicle_station_index = ind_station2;
               vehicle_station_to_add = station1;
           end
           nvehicle = i;
           return;
        end
    end
    %���� ��������� ��
    N_of_bases_in_routes = zeros(1,dim);
    for i = 1:dim
        route = vehicles(i).route;
        N_of_bases_in_routes(i) = length(find(route == 1));
    end
    [~,ind_min_el] = min(N_of_bases_in_routes);
    nvehicle = ind_min_el;
end

%��������� ����� ���������� � ������� ��
function [vehicles] = add_new_route_to_vehicle(vehicles, sub_route, nvehicle)
    route = create_new_subroute(vehicles(nvehicle).route, sub_route);
    vehicles(nvehicle).route = route;
end

%������� ����� ���������� � ��������
function [route] = create_new_subroute(route, sub_route)
    temp_index = find(route == 1, 1, 'last');
    route(temp_index + 1) = sub_route(1);
    route(temp_index + 2) = sub_route(2);
    route(temp_index + 3) = 1;
end

%��������� ������������� ����� ��������
function [ length_of_path ] = length_of_route( vehicles, distances)
    length_of_path = 0;
    for k = 1:length(vehicles)
        route = fliplr(vehicles(k).route);
        for i = 1:length(route) - 1
            length_of_path = length_of_path + distances(route(i),route(i + 1)); 
        end
    end
end

%�������, ������������, ��������� �� ������� � �������
function [ logic ] = is_in_array( element, arr )
    for i = 1:length(arr)
        if element == arr(i)
            logic = true;
            return;
        end
    end
    logic = false;
end

%��������� ����� �������� �� ��������
function [ sum ] = sum_supplies_on_route( route, demands )
sum = 0;
    for i = 1:length(route)
       sum = sum + demands(route(i)); 
    end
end