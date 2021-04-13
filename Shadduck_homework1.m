% Dylan Shadduck
% EEC 289A Homework 1
% Spring Quarter 2021

clear 
clc

%% Generating 10-armed-Testbed

% There are 10 possible actions that can be taken.
% Each action has a true value that is randomly chosen from a normal
% distribution with a mean of zero and a variance of 1
%
% Each of these actions then has an associated reward that follows a normal
% distribution with a mean of the true value and a variance of 1

k = 10;
mu = 0;
sigma = 1;
e = 0.1;
c = 2;
num_runs = 1000;

% Total average rewards for all 2000 runs
r_tot_eg = zeros(1, num_runs);
r_tot_ucb = zeros(1, num_runs);

% Calculating the 10-armed testbed 2000 times
h = waitbar(0, "Training Models...");

for trial = 1:2000
    
    % Update our progress bar
    waitbar(trial/2000, h);
    
    true_values = normrnd(mu, sigma, 1, k);

    % Estimate the average reward across each step for epsilon greedy
    r_avg_trial = e_greedy(e, true_values, num_runs, sigma);
    
    % Estimate average reward for ucb
    r_avg_ucb_t = ucb(c, true_values, num_runs, sigma);
    
    % increment the total rewards
    r_tot_eg = r_tot_eg + r_avg_trial;
    r_tot_ucb = r_tot_ucb + r_avg_ucb_t;
end

% Find average reward across all 2000 runs
r_avg_eg = r_tot_eg/2000;
r_avg_ucb = r_tot_ucb/2000;

%% Plotting

figure(1)
hold on
plot(linspace(1,1000, 1000), r_avg_eg)
plot(linspace(1,1000, 1000), r_avg_ucb)
xlabel("Step")
ylabel("Avg Reward")
title("10-Armed Testbed Over 1000 steps (Avg for 2000 iterations)")
legend("\epsilon-greedy \epsilon = 0.1", "UCB c = 2", "Location", "NorthWest")
hold off

%% Functions

function r_avg_ucb = ucb(c, true_values, num_trials, variance)
    % Re-initialize the q_estimates array
    k = length(true_values);
    q_estimates = zeros(2, k);

    % Total reward
    r_tot = 0;

    % Avg reward
    r_avg_ucb = zeros(1, num_trials);


    for step=1:num_trials

        if step == 1
            choice = randi(k);
        else
            qt = q_estimates(1, :);
            nt = q_estimates(2, :);
            ucb = qt + c*sqrt(log(step)./nt);
            [~, choice] = max(ucb);
        end

        % Find the true value of our choice
        mu_c = true_values(choice);

        % Find the reward for our given choice
        r = normrnd(mu_c, variance);
        qn = q_estimates(1, choice);

        if q_estimates(2, choice) == 0
            q_estimates(1, choice) = r;
        else
            q_estimates(1, choice) = qn + (1/q_estimates(2, choice)) * (r - qn);
        end

        % Increment the number of times this action has been chosen
        q_estimates(2, choice) = q_estimates(2, choice) + 1;

        % Increment the rewards
        r_tot = r_tot + r;
        r_avg_ucb(step) = r_tot/step;

    end
end

function r_avg = e_greedy(epsilon, true_values, num_trials, variance)
    % This function implements the epsilon greedy reinforcement model
    % specifically for the 10-armed testbed problem proposed in chapter 2
    % of the Sutton reinforcement learning textbook.
    % The output of this function is the average reward array for each step
    % in the number of steps specified by the num_trials variable

    % Create a variable to keep track of total rewards
    reward_tot = 0;

    % Initialize an array to keep track of our estimated average reward for
    % each of the unique actions
    % 
    % First row is the true value estimate
    % Second row is the number of times the estimate is chosen]
    k = length(true_values);
    q_estimates = zeros(2, k);

    % Avg reward
    r_avg = zeros(1, num_trials);

    for step=1:num_trials

        if step == 1
            % Need to make a random choice for the first run
            choice = randi(k);
        elseif rand(1) <= epsilon
            choice = randi(k);
        else
            [~, choice] = max(q_estimates(1, :));
        end

        % Find the true value of our choice
        mu_c = true_values(choice);

        % Find the reward corresponding to our choice and update our q estimate
        r = normrnd(mu_c, variance);
        qn = q_estimates(1, choice);

        if q_estimates(2, choice) == 0
            q_estimates(1, choice) = r;
        else
            q_estimates(1, choice) = qn + (1/q_estimates(2, choice)) * (r - qn);
        end

        % Increment the number of times this action has been chosen
        q_estimates(2, choice) = q_estimates(2, choice) + 1;

        % Increment the total 
        reward_tot = reward_tot + r;

        % Append to the average
        r_avg(step) = reward_tot/step;
    end
end