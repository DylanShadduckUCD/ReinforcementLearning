% Dylan Shadduck
% Homework 2
% EEC 289A Lai

clear
clc

%% Problem Definition

% We will start with $5. Each turn our algorithm will decide how much money
% to bet and a coin will be flipped. If the coin lands heads, we win the
% same amount of money as we bet. If the coin lands tails we lose the money
% that we bet to the bank. This game ends when we run out of money or our
% sum is $10 or greater.
%
% The coin we will use to start has a 90 percent chance of landing heads

starting_money = 5;
maximum_money = 10;
heads_prob = 0.9;

%% All Policy State transition matrix
agressive_vals_h = zeros(1,11);
conservative_vals_h = zeros(1, 11);
random_vals_h = zeros(1, 11);

for i=1:11
    state = i-1;
    agressive_vals_h(i) = agressive_policy(state, heads_prob);
    conservative_vals_h(i) = conservative_policy(state, heads_prob, 0);
    random_vals_h(i) = random_policy(state, heads_prob, 0);
end

% Now we set heads probability to 0.1
heads_prob = 0.1;

agressive_vals_t = zeros(1,11);
conservative_vals_t = zeros(1, 11);
random_vals_t = zeros(1, 11);

for i=1:11
    state = i-1;
    agressive_vals_t(i) = agressive_policy(state, heads_prob);
    conservative_vals_t(i) = conservative_policy(state, heads_prob, 0);
    random_vals_t(i) = random_policy(state, heads_prob, 0);
end

%% functions

% Try writing a recursive function that returns the state value
function value = agressive_policy(state, heads_prob)
    % This function takes a certain starting state and calculates the value
    % function for that state for a gambling game. In this game we will set
    % the max and minimum money to be 10 dollars and 0 dollars
    % respectively. Once the state reaches either of these extremes, the
    % game is over
    
    if state == 0
        value = 0;
    elseif state >= 10
        value = 0;
    else
        % If we win the bet our new state is the our initial state plus our
        % winnings. Since we are greedy our winnings are equal to 
        new_state = state + state;
        
        % If we lose our new state will always be zero
        value = heads_prob *(state + agressive_policy(new_state, ... 
                heads_prob)) + (1-heads_prob) * (-state + ...
                agressive_policy(0, heads_prob));
    end
end

function value = conservative_policy(state, heads_prob, depth)
    % This function takes a certain starting state and calculates the value
    % function for that state for a gambling game. In this game we will set
    % the max and minimum money to be 10 dollars and 0 dollars
    % respectively. Each time the game is played we only bet one dollar.
    % Once the state reaches either of these extremes, the
    % game is over. This function is called recursively, so it may take
    % some time to run and the output will be some estimate not an exact
    % answer
    
    % Increment depth
    depth = depth + 1;
    
    if state == 0
        value = 0;
    elseif state >= 10
        value = 0;
    elseif depth >= 25
        value = 0;
    else
        % New values if we win
        new_state_w = state + 1;
        r_w = 1;
        
        % New values if we lose
        new_state_l = state - 1;
        r_l = -1;
        
        value = heads_prob * (r_w + conservative_policy(new_state_w, ...
                heads_prob, depth)) + (1 - heads_prob) * (r_l + ...
                conservative_policy(new_state_l, heads_prob, depth));
    end
end

function value = random_policy(state, heads_prob, depth)
    % This function returns the expected value of a given policy for a
    % current state. The game that is being played is a betting game where
    % the user bets a random amount of money that is between 1 dollar and
    % the current amount of money the user has. 
    %
    % This function is being called recursively, so it will take some time
    % to run. For that reason I have set a depth parameter to tell the
    % function when to stop considering a choice
    
    % Increment the depth
    depth = depth + 1;
    
    if state == 0
        value = 0;
    elseif state >= 10
        value = 0;
    elseif depth >= 11
        value = 0;
    else
        for a = 1:state
            prob = 1/state;
            if a == 1
                value = prob*(heads_prob*(a + random_policy(state+a, ...
                        heads_prob, depth)) + (1-heads_prob)*(-a + ...
                        random_policy(state-a, heads_prob, depth)));
            else
                value = value + prob*(heads_prob*(a + random_policy(state+a, ...
                        heads_prob, depth)) + (1-heads_prob)*(-a + ...
                        random_policy(state-a, heads_prob, depth)));
            end
        end
    end
end