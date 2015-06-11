function [ Route, Length_Route ] = ANT_colony_algorithm_VRP_with_savings( distances, demands, savings )
iter_max = 5; % 100/������������ ���������� ��������
dim = length(distances); %���������� �������
Route = zeros(1,dim); %������� ������ ��� ������� �������
c = demands(1); %���������������� ������

evaporation_fer = 0.5;%����������� ��������� �������� [0;1]
alpha = 0.5; %��� alpha = 0 ����� ������ ��������� �����, ��� ������������� ������� ��������� � ������������ ������ �����������. ����
beta = 0.5; %beta = 0, ����� �������� ���� ���������� ��������, ��� ������ �� ����� ������� ������������������� � ������ ��������������� �������.
tau0 = 0.25; %���������� ��������
tau = zeros(dim); %������� ���������� ����������� ���������
eta = savings; %"���������" ������, ������������� ������� �������� ����� j �� ������ i � ��� ����� �����, ��� ������ ������� �������� ���.
Q = 0; %������� ����� ������������ �������� ???
N_ants = dim; %���������� ��������

ants_in_cities = zeros(1, N_ants); %������� � �������
route_ants = zeros(N_ants, 2*N_ants + 1); %������� ��� ������� �� ��������
length_route_ants = zeros(1, N_ants);%����� �������� ��� ������� �� ��������
entries_in_cities = zeros(1, dim); %������ ��� �����������, ��� �� ������� � ������(1 - ���, 0 - �� ���)

for i = 1:dim
    for j = 1:dim
        if i ~= j
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
Length_Route = length_of_route(Route, distances);
Q = Length_Route; 
P = zeros(1, dim); %����������� ��������� ������� �� 1-�� ������ �� dim-�� ������
%----------------------��������� ����---------------------------------------
for iter = 1: iter_max
    
    for ant = 1: N_ants
    %-----------------��� ������� ������� ������ ������� � ������������ ��� �����--------
        i = ants_in_cities(ant); %������� ��������� ����� �������
        q2 = demands(i); %// ������� ������ ��������� �� ������(�����������, ��� ������ ���������� ������ �� ��������� ��������������� ������)
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
                [P_max, city_ind_P_max] = max(P);%������� ������������ ������� � �������-������������
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
    end
        %___________________________������� �� �������?_____________________
        [min_length_route, ind_min_len_route] = min(length_route_ants);
        if Length_Route > min_length_route %���� ������� ����� �������� ������ ���������� ������������
            Length_Route = min_length_route; %��������� ����� �������� ��������
            route = [1, route_ants(ind_min_len_route, :)];
            route(route == 0) = []; 
            Route = [route, 1]; %��������� ��������� ������� 
            Q = Length_Route; %???
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
Route
Length_Route
create_plot_route(distances, Route, demands);
%_______________________________________________________________________
%��� ������ �������� ������������
sum_demands = 0;
for i = 1:length(Route)
   if Route(i) == 1
      sum_demands
      sum_demands = 0;
      warning('_______________');
   else
      sum_demands = sum_demands + demands(Route(i));
   end
end
%_______________________________________________________________________
end


%��������� ������������� ����� ��������
function [ length_of_path ] = length_of_route( route, distances)
    length_of_path = 0;
    for m = 1:length(route) - 1
       length_of_path = length_of_path + distances(route(m),route(m + 1)); 
    end
end


