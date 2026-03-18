% RV400 3D Visualization
RV400_Parameters
RV400_DriveCycle
RV400_Simulation

fig = figure('Name', 'RV400 Digital Twin', 'Position', [50 50 1400 700], 'Color', 'black');

ax1 = axes('Position', [0.02 0.25 0.65 0.70], 'Color', [0.1 0.1 0.1]);
hold on; grid on; axis off
xlim([0 200]); ylim([-10 30])

% Road
fill([0 200 200 0], [-6 -6 0 0], [0.3 0.3 0.3])
plot([0 200], [0 0],   'w-', 'LineWidth', 2)
plot([0 200], [-6 -6], 'w-', 'LineWidth', 2)
for x = 0:20:200
    plot([x x+10], [-3 -3], 'y--', 'LineWidth', 1.5)
end

% Bike parts
wheel_r   = rectangle('Position', [-3 -0.5 5 5],   'Curvature', [1 1], 'FaceColor', [0.15 0.15 0.15], 'EdgeColor', [0.8 0.8 0.8], 'LineWidth', 2.5);
wheel_f   = rectangle('Position', [8 -0.5 5 5],    'Curvature', [1 1], 'FaceColor', [0.15 0.15 0.15], 'EdgeColor', [0.8 0.8 0.8], 'LineWidth', 2.5);
body      = fill([0 12 11 9 3 -1], [2 2 5 7 7 5],  [0.9 0.1 0.1]);
tank      = fill([3 9 8 4],        [5 5 7 7],       [0.7 0.0 0.0]);
handle    = plot([9 11 12],        [7 8 7],         'w-', 'LineWidth', 3);
exhaust   = fill([-2 1 1 -2],      [1 1 2 2],       [0.6 0.6 0.6]);
rider     = fill([4 8 7 5],        [7 7 12 12],     [0.1 0.1 0.1]);
helmet    = rectangle('Position',  [4.5 12 3 2.5],  'Curvature', [1 1], 'FaceColor', [0.9 0.1 0.1], 'EdgeColor', 'w');
headlight = rectangle('Position',  [11 3 1.5 1.5],  'Curvature', [1 1], 'FaceColor', [1 1 0.5],     'EdgeColor', [1 1 0]);

% Dashboard
ax2 = axes('Position', [0.70 0.25 0.28 0.70], 'Color', 'black');
axis off

% SOC bar
ax3 = axes('Position', [0.02 0.05 0.65 0.12], 'Color', 'black');

% Animation loop
distance = 0;

for i = 1:5:length(t)
    spd    = speed_AI(i) * 3.6;
    soc    = SOC_AI(i) * 100;
    distance = distance + speed_AI(i) * 5 * dt;
    x_bike = mod(distance/5, 150) + 10;
    road_h = tan(gradient_deg(i) * pi/180) * 5;

    % Move bike parts
    axes(ax1)
    set(body,     'XData', x_bike+[0 12 11 9 3 -1], 'YData', road_h+[2 2 5 7 7 5])
    set(tank,     'XData', x_bike+[3 9 8 4],         'YData', road_h+[5 5 7 7])
    set(handle,   'XData', x_bike+[9 11 12],         'YData', road_h+[7 8 7])
    set(exhaust,  'XData', x_bike+[-2 1 1 -2],       'YData', road_h+[1 1 2 2])
    set(rider,    'XData', x_bike+[4 8 7 5],         'YData', road_h+[7 7 12 12])
    helmet.Position    = [x_bike+4.5  road_h+12  3    2.5];
    headlight.Position = [x_bike+11   road_h+3   1.5  1.5];
    wheel_r.Position   = [x_bike-3    road_h-0.5 5    5];
    wheel_f.Position   = [x_bike+8    road_h-0.5 5    5];

    % Speed lines when fast
    if spd > 40
        plot(ax1, [x_bike-15 x_bike-5], [road_h+3 road_h+3], 'c-', 'LineWidth', 1)
        plot(ax1, [x_bike-15 x_bike-5], [road_h+5 road_h+5], 'c-', 'LineWidth', 1)
    end

    % Dashboard
    axes(ax2); cla; axis off
    set(ax2, 'Color', 'black')
    text(0.05, 0.95, 'RV400 DIGITAL TWIN',          'Color', 'cyan',    'FontSize', 12, 'FontWeight', 'bold')
    text(0.05, 0.80, 'SPEED',                        'Color', 'white',   'FontSize', 10)
    text(0.05, 0.70, sprintf('%.1f km/h', spd),      'Color', 'yellow',  'FontSize', 20, 'FontWeight', 'bold')
    text(0.05, 0.55, 'BATTERY',                      'Color', 'white',   'FontSize', 10)
    text(0.05, 0.45, sprintf('%.1f%%', soc),         'Color', [0 1 0],   'FontSize', 20, 'FontWeight', 'bold')
    text(0.05, 0.30, 'RANGE LEFT',                   'Color', 'white',   'FontSize', 10)
    text(0.05, 0.20, sprintf('%.1f km', SOC_AI(i)*119), 'Color', [1 0.5 0], 'FontSize', 20, 'FontWeight', 'bold')
    text(0.05, 0.08, sprintf('GRADIENT: %.1f deg', gradient_deg(i)), 'Color', 'white', 'FontSize', 9)

    % SOC bar
    axes(ax3); cla
    set(ax3, 'Color', 'black')
    if soc > 50
        bar_color = [0 0.8 0];
    elseif soc > 25
        bar_color = [1 0.6 0];
    else
        bar_color = [1 0 0];
    end
    barh(soc, 'FaceColor', bar_color)
    xlim([0 100]); axis off
    text(2, 1, sprintf('BATTERY: %.1f%%', soc), 'Color', 'white', 'FontSize', 10, 'FontWeight', 'bold')

    drawnow
end