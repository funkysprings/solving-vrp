% Используя алгоритм муравьиных колоний для построения маршрутов, мы
% последовательно(в процессе выполнения алгоритма) разбиваем
% маршруты на подмаршруты, исходя из грузовместимости ТС
function [ Route, Length_Route ] = ANT_colony_algorithm_VRP( ...
    distances, distances_bases, demands, param, vehicles_capacity ...
)
%clc
%waitBar = waitbar(0,'Please wait...');
%%
%Инициализация данных
iter_max = 5; % 100/максимальное количество итераций

distances = add_bases_to_distances(distances, distances_bases);
vehicles_capacity = sort(vehicles_capacity,'descend'); %сортируем грузвовместимость машин в убывающем порядке
demands = [vehicles_capacity(1) demands]; 
%создаем структуру данных для ТС, где будут хранится их
%грузоподьемности и маршруты
cell_capacities = vehicles_capacities_to_cellarray(vehicles_capacity); %сохраняем грузоподьемность каждого ТС
vehicles = struct('capacity',cell_capacities,'route',cell(1,length(vehicles_capacity)));
%инициализируем стартовую базу для всех ТС
for i = 1:length(vehicles)
    vehicles(i).route = 1;
end
nvehicle = 1; %начинаем с 1-го ТС

dim = length(distances); %количество городов
Route = zeros(1,dim); %создаем массив под будущий маршрут
c = demands(1); %грузовместимость 1-ого ТС
N_of_vehicles = length(vehicles);

evaporation_fer = param(1);%коэффициент испарения феромона [0;1]
alpha = param(2); %При alpha = 0 будет выбран ближайший город, что соответствует жадному алгоритму в классической теории оптимизации. Если
beta = param(3); %beta = 0, тогда работает лишь феромонное усиление, что влечет за собой быстрое вырождениемаршрутов к одному субоптимальному решению.
tau0 = param(4); %количество феромона
tau = zeros(dim); %матрица количества виртуальных феромонов
eta = zeros(dim); %"видимость" города, эвристическое желание посетить город j из города i — чем ближе город, тем больше желание посетить его.
Q = 0; %порядок длины оптимального маршрута
N_ants = dim; %количество муравьев

ants_in_cities = zeros(1, N_ants); %муравьи в городах
route_ants = zeros(N_ants, 2*N_ants + 1); %маршрут для каждого из муравьев
length_route_ants = zeros(1, N_ants);%длина маршрута для каждого из муравьев
entries_in_cities = zeros(1, dim); %массив для определения, был ли муравей в городе(1 - был, 0 - не был)

for i = 1:dim
    for j = 1:dim
        if i ~= j
            eta(i,j) = 1/distances(i,j); %видимость
            tau(i,j) = tau0; %феромон
        else
            tau(i,j) = 0;
        end
    end  
