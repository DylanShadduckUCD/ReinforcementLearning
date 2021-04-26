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

% The array P are all the possible states
% First index is Dealer value showing
% Second index is the player score
% Third index is if the player has a usable ace or not (assume 1 is false
% and 2 is true)
P = round(rand(10, 10, 2));


%% Monte Carlo 

% We consider each face card as the same value (10)
deck = repmat([11, linspace(2,9, 8), 10*ones(1,4)], [1,4]);

while true
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
    
    policy = P(dealer_showing, player_score - 11, usable_ace);
    
    while policy > 0 && player_score <= 21
        player_hand = [player_hand, deck(randi([1,52], 1))];
        
        % Check score again
        [player_score, usable_ace] = check_score(player_hand);
        
        % Check policy again
        policy = P(dealer_showing, player_score - 11, usable_ace);
    end
    
    % Now that the player has taken their turn, the dealer must play
    % (Assume the dealer must hit on soft 17)
    
    break
end

test_hand = [2, 4, 9, 10];
[score, ace] = check_score(test_hand);
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