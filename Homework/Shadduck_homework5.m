% Dylan Shadduck
% EEC 289A Homework 5
% Spring 2021
clear
clc

%% Defining the Grid

% This game we are going to play involves our agent walking through a grid
% world with a cliff. The agent can move up, down, left, or right, but each
% step will incure a penalty of -1. If the agent walks off the cliff, they
% incure a penalty of -100 and must return to the start. We will play this
% game with three different agents using the SARSA, Q-Learning, and
% Expected SARSA methods

gridworld = zeros(4,12);
[cols, rows] = size(gridworld);

% Let's add in the penalty for each square
% Terminal states have a reward of 0
% The cliff has a reward of -100
% All other squares have a reward of -1
for column=1:cols
    for row=1:rows
        if column == 4 && row > 1 && row < 12
            gridworld(column, row) = -100;
        elseif column == 4 || column == 1 && row == 12
            gridworld(column, row) = 0;
        else
            gridworld(column, row) = -1;
        end
    end
end

% Apply all algorithms for a set number of episodes
episodes = 500;
trials = 50;
epsilon = 0.1;
alpha = 0.5;

%% SARSA Method

% 4 actions for up, down, left, and right
num_actions = 4;          

% Starting position in terms of rows and columns
start_position = [4, 1];

% Avg the sum of rewards per episode over several trials
avg_rewards = zeros(1, episodes);

for trial=1:trials
    % Keep track of rewards during the episodes
    sum_reward_per_episode = [];
    
    % Up = A1, Down = A2, Left = A3, Right = A4
    Q = zeros(cols, rows, num_actions);
    
    for episode=1:episodes
        
        % Keep track of rewards received for this episode
        episode_rewards = 0;

        % s represents the row and column of the starting position
        s = start_position;

        % First thing to do is take a step in a particular direction
        if rand(1) > epsilon
            % Take the optimal action for starting position
            [~, a] = max([Q(4, 1, 1), -inf, -inf, Q(4, 1, 4)]);
        else
            % Can only go right or up
            options = [1, 4];
            a = options(randi(2, 1));
        end

        % Update s to find the reward for taking this action
        s_prime = new_state(s, a);

        % Now that we have taken an action, we claim our reward
        r = gridworld(s_prime(1), s_prime(2));
        episode_rewards = episode_rewards + r;

        % Find the next action using e-greedy policy
        a_prime = get_action(Q, s_prime, epsilon, false);

        % Update our Q function
        q = Q(s(1), s(2), a);
        q_prime = Q(s_prime(1), s_prime(2), a_prime);
        Q(s(1), s(2), a) = q + alpha * (r + q_prime - q);

        % Now we play this episode until we reach the terminal state
        while true
            % Old state and action are the set to the current state and action
            % Unless we fall off the cliff
            if r == -100
                s = start_position;
                a = get_action(Q, s, epsilon, false);
            else
                s = s_prime;
                a = a_prime;
            end

            % Find new s prime from the current state action pair
            s_prime = new_state(s, a);

            % Find the corresponding reward for this action
            r = gridworld(s_prime(1), s_prime(2));
            episode_rewards = episode_rewards + r;

            % Find the next action from our next state
            if r == -100
                a_prime = get_action(Q, start_position, epsilon, false);
            else
                a_prime = get_action(Q, s_prime, epsilon, false);
            end

            % Update our Q function
            q = Q(s(1), s(2), a);
            q_prime = Q(s_prime(1), s_prime(2), a_prime);
            Q(s(1), s(2), a) = q + alpha * (r + q_prime - q);

            % Check for break condition
            if s_prime(1) == 4 && s_prime(2) == 12
                % Update our Q function for the terminal state
                q = Q(s(1), s(2), a);
                q_prime = 0;
                Q(s(1), s(2), a) = q + alpha * (r + q_prime - q);
                break
            else
                % Update our Q function for non terminal state
                q = Q(s(1), s(2), a);
                q_prime = Q(s_prime(1), s_prime(2), a_prime);
                Q(s(1), s(2), a) = q + alpha * (r + q_prime - q);
            end
        end

        % Update our avg episode rewards
        sum_reward_per_episode = [sum_reward_per_episode, episode_rewards];
    end
    avg_rewards = avg_rewards + sum_reward_per_episode;
end

% Average our avg rewards
avg_rewards = avg_rewards./trials;
%% Plotting
figure(1)
plot(linspace(1, episodes, episodes), medfilt1(avg_rewards, 10))
title("SARSA Sum of rewards per episode")
xlabel("Episode")
ylabel("Sum of rewards")
ylim([-100, -15])
%% Functions
function state_prime = new_state(state, action)
    % This function takes a current state and a given action and returns a
    % vector representing the new state given that action
    
    % Update s to find the reward for taking this action
    state_prime = state;
    switch action
        case 1
            % Moving up
            state_prime(1) = state(1) - 1;
        case 2
            % Moving down
            state_prime(1) = state(1) + 1;
        case 3
            % Moving left
            state_prime(2) = state(2) - 1;
        case 4
            % Moving right
            state_prime(2) = state(2) + 1;
    end
end

function action = get_action(Q_function, state, epsilon, verbose)
    % This function takes a given Q_function and state and returns the
    % appropriate action for the grid world game. We assume that we can't
    % take an action that would take us off the grid. 
    
    % State should be an array with two values. The first represents the
    % column of the grid and the second represents the row
    % Q_function should be the q function for all the possible state and
    % action pairs. This game has 4 possible actions.
    col = state(2);
    row = state(1);
    
    Q = Q_function(row, col, :);
    
    if col + 1 > 12
        % Make sure we can't go right
        Q(4) = -inf;
    end
    if col - 1 < 1
        % Make sure we can't go left
        Q(3) = -inf;
    end
    if row + 1 > 4
        % Make sure we can't go down
        Q(2) = -inf;
    end
    if row - 1 < 1
        % Make sure we can't go up
        Q(1) = -inf;
    end
    
    % Find the optimal action
    if rand(1) > epsilon
        [~, action] = max(Q);
    else
        choices = find(Q ~= -inf);
        index = randi(length(choices));
        action = choices(index);
        
    end
    
    if verbose
        fprintf("Action = %d \n", action)
        fprintf("State: [%d, ", state(1))
        fprintf("%d]\n", state(2))
        fprintf("Choice vector: [")
        fprintf("%.1f, ", Q(1:3))
        fprintf("%1.f]\n", Q(4))
    end
end