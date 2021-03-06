
% Script to load data for PBC BHM
clc
clear

tot_num_jobs = 1;

% job_var_list = linspace(-10, 10, 21);
job_var_list = 0;
J = 0.1;
delta = 2*J;

file_prefix = 'two_site_spectrum_JCH_J_on_gamma_10_zoom_1_part_peak_';

start_job = 1;
end_job = tot_num_jobs;

numjobs = end_job - start_job + 1;

close all
figure_to_use = 20;
figure(figure_to_use)
hold on

numjobs_loaded = 0;

track_feature_freq_store = zeros(1, numjobs);

for loop = 1:numjobs
    
    job_to_load = start_job + loop - 1;
    
    file_name = [file_prefix num2str(job_to_load) '.mat'];
    data_loaded = 0;
    
    try
        
        disp(['Loading file ' file_name])
        data = load(file_name);
        data_loaded = 1;
        numjobs_loaded = numjobs_loaded + 1;
        
    catch me
        disp(['Error! File ' file_name ' not loaded!'])
    end
    
    if data_loaded == 1
            
                % Find the lowest-lying two-particle mode for this job:
                omega_d = 10000;    % A large cavity frequency to find the two-particle modes
                H = jch_hamiltonian_multi_site_pbc(2, 2, omega_d, omega_d - delta, 1, J, 0);
                [v,d] = eig(full(H));
            
                evs = diag(d);
            
                % One particle states:
                one_particle_state_indices = find((evs > 0.95*omega_d) & (evs < 1.05*omega_d));
                one_particle_state_frequencies = evs(one_particle_state_indices);
            
                % Two particle states:
                two_particle_state_indices = find((evs > 0.95*omega_d*2) & (evs < 1.05*omega_d*2));
                two_particle_state_frequencies = evs(two_particle_state_indices);
                delta_omega_d_track = omega_d - two_particle_state_frequencies(1)/2;   % Choose the lowest lying two particle mode to drive
                track_feature_freq_store(loop) = delta_omega_d_track;
            
            % Plotting:
                figure(figure_to_use)
            hold on
            plot(-data.var_list + 2*J, log10(real(data.g2_ss_store)),'g','LineWidth',2)
            plot(-data.var_list + 2*J, log10(real(data.num_1_store)),'b','LineWidth',2)
            plot(-data.var_list + 2*J, log10(real(data.ee_1_store)),'r','LineWidth',2)
            
            xlabel('(\Delta_c - 2 J) / g', 'FontSize', 14)
            ylabel('log_{10} NESS exp. vals.', 'FontSize', 14)
            
%             title(['\Delta / g = ' num2str(job_var_list(loop))], 'FontSize', 14)
            y_lim = ylim;
            
%             plot((-delta_omega_d_track + 2*J)*[1 1], y_lim)
        
            pause
            
    end
    
end

%%
ylim([-4 2])
x_lim = xlim;
plot(x_lim, 0*[1 1], 'k:')

set(gcf, 'Color', 'w')
set(gca, 'XTick', [-1.25 -1 -0.75])
set(gca, 'YTick', [-4:2])
export_fig 'two_site_spectrum_JCH_small_loss_small_hopping_zoom' '-pdf'