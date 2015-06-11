function [ Route, Length_Route ] = ANT_colony_algorithm_minpath( distances, param)
iter_max = 7; % 100/максимальное количество итераций
dim = length(distances); %количество городов
Route = zeros(1,dim + 1); %создаем массив под будущий маршрут

evaporation_fer = param(1);%коэффициент испарения феромона [0;1]
alpha = param(2); %При alpha = 0 будет выбран ближайший город, что соответствует жадному алгоритму в классической теории оптимизации. Если
beta = param(3); %beta = 0, тогда работает лишь феромонное усиление, что влечет за собой быстрое вырождениемаршрутов к одному субоптимальному решению.
tau0 = param(4); %количество феромона
tau = zeros(dim); %матрица количества виртуальных феромонов
eta = zeros(dim); %"видимость" города, эвристическое желание посетить город j из города i — чем ближе город, тем больше желание посетить его.
Q = 0; %порядок длины оптимального маршрута ???????????????????????????????????????????????????????
N_ants = dim; %количество муравьев

ants_in_cities = zeros(1, N_ants); %муравьи в городах
route_ants = zeros(N_ants, N_ants + 1); %маршрут для каждого из муравьев
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
Route = [ants_in_cities, ants_in_cities(1)]; %циклический маршрут
Length_Route = length_of_route(Route, distances);
Q = Length_Route; %?????????????????????????????????????????????????????????????????????????????
P = zeros(1, dim); %вероятности посещения муравья от 1-го города до dim-го города
%----------------------основноый цикл---------------------------------------
for iter = 1: iter_max
    
    for ant = 1: N_ants
    %-----------------для каждого муравья строим маршрут и рассчитываем его длину--------
        i = ants_in_cities(ant); %находим стартовый город муравья
        entries_in_cities(i) = 1;
        route_ants(ant, 1) = i;
        ind_city_for_route_ant = 1; %порядковый номер города в маршруте
        while ~all(entries_in_cities) %пока есть не посещенные города
                ind_city_for_route_ant = ind_city_for_route_ant + 1; %переходим к индексу след. городу
                for j = 1: dim
                    %считаем вероятность похода в каждый не посещенный город
                    if entries_in_cities(j) == 0 %если не посещенный город
                        sum = 0;
                        for l = 1: dim
                            if entries_in_cities(l) == 0
                                sum = sum + (tau(i,l)^alpha * eta(i,l)^beta);
                            end
                        end
                        P(j) = (tau(i,j)^alpha * eta(i,j)^beta)/sum;
                    end
                end
                [P_max, city_ind_P_max] = max(P);%находим максимальный элемент в векторе-вероятностей
                route_ants(ant, ind_city_for_route_ant) = city_ind_P_max; %добавляем город в маршрут текущего муравья
                entries_in_cities(city_ind_P_max) = 1;
                P = zeros(1, dim); %обнуляем все вероятности в городах
                i = city_ind_P_max;
        end
        route_ants(ant, end) = route_ants(ant, 1);
        length_route_ants(ant) = length_of_route(route_ants(ant, :), distances); %считаем длину маршрута текущего муравья
        entries_in_cities = zeros(1, dim); %отменяем все посещения городов предыдущего муравья
    %-------------------------------------------------------------------------------------
    end
        %___________________________Найдено ли решение?_____________________
        [min_length_route, ind_min_len_route] = min(length_route_ants);
        if Length_Route > min_length_route %если текущая длина маршрута больше найденного минимального
            Length_Route = min_length_route; %обновляем длину текущего маршрута
            Route = route_ants(ind_min_len_route, :); %обновляем наилучший маршрут
            Q = Length_Route;%??????????????????????????????????????????????????????????????????
        end
        %__________________________________________________________________
    %-----------Обновляем следы феромона--------------------------------
    sum_delta_tau = zeros(dim);
    for ant = 1: N_ants
        delta_tau = zeros(dim); %количество феромона на каждом из ребер
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


%вычисляем протяженность всего маршрута
function [ length_of_path ] = length_of_route( route, distances)
    length_of_path = 0;
    for m = 1:length(route) - 1
       length_of_path = length_of_path + distances(route(m),route(m + 1)); 
    end
end
