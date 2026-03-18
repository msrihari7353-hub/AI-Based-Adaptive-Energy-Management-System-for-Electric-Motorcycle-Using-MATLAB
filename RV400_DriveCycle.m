% Bengaluru Drive Cycle Generator
RV400_Parameters
t = (0:dt:t_end)';

% Bengaluru city speed profile (km/h)
v_kmh = zeros(size(t));

% Segment 1 — Starting from signal, accelerate to 30
v_kmh(1:30)   = linspace(0, 30, 30);

% Segment 2 — Cruise at 30 (traffic jam zone)
v_kmh(31:120) = 30;

% Segment 3 — Red signal, brake to stop
v_kmh(121:150) = linspace(30, 0, 30);

% Segment 4 — Stopped at signal (90 sec Bengaluru signal)
v_kmh(151:240) = 0;

% Segment 5 — Accelerate to 50 (open road)
v_kmh(241:280) = linspace(0, 50, 40);

% Segment 6 — Cruise at 50
v_kmh(281:450) = 50;
% Road Gradient Profile (degrees)
gradient_deg = zeros(size(t));

% Flat road
gradient_deg(1:300)    =  0;

% Uphill — flyover climb
gradient_deg(301:400)  =  4;

% Downhill — other side of flyover  
gradient_deg(401:500)  = -3;

% Flat again
gradient_deg(501:800)  =  0;

% Slight uphill — typical Bengaluru undulating road
gradient_deg(801:1000) =  2;

% Flat to end
gradient_deg(1001:end) =  0;
% Segment 7 — Brake for speed breaker
v_kmh(451:480) = linspace(50, 10, 30);

% Segment 8 — Speed breaker crawl
v_kmh(481:510) = 10;

% Segment 9 — Accelerate again
v_kmh(511:560) = linspace(10, 45, 50);

% Repeat pattern for rest of journey
v_kmh(561:end) = 35;