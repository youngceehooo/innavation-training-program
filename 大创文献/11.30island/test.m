for a = 1:36
% b( 2*a - 1 ) = shipweight_path_xx(a);
% b( 2*a ) = shipweight_path_xx(a);
% c( 2*a - 1 ) = islandweight_path_xx(a);
% c( 2*a ) = islandweight_path_xx(a);
% b = value(b);
% c = value(c);
pload_path_22_year = xlsread('data','load_80','A1:A36');        %年物流调度下的海岛燃油消耗量????
b( 2*a - 1 ) = pload_path_22_year(a);
b( 2*a ) = pload_path_22_year(a);
end

% path(9,:) = value(pv_path_xx);

