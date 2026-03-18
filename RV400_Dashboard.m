% RV400 Parametric Dashboard
RV400_Parameters
RV400_DriveCycle

fig = figure('Name', 'RV400 Digital Twin Dashboard', ...
             'Position', [100 100 800 600]);

uicontrol('Style', 'text', 'Position', [20 550 250 30], ...
          'String', 'RV400 Digital Twin Dashboard', ...
          'FontSize', 12, 'FontWeight', 'bold')

uicontrol('Style', 'text', 'Position', [20 510 150 20], ...
          'String', 'Motor Power (W)')
sl_motor = uicontrol('Style', 'slider', 'Position', [20 490 200 20], ...
          'Min', 1000, 'Max', 10000, 'Value', 3000);

uicontrol('Style', 'text', 'Position', [20 450 150 20], ...
          'String', 'Battery Capacity (Ah)')
sl_battery = uicontrol('Style', 'slider', 'Position', [20 430 200 20], ...
          'Min', 20, 'Max', 100, 'Value', 45);

uicontrol('Style', 'text', 'Position', [20 390 150 20], ...
          'String', 'Vehicle Mass (kg)')
sl_mass = uicontrol('Style', 'slider', 'Position', [20 370 200 20], ...
          'Min', 100, 'Max', 300, 'Value', 183);

uicontrol('Style', 'pushbutton', 'Position', [20 310 200 40], ...
          'String', 'RUN SIMULATION', ...
          'FontSize', 11, 'FontWeight', 'bold', ...
          'Callback', @(~,~) runSimulation(sl_motor, sl_battery, sl_mass));

function runSimulation(sl_motor, sl_battery, sl_mass)
    RV400_Parameters
    RV400_DriveCycle

    battery_ah  = sl_battery.Value;
    mass_kg     = sl_mass.Value;

    E_kwh  = (72 * battery_ah) / 1000;
    m      = mass_kg;

    v_ref    = v_kmh / 3.6;
    grad_rad = gradient_deg * (pi/180);

    SOC_AI   = zeros(size(t));
    speed_AI = zeros(size(t));
    SOC_AI(1)= SOC_0;

    for i = 2:length(t)
        soc = SOC_AI(i-1);
        spd = speed_AI(i-1) * 3.6;

        if soc > 0.9
            torque_factor = 1.0;
        elseif soc > 0.7 && spd < 40
            torque_factor = 0.82;
        else
            torque_factor = 0.75;
        end

        v_error     = v_ref(i) - speed_AI(i-1);
        V_ctrl      = max(0, min(V_sat * torque_factor, Kp * v_error * torque_factor));
        I_motor     = max(0, (V_ctrl - Ke * speed_AI(i-1) * torque_factor) / Ra);
        F_drive     = (Kt * I_motor * torque_factor) / r_wheel;
        F_drag      = 0.5 * 1.225 * Cd * A * speed_AI(i-1)^2;
        F_roll      = Cr * m * g * cos(grad_rad(i));
        F_grade     = m * g * sin(grad_rad(i));
        F_net       = F_drive - F_drag - F_roll - F_grade;
        speed_AI(i) = max(0, speed_AI(i-1) + (F_net/m)*dt);
        P_motor     = V_ctrl * I_motor;
        SOC_AI(i)   = SOC_AI(i-1) - (P_motor*dt)/(E_kwh*3.6e6);
    end

    range_est = (1 - min(SOC_AI)) * 150 * (battery_ah/45);
    fprintf('Battery: %.0fAh | Mass: %.0fkg | Range: %.1f km\n', ...
             battery_ah, mass_kg, range_est)
end