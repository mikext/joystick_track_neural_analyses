function [Px, Py, Vx, Vy] = Cal_Pxy_Vxy(sub)
%CAL_PXY_VXY Calculate (averaged) position and velocity of given subject
%   :param:
%       sub: char array, subject id

%   :return: 
%       Px: double vector, position on X axis
%       Py: double vector, position on Y axis
%       Vx: double vector, velocity on X axis
%       Vy: double vector, velocity on Y axis

    filepath = ['../data/raw/', sub, '_joystick.mat'];
    load(filepath, 'data', 'CursorPosX', 'CursorPosY');

    time_l = size(data, 1);
    n_points = floor(time_l / 167);
    
    % calculate running average of positions
    xpos_rec = CursorPosX;
    Px = zeros(n_points-1, 1);
    for ii = 1:n_points-1
        mid_t = ii * 167;
        start_t = mid_t - 166;
        end_t = mid_t + 166;
        Px(ii, 1) = mean(xpos_rec(start_t : end_t, :));
    end

    ypos_rec = CursorPosY;
    Py = zeros(n_points-1, 1);
    for ii = 1:n_points-1
        mid_t = ii * 167;
        start_t = mid_t - 166;
        end_t = mid_t + 166;
        Py(ii, 1) = mean(ypos_rec(start_t : end_t, :));
    end
    
    % calculate velocities
    time_span = 0.167; % 1000Hz, 167 points -> 0.167s

    Vx = zeros(n_points-1, 1);
    for ii = 2:n_points-1
        Vx(ii, 1) = (Px(ii, 1) - Px(ii - 1, 1)) / time_span;
    end
    Vx(1, 1) = Vx(2, 1);

    Vy = zeros(n_points-1, 1);
    for ii = 2:n_points-1
        Vy(ii, 1) = (Py(ii, 1) - Py(ii - 1, 1)) / time_span;
    end
    Vy(1, 1) = Vy(2, 1);

end

