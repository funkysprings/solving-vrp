%
%!пункт, где находится база с запасами, расположен в ячейке с координатами(1, 1)
function [ route, length_of_all_pathway, vehicles ] = Clark_Wright_VRP( ...
    demands, distances, distances_bases, vehicles_capacity ...
)
clc
waitBar = waitbar(0,'Please wait...');
%%
% Инициализация данных

Iter = 0;

distances = add_bases_to_distances(distances, distances_bases);
distances_and_savings = create_distances_and_savings(distances); %матрица расстояний и выигрышей
vehicles_capacity = sort(vehicles_capacity,'descend'); %сортируем грузвовместимость машин в убывающем порядке
demands = [vehicles_capacity(1) demands];

dim = length(distances_and_savings);
c = demands(1); %грузовместимость машины

matrix_of_entries = eye(dim, dim);%матрица вхождений с единицами на главной диагонали - чтобы понять, была ли рассмотрена ячейка (i,j) ранее в алгоритме
N_of_bases = 1; %количество начальных пунктов в общем маршруте, где находится база
N_of_stations = 1; %общее количество пунктов во всех маршрутах, в т.ч. начальный пункт отправки

route = []; %создаем массив под будущий маршрут
route(1) = 1; %начальный пункт отправки - это наша база с запасами

max_iter = dim * 2000;

%создаем структуру данных для ТС, где будут хранится их
%грузоподьемности и маршруты
cell_capacities = vehicles_capacities_to_cellarray(vehicles_capacity); %сохраняем грузоподьемность каждого ТС
vehicles = struct('capacity',cell_capacities,'route',cell(1,length(vehicles_capacity)));
%инициализируем стартовую базу для всех ТС
for i = 1:length(vehicles)
    vehicles(i).route = 1;
end

%%
while N_of_stations ~= dim
%-step1----------находим максимальный выигрыш пути и пункты с этим выигрышем-----------------------------------------
    s_max = 0; max_i = 1; max_j = 1;
    for i = 1:dim
        for j = 2:dim
                if i < j || distances_and_savings(i, j) <= s_max %просматриваем только нижнюю треугольную матрицу, т.е. километровые выиграши
                    continue;
                elseif matrix_of_entries(i, j) == 0 %если ячейка не была рассмотрена ранее 
                        s_max = distances_and_savings(i, j); %выбираем максимум из километровых выигрышей
                        max_i = i;
                        max_j = j;
                end
        end
    end
%-end1------------------------------------------------------------------------
    %проверяем 3 условия
    if ~is_in_array(max_i ,route) || ~is_in_array(max_j ,route)%если хоят бы один из пунктов входит в состав маршрута
        %---------------------------------------------------------------
        index_max_i = find(route == max_i); %находим инедкс 1-го пункта в массиве общего маршрута
        index_max_j = find(route == max_j); %находим инедкс 2-го пункта в массиве общего маршрута
        [start_ind, sub_route, end_ind] = subroute(index_max_i, index_max_j, route); %start_ind - начальный индекс подмаршрута, в котором находится один из пунктов, в массиве общего маршрута//(start_ind, end_ind) = (0, 0) - если ни один из пунктов не входит в общий маршрут
        %--------------------------------------------------------------
        if isempty(sub_route) || ((max_i == sub_route(1) || max_i == sub_route(length(sub_route))) || (max_j == sub_route(1) || max_j == sub_route(length(sub_route))))%являются начальным и/или конечным пунктом тех маршрутов, в состав которых они входят
            [nvehicle,vehicle_station_index,vehicle_station_to_add] = get_No_vehicle(max_i, ...
                max_j, vehicles); %получаем номер рассматриваемого ТС
%-step2--------------------------находим суммарный объем поставок------------------------------
                if isempty(sub_route)
                   q1 = demands(max_i);
                   q2 = demands(max_j);
                else
                    is_in_the_end_of_route = false; %указывает на то, что пункт не находится в конце маршрута
                    if ~isempty(index_max_i) %если пункт max_i находится в общем маршруте
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
%-step3-----------------------проверяем, чтобы суммарный объем поставок был не больше грузовместимости машины----------------------------------
                    if q1 + q2 <= c 
%-end3------------------------------------------------------------------------
                        if ~isempty(sub_route) %если мы соединяем два маршрута
                            if ~isempty(index_max_i) %если пункт max_i находится в общем маршруте
                                if is_in_the_end_of_route %и в конце подмаршрута
                                    sub_route(length(sub_route) + 1) = max_j;
                                else
                                    sub_route = [max_j sub_route];
                                end
                            else %иначе, пункт max_j находится в общем маршруте
                                if is_in_the_end_of_route
                                    sub_route(length(sub_route) + 1) = max_i;
                                else
                                    sub_route = [max_i sub_route];
                                end
                            end
                        else %иначе создаем новый подмаршрут
                            sub_route(1) = max_i;
                            sub_route(2) = max_j;
                        end
                       %добавляем новый подмаршрут в общий маршрут с базой(в общий и в маршрут ТС)
                        if (length(sub_route) == 2 && start_ind ~= end_ind) || (length(sub_route) == 2 && start_ind == 0 && end_ind == 0)
                            route = create_new_subroute(route, sub_route);
                            vehicles = add_new_route_to_vehicle(vehicles,sub_route,nvehicle);
                            N_of_bases = N_of_bases + 1;% количество начальных пунктов в общем маршруте, где находится база, увеличиваем на 1
                        else %добавляем пункт в подмаршрут общего маршрута с базой(в общий и в маршрут ТС)
                            vehicles(nvehicle).route = find_and_replace_subroute_in_vehicle( ...
                                vehicles(nvehicle).route, vehicle_station_index, vehicle_station_to_add);
                            route = find_and_replace_subroute(sub_route, route, start_ind, end_ind);
                        end
                    end
        end
    end
    matrix_of_entries(max_i, max_j) = 1;% устанавливаем "флажок", который означает, что ячейка уже использовалась
    %считаем количество пунктов в маршруте
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
%vehicles(1:end).route %информация о маршрутах для каждого ТС

