% Dylan Shadduck
% EEC 289A
% Homework 6

clear
clc

%% Setting the Environment

% This environment will be a version of the random walk game. There are
% 1000 different states with the terminal states being 1 and 1000. The
% reward for each step taken is 0 except when the terminal states are
% reached. The state 1 gives a reward of -1 and the state 1000 gives a
% reward of 1. The step taken is available on a uniform distribution of all
% 100 states to the left or right of the current state. If there are not
% 100 states available in a direction, the probability of landing on the
% terminal state is increased. For example, if you are standing on the
% state 1 you have a probability of 0.5 of terminating on the left.

total_states = 1000;
V = zeros(1, total_states);

%% Policy Evaluation
threshold = 1e-5;
delta = 1;
epochs = 0;

while delta > threshold
    delta = 0;
    
    for s=1:1000
        v = V(s);
        new_v = 0;
        for step = 1:100
            % Check if we are at a terminal state
            if s + step > 1000
                v_prime_right = 0;
                v_prime_left = V(s-step);
                r_right = 1;
                r_left = 0;
            elseif s - step < 1
                v_prime_right = V(s+step);
                v_prime_left = 0;
                r_right = 0;
                r_left = -1;
            else
                r_right = 0;
                r_left = 0;
                v_prime_left = V(s-step);
                v_prime_right = V(s+step);
            end
            
            % Update our v function for this state and step
            new_v = new_v + (1/200)*(r_right + v_prime_right) + (1/200)*(r_left + v_prime_left);
            
        end
        % Update v function for this state
        V(s) = new_v;
        
        % Update delta
        delta = max(delta, abs(v - new_v));
    end
    epochs = epochs+1;
end



%% Semi Gradient TD(0)

% Initialize weights
% We will use the aggregate method where each weigth corresponds to 100
% states. w1 for states 1-100, w2 for states 101-200 and so on
w = zeros(1, 10);

% Initialize the step size
alpha = 2e-5;

total_episodes = 500000;
for episode=1:total_episodes
    
    s = 500;
    
    while true
        a = randi([-100, 100], 1);
        s_prime = s + a;
        
        v = w(ceil(s/100));
        % Check for terminal state
        if s_prime < 1
            r = -1;
            w(ceil(s/100)) = v + alpha*(r - v);
            break
        elseif s_prime > 1000
            r = 1;
            w(ceil(s/100)) = v + alpha*(r - v);
            break
        else
            w_prime = w(ceil(s_prime/100));
            w(ceil(s/100)) = v + alpha*(w_prime - v);
        end
        
        % Set s prime to s and get new action and s prime
        s = s_prime;
    end
 
end

%% Plot Policy Evaluation
figure(1)
hold on
plot(linspace(1, 1000, 1000), V, "r")
plot(linspace(1, 1000, 1000), repelem(w, 100), "b")
xlabel("State")
ylabel("Value")
legend("True Value v_{\pi}", "Semi-Gradient TD(0)", "Location", "NorthWest", "FontSize", 12)
title("Optimal State Value")