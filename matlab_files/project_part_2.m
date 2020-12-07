clear
clc

% Playing around with designing what a linear observer would look like if
% we had estimates for all of the states

run('quadrocopter_LQR.m')

C = eye(12);
ctrlr_poles = eig(A-B*K);

% From https://ecal.berkeley.edu/files/ce295/CH02-StateEstimation.pdf
% ". A general rule-of-thumb is that the observer eigenvalues should be 
% placed 2-10 times faster than the slowest stable eigenvalue of the energy
% system itself."
slowest_ctrlr_pole = max(real(ctrlr_poles));
obsv_poles = 2*ctrlr_poles;
L = place((A-B*K)',C', obsv_poles)';
% L_file = "/Users/tmcnama2/px4-19/Firmware/build/px4_sitl_default/tmp/rootfs/tgmL.txt";
% writematrix(L,L_file,'Delimiter','tab')

sensor_noise = 0.00001*ones(12,1);
obsv_ctrl_dynamics = @(t, x_ext) quadrotor_exact_pt2(t, x_ext, K, L, sensor_noise, A, B);

x0 = zeros(24,1);
% run2 values (run 1 was 15, 15 15)
px_init = -5; py_init = -5; pz_init = -5;
x0(2) = px_init;
x0(4) = py_init;
x0(6) = pz_init;
% x_hat values 
x0(14) = px_init;
x0(16) = py_init;
x0(18) = pz_init;

[t, x] = ode45(obsv_ctrl_dynamics, [0, 10], x0);


plot_pos = true;
plot_velocity = true;
plot_angle = true;
plot_angvel = true;
plot_input = false;
legend_labels = ["true state"; "estimated state"];
plot_quadrotor_model(x(:,13:24),t, [], x(:,1:12), t, [], plot_pos, plot_velocity, plot_angle, plot_angvel, plot_input, legend_labels)