end
%размещаем каждого муравья в случайно выбранный город 
ants_in_cities = randperm(N_ants);
%Выбираем условно-кратчайший маршрут Route и расчитываем его длину
Route = ants_in_cities;
Length_Route = length_of_route(Route, distances) * 10; %для уверенности, что эта длина не 'сработает'
Q = Length_Route;
P = zeros(1, dim); %вероятности посещения муравья от 1-го города до dim-го города
%%
%----------------------основноый цикл---------------------------------------
for iter = 1: iter_max
    
    for ant = 1: N_ants
        %обновляем грузовместимости ТС
        nvehicle = 1;
        c = vehicles(nvehicle).capacity; 
    %-----------------для каждого муравья строим маршрут и рассчитываем его длину--------
        i = ants_in_cities(ant); %находим стартовый город муравья
        q2 = demands(i); % находим запрос продукции по городу(предполагая, что запрос стартового города не превышают грузоместимости машины)
        entries_in_cities(i) = 1;
        route_ants(ant, 1) = i;
        ind_city_for_route_ant = 1; %порядковый номер города в маршруте
        while ~all(entries_in_cities) %пока есть не посещенные города
                ind_city_for_route_ant = ind_city_for_route_ant + 1; %переходим к индексу след. городу
                for j = 1: dim
                    %считаем вероятность похода в каждый не посещенный город
                    if entries_in_cities(j) == 0 %если не посещенный город
                        sum = 0;
                        for el = 1: dim
                            if entries_in_cities(el) == 0
                                sum = sum + (tau(i,el)^alpha * eta(i,el)^beta);
                            end
                        end
                        P(j) = (tau(i,j)^alpha * eta(i,j)^beta)/sum;
                    end
                end
                P(1) = 0; %обнуляем базу с запасами, как наивероятнейший выбор
                %///////////////////////////////////////////////////////
                [~, city_ind_P_max] = max(P);%находим максимальный элемент в векторе-вероятностей
                q1 = demands(city_ind_P_max);
                if q1 + q2 <= c 
                    route_ants(ant, ind_city_for_route_ant) = city_ind_P_max; %добавляем город в маршрут текущего муравья
                    entries_in_cities(city_ind_P_max) = 1;
                    i = city_ind_P_max; %след. город наивероятнее с мин. расстоянием
                    q2 = q2 + q1;
                else
                    route_ants(ant, ind_city_for_route_ant) = 1; %возврат на базу запасов
                    entries_in_cities(1) = 1;
                    i = 1; %возврат на базу 
                    q2 = 0;
                    nvehicle = get_No_vehicle(nvehicle,N_of_vehicles);
                    c = vehicles(nvehicle).capacity; 
                end
                %//////////////////////////////////////////////////////
                %__________________________________________________________
                P = zeros(1, dim); %обнуляем все вероятности в городах
                %___________________________________________________________
        end
        route = [1, route_ants(ant, :)];
        route(route == 0) = []; %убираем ненужные нули 
        route(end + 1) = 1; %возврат на базу 
        length_route_ants(ant) = length_of_route(route, distances); %считаем длину маршрута текущего муравья
        entries_in_cities = zeros(1, dim); %отменяем все посещения городов предыдущего муравья
    %-------------------------------------------------------------------------------------
    
    %res = ((iter - 1)+(ant/N_ants))/(iter_max);
    %waitbar(res,waitBar,sprintf('Processing... %d %%',round(res*100)));
    
    end
    %___________________________Найдено ли решение?_____________________
    [min_length_route, ind_min_len_route] = min(length_route_ants);
    if Length_Route > min_length_route %если текущая длина маршрута больше найденного минимального
        Length_Route = min_length_route; %обновляем длину текущего маршрута
        route = [1, route_ants(ind_min_len_route, :)];
        route(route == 0) = []; 
        Route = [route, 1]; %обновляем наилучший маршрут
        Route = delete_duplicates_stations(Route);
        Q = Length_Route;
    end
    %__________________________________________________________________
    %-----------Обновляем следы феромона--------------------------------
    sum_delta_tau = zeros(dim);
    for ant = 1: N_ants
        delta_tau = zeros(dim); %количество феромона на каждом из ребер
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

%vehicles(1:end).route %информация о маршрутах для каждого ТС
%Length_Route
%create_plot_route_with_vehicles(distances,vehicles,demands);
%_______________________________________________________________________
%для вывода запросов потребителей
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
    nvehicle = 1; %начинаем с 1-го ТС 
    N_of_vehicles = length(vehicles);
    bases = find(ROUTE == 1); %ищем индексы с базой в маршруте 
    for i = 1:length(bases) - 1
        ind_start = bases(i) + 1;
        ind_end = bases(i + 1);
        vehicles(nvehicle).route = [ vehicles(nvehicle).route ROUTE(ind_start:ind_end)];
        nvehicle = get_No_vehicle(nvehicle, N_of_vehicles);
    end
end

%Получаем номер ТС(последовательно)
function [nvehicle] = get_No_vehicle(nvehicle, N_of_vehicles)
    nvehicle = nvehicle + 1;                
    if nvehicle > N_of_vehicles
    	nvehicle = 1; %начинаем с 1-го ТС 
    end
end

%вычисляем протяженность всего маршрута для ТС
function [ length_of_path ] = length_of_route_for_vehicles( vehicles, distances)
    length_of_path = 0;
    for k = 1:length(vehicles)
        route = vehicles(k).route;
        for i = 1:length(route) - 1
            length_of_path = length_of_path + distances(route(i),route(i + 1)); 
        end
    end
end

%вычисляем протяженность всего маршрута
function [ length_of_path ] = length_of_route( route, distances)
    length_of_path = 0;
    for m = 1:length(route) - 1
       length_of_path = length_of_path + distances(route(m),route(m + 1)); 
    end
end
