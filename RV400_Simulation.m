% RV400 Main Simulation
RV400_Parameters
RV400_DriveCycle

% Convert units
v_ref    = v_kmh / 3.6;
grad_rad = gradient_deg * (pi/180);

% Preallocate
speed_noAI  = zeros(size(t));
speed_AI    = zeros(size(t));
SOC_noAI    = zeros(size(t));
SOC_AI      = zeros(size(t));
SOC_noAI(1) = SOC_0;
SOC_AI(1)   = SOC_0;

% NO AI loop
for i = 2:length(t)
    v_error      = v_ref(i) - speed_noAI(i-1);
    V_ctrl       = max(0, min(V_sat, Kp * v_error));
    I_motor      = max(0, (V_ctrl - Ke * speed_noAI(i-1)) / Ra);
    F_drive      = (Kt * I_motor) / r_wheel;
    F_drag       = 0.5 * 1.225 * Cd * A * speed_noAI(i-1)^2;
    F_roll       = Cr * m * g * cos(grad_rad(i));
    F_grade      = m * g * sin(grad_rad(i));
    F_net        = F_drive - F_drag - F_roll - F_grade;
    speed_noAI(i)= max(0, speed_noAI(i-1) + (F_net/m)*dt);
    P_motor      = V_ctrl * I_motor;
    SOC_noAI(i)  = SOC_noAI(i-1) - (P_motor*dt)/(E_kwh*3.6e6);
end

% AI loop
for i = 2:length(t)
    soc  = SOC_AI(i-1);
    spd  = speed_AI(i-1) * 3.6;
    grad = gradient_deg(i);

    if soc > 0.9
        torque_factor = 1.0;
    elseif soc > 0.7 && spd < 40
        torque_factor = 0.82;
    elseif soc > 0.7 && spd >= 40
        torque_factor = 0.88;
    elseif soc <= 0.7 && grad > 3
        torque_factor = 0.72;
    elseif soc <= 0.7 && grad < -2
        torque_factor = 0.58;
    elseif soc <= 0.7
        torque_factor = 0.68;
    else
        torque_factor = 0.78;
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

    if v_ref(i) < speed_AI(i-1) && speed_AI(i-1) > 0.5
        P_regen    = min(0.72 * 0.5 * m * speed_AI(i-1)^2 / dt, 2000);
        P_motor    = max(0, V_ctrl * I_motor - P_regen);
    else
        P_motor    = V_ctrl * I_motor;
    end
    SOC_AI(i) = SOC_AI(i-1) - (P_motor*dt)/(E_kwh*3.6e6);
end

% Results
SOC_used_noAI = SOC_0 - min(SOC_noAI);
SOC_used_AI   = SOC_0 - min(SOC_AI);
range_noAI    = (SOC_used_noAI/1.0) * 150;
range_AI      = (SOC_used_AI/1.0)   * 150;
improvement   = ((range_AI - range_noAI)/range_noAI) * 100;

fprintf('Range without AI: %.1f km\n', range_noAI);
fprintf('Range with AI:    %.1f km\n', range_AI);
fprintf('Improvement:      %.1f%%\n',  improvement);