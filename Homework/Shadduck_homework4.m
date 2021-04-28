% Dylan Shadduck
% 913902897
% EEC 289A Homework 4

clear
clc

%% Setting the Problem

% We need to construct an array to keep track of all possible states
% There are three important variables:
%   Dealer Card Showing (A-10)
%   Player hand sum (12-21)
%   If player has usable Ace (True, False)
%
% The total number of states here should be 200


%% Monte Carlo Stick Soft 17

% We consider each face card as the same value (10)
deck = repmat([11, linspace(2,9, 8), 10*ones(1,4)], [1,4]);

% The array P are all the possible states
% First index is Dealer value showing
% Second index is the player score
% Third index is if the player has a usable ace or not (assume 1 is false
% and 2 is true)
P = round(rand(10, 10, 2));

% Initialize the Q matrix that has two values for each state action pair
% Indicies are as follows
% First is dealer showing
% Second is user score
% Third is if player has a useable ace
% 4th is what action 2 for hit 1 for stick
% 5th is if we are looking at Q value or number of times this action has
% been taken
Q = zeros(10,10,2,2,2);

% Number of iterations
num_iterations = 5000000;

for i=1:num_iterations
    
    % Assume deck is infinite, so we won't remove cards from the deck as we
    % take them out
    % Set a state by dealing cards to the dealer and the player
    dealer_hand = [deck(randi([1 52], 1)), deck(randi([1,52], 1))];
    player_hand = [deck(randi([1 52], 1)), deck(randi([1,52], 1))];
    
    % Make sure player has at least a score of 12
    [player_score, usable_ace] = check_score(player_hand);
    
    while player_score < 12
        player_hand = [player_hand, deck(randi([1,52], 1))];
        
        % Check score again
        [player_score, usable_ace] = check_score(player_hand);
    end
    
    % Let's play an episode of black jack
    
    % Check policy of the player at this state (1 is hit 0 is stick)
    dealer_showing = dealer_hand(1);
    if dealer_showing > 10
        % This sets the Ace back to one for the array index that the dealer
        % is showing
        dealer_showing = 1;
    end
    
    % Random policy to start. This is key for Monte Carlo ES
    policy = round(rand(1));
    rand_hand_len = length(player_hand);
    rand_policy = policy;
    
    while policy > 0 && player_score < 21
        player_hand = [player_hand, deck(randi([1,52], 1))];
        
        % Check score again
        [player_score, usable_ace] = check_score(player_hand);
        
        if player_score > 21
            break
        end
        
        % Check policy again
        policy = P(dealer_showing, player_score - 11, usable_ace);
    end
    
    % Now that the player has taken their turn, the dealer must play
    % (Assume the dealer must hit on soft 17)
    [dealer_score, dealer_ace] = check_score(dealer_hand);
    
    while dealer_score < 17
        % Dealer hits unless their score is 17 or greater
        dealer_hand = [dealer_hand, deck(randi([1,52], 1))];
        
        % Check for new score
        [dealer_score, dealer_ace] = check_score(dealer_hand);
    end
    
    % Check for winner
    if player_score > 21
        % Player busts
        r = -1;
    elseif dealer_score > 21
        % Dealer busts
        r = 1;
    elseif player_score > dealer_score
        % Neither bust and player wins
        r = 1;
    elseif player_score < dealer_score
        % Neither bust and dealer wins
        r = -1;
    else
        % It's a tie
        r = 0;
    end
    
    % Update our Q function for each state that was played
    for k=2:length(player_hand)
        % update the hand with the new card
        hand = player_hand(1:k);
        
        [score, ace] = check_score(hand);
        if score >= 12 && score <= 21
            
            if length(hand) == rand_hand_len
                p = rand_policy + 1;
            else
                p = P(dealer_showing, score - 11, ace) + 1;
            end
            
            qn = Q(dealer_showing, score - 11, ace, p, 1);
            n = Q(dealer_showing, score - 11, ace, p, 2);

            if n == 0
                Q(dealer_showing, score - 11, ace, p, 1) = r;
            else
                Q(dealer_showing, score - 11, ace, p, 1) = qn + (1/n)*(r - qn);
            end

            % Update n
            Q(dealer_showing, score - 11, ace, p, 2) = n + 1;

            % Update our policy
            q_hit = Q(dealer_showing, score - 11, ace, 2, 1);
            q_stick = Q(dealer_showing, score - 11, ace, 1, 1);

            if q_stick > q_hit
                % Best policy is to stick
                P(dealer_showing, score - 11, ace) = 0;
            elseif q_stick < q_hit
                % Best policy is to hit
                P(dealer_showing, score - 11, ace) = 1;
            end
        end
    end
