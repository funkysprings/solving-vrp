function [ Route, Length_Route ] = ANT_colony_algorithm_minpath( distances, param)
iter_max = 7; % 100/������������ ���������� ��������
dim = length(distances); %���������� �������
Route = zeros(1,dim + 1); %������� ������ ��� ������� �������

evaporation_fer = param(1);%����������� ��������� �������� [0;1]
alpha = param(2); %��� alpha = 0 ����� ������ ��������� �����, ��� ������������� ������� ��������� � ������������ ������ �����������. ����
beta = param(3); %beta = 0, ����� �������� ���� ���������� ��������, ��� ������ �� ����� ������� ������������������� � ������ ��������������� �������.
tau0 = param(4); %���������� ��������
tau = zeros(dim); %������� ���������� ����������� ���������
eta = zeros(dim); %"���������" ������, ������������� ������� �������� ����� j �� ������ i � ��� ����� �����, ��� ������ ������� �������� ���.
Q = 0; %������� ����� ������������ �������� ???????????????????????????????????????????????????????
N_ants = dim; %���������� ��������

ants_in_cities = zeros(1, N_ants); %������� � �������
route_ants = zeros(N_ants, N_ants + 1); %������� ��� ������� �� ��������
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
Route = [ants_in_cities, ants_in_cities(1)]; %����������� �������
Length_Route = length_of_route(Route, distances);
Q = Length_Route; %?????????????????????????????????????????????????????????????????????????????
P = zeros(1, dim); %����������� ��������� ������� �� 1-�� ������ �� dim-�� ������
%----------------------��������� ����---------------------------------------
for iter = 1: iter_max
    
    for ant = 1: N_ants
    %-----------------��� ������� ������� ������ ������� � ������������ ��� �����--------
        i = ants_in_cities(ant); %������� ��������� ����� �������
        entries_in_cities(i) = 1;
        route_ants(ant, 1) = i;
        ind_city_for_route_ant = 1; %���������� ����� ������ � ��������
        while ~all(entries_in_cities) %���� ���� �� ���������� ������
                ind_city_for_route_ant = ind_city_for_route_ant + 1; %��������� � ������� ����. ������
                for j = 1: dim
                    %������� ����������� ������ � ������ �� ���������� �����
                    if entries_in_cities(j) == 0 %���� �� ���������� �����
                        sum = 0;
                        for l = 1: dim
                            if entries_in_cities(l) == 0
                                sum = sum + (tau(i,l)^alpha * eta(i,l)^beta);
                            end
                        end
                        P(j) = (tau(i,j)^alpha * eta(i,j)^beta)/sum;
                    end
                end
                [P_max, city_ind_P_max] = max(P);%������� ������������ ������� � �������-������������
                route_ants(ant, ind_city_for_route_ant) = city_ind_P_max; %��������� ����� � ������� �������� �������
                entries_in_cities(city_ind_P_max) = 1;
                P = zeros(1, dim); %�������� ��� ����������� � �������
                i = city_ind_P_max;
        end
        route_ants(ant, end) = route_ants(ant, 1);
        length_route_ants(ant) = length_of_route(route_ants(ant, :), distances); %������� ����� �������� �������� �������
        entries_in_cities = zeros(1, dim); %�������� ��� ��������� ������� ����������� �������
    %-------------------------------------------------------------------------------------
    end
        %___________________________������� �� �������?_____________________
        [min_length_route, ind_min_len_route] = min(length_route_ants);
        if Length_Route > min_length_route %���� ������� ����� �������� ������ ���������� ������������
            Length_Route = min_length_route; %��������� ����� �������� ��������
            Route = route_ants(ind_min_len_route, :); %��������� ��������� �������
            Q = Length_Route;%??????????????????????????????????????????????????????????????????
        end
        %__________________________________________________________________
    %-----------��������� ����� ��������--------------------------------
    sum_delta_tau = zeros(dim);
    for ant = 1: N_ants
        delta_tau = zeros(dim); %���������� �������� �� ������ �� �����
        for w = 1:(dim - 1)
            i = route_ants(ant, w);
            j = route_ants(ant, w + 1);
            delta_tau(i,j) = Q/length_route_ants(ant);
        end
        sum_delta_tau = sum_delta_tau + delta_tau;
    end
    tau = (1 - evaporation_fer) * tau + sum_delta_tau;
    %-------------------------------------------------------------------
end
Route
Length_Route
end


%��������� ������������� ����� ��������
function [ length_of_path ] = length_of_route( route, distances)
    length_of_path = 0;
    for m = 1:length(route) - 1
       length_of_path = length_of_path + distances(route(m),route(m + 1)); 
    end
end
