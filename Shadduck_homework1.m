% Dylan Shadduck
% EEC 289A Homework 1
% Spring Quarter 2021

clear 
clc

% Setting the seed for more consistent results
rng(10)
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
true_values = normrnd(mu, sigma, 1, k);

% We will run this model for 1000 steps
num_runs = 1000;

% Create a variable to keep track of total rewards
reward_tot = 0;

% Initialize an array to keep track of our estimated average reward for
% each of the unique actions
% 
% First row is the true value estimate
% Second row is the number of times the estimate is chosen
q_estimates = zeros(2, k);

% Avg reward
r_avg = zeros(1, num_runs);

% Incorperate our epsilon
e = 0.1;

for step=1:num_runs
    
    if step == 1
        % Need to make a random choice for the first run
        choice = randi(k);
    elseif rand(1) <= e
        choice = randi(k);
    else
        [~, choice] = max(q_estimates(1, :));
    end
    
    % Find the true value of our choice
    mu_c = true_values(choice);
    
    % Find the reward corresponding to our choice and update our q estimate
    r = normrnd(mu_c, 1);
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

figure(1)
plot(linspace(1,1000, 1000), r_avg)
xlabel("Step")
ylabel("Avg Reward")