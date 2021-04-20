% Dylan Shadduck
% EEC 289A Spring 2021
% Homework 3

clear
clc

% Same problem as homework 2. We are gambling our money with several
% different policies. The first policy is the greedy policy in which the
% the user will gamble all of their money each time. The second is the
% conservative policy. Here the user always bets only 1 dollar. The last
% policy is the random one. In this policy the user bets a random integer
% amount of money between 1 dollar and the total money the user has in a
% uniform distribution. The reward seen each time the game is played is the
% amount of money earned or lost (positive or negative reward). The game
% ends when the user has no money or has 10 dollars or more. 

%% Policy iteration

% Probability of heads
hp = 0.9;

% Set a convergence threshold for our delta value
convergence_threshold = 1e-4;

% Initialize a random policy matrix
P = zeros(1,9);
for s=1:9
    P(s) = randi(s);
end

% Let's keep track of how many times we perform policy iteration
k = 0;

while true
    % This loop should only exit when our policy converges to the optimal
    % policy
    
    % Increment k
    k = k + 1;
    
    % Initialize the policy evaluation matrix
    V = zeros(1, 11);
    
    % Reset delta so we can enter the while loop again
    delta = 1;
    
    while delta > convergence_threshold
        % Policy evaluation
        delta = 0;
        for s=1:9
            v = V(s+1);
            r = P(s);
            
            if s+r >= 10
                eval = 0;
            else
                eval = V(s+1+r);
            end
            
            V(s+1) = hp*(r + eval) + (1-hp)*(-r + V(s+1-r));
            delta = max([delta abs(v - V(s+1))]);
        end
    end

    % We want to save the current state of our policy
      pi = P;
    
    for s=1:9
        % Check each possible policy and see if it is better than our
        % current policy
        
        % Create a temp array for all possible policy evaluations
        temp = zeros(1, s);
        
        for j=1:s
        
            if j+s >= 10
                Vj = hp*(j + 0) + (1-hp)*(-j + V(s+1-j));
            else
                Vj = hp*(j + V(s+1+j)) + (1-hp)*(-j + V(s+1-j));
            end
            
            temp(j) = Vj;
        end
        % Check if this new policy returns a greater value than
        % previous
        
        [~, new_p] = max(temp);
        
        % If best policy is different than the current policy, update our
        % policy array
        P(s) = new_p;
    end
    
    % Check if our policy array has changed
    if isequal(pi, P)
        % If our policy has not changed, we have 
        break
    end
end

fprintf("Policy converged to optimal policy after %d iterations\n", k)

%% Value Iteration

% Set the heads probability to 0.1
hp = 0.1;

% Initialize the value function and policy
V = zeros(1, 11);
P = zeros(1,9);

% Initialize delta so we can enter our while loop
delta = 1;

while delta > convergence_threshold
   % Set delta back to zero
   delta = 0;
   
   % Check each possible action for each state
   for s=1:9
       v = V(s+1);
       % We will store all the possible values in this temp variable
       temp = zeros(1, s);
       
       for r=1:s
           if r+s+1 >= 10
               temp(r) = hp*(r + 0) + (1-hp)*(-r + V(s+1-r));
           else
               temp(r) = hp*(r + V(s+1+r)) + (1-hp)*(-r + V(s+1-r));
           end
       end
       
       % Find the maximum value and set that as our value for this
       % state
       [V(s+1), new_p] = max(temp);
       
       % Update policy
       P(s) = new_p;
       
       % Update delta
       delta = max([delta, abs(v-V(s+1))]);
   end
end