end

%% Figures Stick Soft 17
figure(1)
subplot(223)
pcolor(P(:,:,1)')
yticks([1:10])
yticklabels({'12','13','14','15','16','17','18','19','20','21'})
title("Optimal Policy: No Usable Ace")
xticklabels({'A','2','3','4','5','6','7','8','9','10'})
xlabel("Dealer Showing")
ylabel("Player Sum")

subplot(221)
pcolor(P(:,:,2)')
yticks([1:10])
yticklabels({'12','13','14','15','16','17','18','19','20','21'})
title("Optimal Policy: Usable Ace")
xlabel("Dealer Showing")
xticklabels({'A','2','3','4','5','6','7','8','9','10'})
ylabel("Player Sum")

% Plot Q for ideal policy for each case
V = zeros(10, 10, 2);
for dealer_showing = 1:10
    for score = 1:10
        for ace = 1:2
            p = P(dealer_showing, score, ace) + 1;
            V(dealer_showing, score, ace) = Q(dealer_showing, score, ace, p, 1);
        end
    end
end

subplot(224)
surf(V(:,:,1))
xticks([1:10])
xticklabels({'12','13','14','15','16','17','18','19','20','21'})
yticks([1:10])
yticklabels({'A','2','3','4','5','6','7','8','9','10'})
title("Optimal Policy Value: No Usable Ace")

subplot(222)
surf(V(:,:,2))
xticks([1:10])
xticklabels({'12','13','14','15','16','17','18','19','20','21'})
yticks([1:10])
yticklabels({'A','2','3','4','5','6','7','8','9','10'})
title("Optimal Policy Value: Usable Ace")

%% Monte Carlo Hit Soft 17

% Re initialize the Q and P matricies
Q = zeros(10,10,2,2,2);
P = round(rand(10, 10, 2));

% Run simulation
% Number of iterations
num_iterations = 5000000;

for i=1:num_iterations
    
    % Assume deck is infinite, so we won't remove cards from the deck as we
    % take them out
    % Set a state by dealing cards to the dealer and the player
    dealer_hand = [deck(randi([1 52], 1)), deck(randi([1,52], 1))];
    player_hand = [deck(randi([1 52], 1)), deck(randi([1,52], 1))];
    
    % Make sure player has at least a score of 12
    [player_score, usable_ace] = check_score(player_hand);
    
    while player_score < 12
        player_hand = [player_hand, deck(randi([1,52], 1))];
        
        % Check score again
        [player_score, usable_ace] = check_score(player_hand);
    end
    
    % Let's play an episode of black jack
    
    % Check policy of the player at this state (1 is hit 0 is stick)
    dealer_showing = dealer_hand(1);
    if dealer_showing > 10
        % This sets the Ace back to one for the array index that the dealer
        % is showing
        dealer_showing = 1;
    end
    
    % Random policy to start. This is key for Monte Carlo ES
    policy = round(rand(1));
    rand_hand_len = length(player_hand);
    rand_policy = policy;
    
    while policy > 0 && player_score < 21
        player_hand = [player_hand, deck(randi([1,52], 1))];
        
        % Check score again
        [player_score, usable_ace] = check_score(player_hand);
        
        if player_score > 21
            break
        end
        
        % Check policy again
        policy = P(dealer_showing, player_score - 11, usable_ace);
    end
    
    % Now that the player has taken their turn, the dealer must play
    % (Assume the dealer must hit on soft 17)
    [dealer_score, dealer_ace] = check_score(dealer_hand);
    
    while dealer_score < 18
        % Check for soft 17
        if dealer_score == 17 && dealer_ace == 1
            % On a hard 17 we stick, so I break out of the loop
            break
        end
        
        % Dealer hits unless their score is 17 or greater
        dealer_hand = [dealer_hand, deck(randi([1,52], 1))];
        
        % Check for new score
        [dealer_score, dealer_ace] = check_score(dealer_hand);
    end
    
    % Check for winner
    if player_score > 21
        % Player busts
        r = -1;
    elseif dealer_score > 21
        % Dealer busts
        r = 1;
    elseif player_score > dealer_score
        % Neither bust and player wins
        r = 1;
    elseif player_score < dealer_score
        % Neither bust and dealer wins
        r = -1;
    else
        % It's a tie
        r = 0;
    end
    
    % Update our Q function for each state that was played
    for k=2:length(player_hand)
        % update the hand with the new card
        hand = player_hand(1:k);
        
        [score, ace] = check_score(hand);
        if score >= 12 && score <= 21
            
            if length(hand) == rand_hand_len
                p = rand_policy + 1;
            else
                p = P(dealer_showing, score - 11, ace) + 1;
            end
            
            qn = Q(dealer_showing, score - 11, ace, p, 1);
            n = Q(dealer_showing, score - 11, ace, p, 2);

            if n == 0
                Q(dealer_showing, score - 11, ace, p, 1) = r;
            else
                Q(dealer_showing, score - 11, ace, p, 1) = qn + (1/n)*(r - qn);
            end

            % Update n
            Q(dealer_showing, score - 11, ace, p, 2) = n + 1;

            % Update our policy
            q_hit = Q(dealer_showing, score - 11, ace, 2, 1);
            q_stick = Q(dealer_showing, score - 11, ace, 1, 1);

            if q_stick > q_hit
                % Best policy is to stick
                P(dealer_showing, score - 11, ace) = 0;
            elseif q_stick < q_hit
                % Best policy is to hit
                P(dealer_showing, score - 11, ace) = 1;
            end
        end
    end
end

%% Figures Hit Soft 17
figure(2)
subplot(223)
pcolor(P(:,:,1)')
yticks([1:10])
yticklabels({'12','13','14','15','16','17','18','19','20','21'})
title("Optimal Policy: No Usable Ace")
xticklabels({'A','2','3','4','5','6','7','8','9','10'})
xlabel("Dealer Showing")
ylabel("Player Sum")

subplot(221)
pcolor(P(:,:,2)')
yticks([1:10])
yticklabels({'12','13','14','15','16','17','18','19','20','21'})
title("Optimal Policy: Usable Ace")
xlabel("Dealer Showing")
xticklabels({'A','2','3','4','5','6','7','8','9','10'})
ylabel("Player Sum")

% Plot Q for ideal policy for each case
V = zeros(10, 10, 2);
for dealer_showing = 1:10
    for score = 1:10
        for ace = 1:2
            p = P(dealer_showing, score, ace) + 1;
            V(dealer_showing, score, ace) = Q(dealer_showing, score, ace, p, 1);
        end
    end
end

subplot(224)
surf(V(:,:,1))
xticks([1:10])
xticklabels({'12','13','14','15','16','17','18','19','20','21'})
yticks([1:10])
yticklabels({'A','2','3','4','5','6','7','8','9','10'})
title("Optimal Policy Value: No Usable Ace")

subplot(222)
surf(V(:,:,2))
xticks([1:10])
xticklabels({'12','13','14','15','16','17','18','19','20','21'})
yticks([1:10])
yticklabels({'A','2','3','4','5','6','7','8','9','10'})
title("Optimal Policy Value: Usable Ace")
%% Functions

function [score, usable_ace] = check_score(player_hand)
    % This function will check for usable aces and apply them depending on
    % whether or not the player will bust or not
    
    score = sum(player_hand);
    
    while score > 21
        [ace, loc] = ismember(11, player_hand);
        
        if ace
            player_hand(loc) = 1;
        elseif score > 21
            score = sum(player_hand);
            break
        end
        
        score = sum(player_hand);
    end
    
    usable_ace = ismember(11, player_hand) + 1;
end