%-step6--------------------------------------------------------------------
%считаем протяженность всего пути

%route = fliplr(route);
length_of_all_pathway = length_of_route(vehicles, distances_and_savings);

%-6------------------------------------------------------------------------
%Iter
%create_plot_route_with_vehicles(distances,vehicles,demands);



%____________________для вывода запросов потребителей по каждым циклическим маршрутам-----------------
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

%выделяем подмаршрут в общем маршруте, если таковой существует
% и находим порядковые номера(индексы) начала и конца подмаршрута в массиве общего
% маршрута
function [ start_ind, sub_route ,end_ind ] = subroute( index_p1, index_p2, route)
    if isempty(index_p1) && isempty(index_p2) %если подмаршрута нет в общем маршруте
        sub_route = [];
        start_ind = 0; end_ind = 0;
    else
        sub_route = zeros(1,length(route)); %выделяем память под подмаршрут-массив с нулями
        i = 1;
        if isempty(index_p1) && ~isempty(index_p2) %если первый пункт отсутствует в общем маршруте,а второй присутствует
            while route(index_p2 - 1) ~= 1 %движемся "назад" по массиву общего маршрута, пока не встретим 1
               index_p2 = index_p2 - 1; 
            end
            start_ind = index_p2;
            while route(index_p2) ~=1 %теперь движемся "вперед", пока не встретим 1
                sub_route(i) = route(index_p2); %добавляем в подмаршрут пункты из общего маршрута
                index_p2 = index_p2 + 1;
                i = i + 1;
            end
            end_ind = index_p2 - 1;
        else %иначе, если второй пункт отсутствует в общем маршруте,а первый присутствует
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
        sub_route(sub_route == 0) = []; %убираем ненужные нули
    end
end

%находим подмаршрут в маршруте, заменяем его на новый и возвращаем общий
% маршрут
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

%находим подмаршрут в маршруте ТС, заменяем его на новый и возвращаем новый
%маршрут ТС
function [temp_route] = find_and_replace_subroute_in_vehicle(route, vehicle_station_index, ...
                            station_to_add)
    temp_route = zeros(1,length(route)+1);
    if(route(vehicle_station_index + 1) == 1)
        temp_route = [route(1:vehicle_station_index) station_to_add route(vehicle_station_index + 1:end)];
    else
        temp_route = [route(1:vehicle_station_index - 1) station_to_add route(vehicle_station_index:end)];
    end
end

%Получаем номер ТС
function [nvehicle,vehicle_station_index,vehicle_station_to_add] = get_No_vehicle(station1, station2, vehicles)
    dim = length(vehicles);
    vehicle_station_index = -1;
    vehicle_station_to_add = -1;
    %если пункт присутствует хотя бы в одном маршруте т.с.
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
    %ищем следующее ТС
    N_of_bases_in_routes = zeros(1,dim);
    for i = 1:dim
        route = vehicles(i).route;
        N_of_bases_in_routes(i) = length(find(route == 1));
    end
    [~,ind_min_el] = min(N_of_bases_in_routes);
    nvehicle = ind_min_el;
end

%добавляем новый подмаршрут в маршрут ТС
function [vehicles] = add_new_route_to_vehicle(vehicles, sub_route, nvehicle)
    route = create_new_subroute(vehicles(nvehicle).route, sub_route);
    vehicles(nvehicle).route = route;
end

%создаем новый подмаршрут в маршруте
function [route] = create_new_subroute(route, sub_route)
    temp_index = find(route == 1, 1, 'last');
    route(temp_index + 1) = sub_route(1);
    route(temp_index + 2) = sub_route(2);
    route(temp_index + 3) = 1;
end

%вычисляем протяженность всего маршрута
function [ length_of_path ] = length_of_route( vehicles, distances)
    length_of_path = 0;
    for k = 1:length(vehicles)
        route = fliplr(vehicles(k).route);
        for i = 1:length(route) - 1
            length_of_path = length_of_path + distances(route(i),route(i + 1)); 
        end
    end
end

%функция, определяющая, находится ли элемент в массиве
function [ logic ] = is_in_array( element, arr )
    for i = 1:length(arr)
        if element == arr(i)
            logic = true;
            return;
        end
    end
    logic = false;
end

%суммарный объем поставок по маршруту
function [ sum ] = sum_supplies_on_route( route, demands )
sum = 0;
    for i = 1:length(route)
       sum = sum + demands(route(i)); 
    end
end