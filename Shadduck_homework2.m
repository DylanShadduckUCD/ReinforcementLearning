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

% Agressive policy
agressive_policy(starting_money, maximum_money, heads_prob)

% Conservative policy
conservative_policy(starting_money, maximum_money, heads_prob)

% Random policy
random_policy(starting_money, maximum_money, heads_prob)

%% Change Probability of Heads to 0.1
heads_prob = 0.1;

% Agressive policy
agressive_policy(starting_money, maximum_money, heads_prob)

% Conservative policy
conservative_policy(starting_money, maximum_money, heads_prob)

% Random policy
random_policy(starting_money, maximum_money, heads_prob)

%% functions
function agressive_policy(start_money, max_money, heads_probability)
    % This function takes a certain starting money and plays a game where
    % it bets all of its money on the outcome of a coin flip. The coin can
    % be unfair with a probability of heads set by the user. The game ends
    % when the player has no money or meets or exceeds the maximum amount
    % of money. This function will only output to the standard out the
    % result of the game
    fprintf("Agressive Policy\n------------------------\n")

    funds = start_money;
    times_bet = 0;

    % Given that this is a super aggresive policy, we should expect to win the
    % game right away 90 percent of the time or lose right away 10 percent of
    % the time. 

    while (0 < funds) && (funds < max_money)

        % Increment the number of times this game is played
        times_bet = times_bet + 1;

        % Choose how much money to bet
        bet = funds;

        % Flip the coin
        if rand(1) < heads_probability
            % Coin lands heads
            funds = funds + bet;
        else
            % Coin lands tails
            funds = funds - bet;
        end
    end

    fprintf("Times played: %d\n", times_bet)

    if funds >= max_money
        fprintf("Game won!\n\n")
    else
        fprintf("Game lost :(\n\n")
    end
end

function conservative_policy(start_money, max_money, heads_probability)
    % This function takes a certain starting money and plays a game where
    % it bets only $1 on the outcome of a coin flip. The coin can
    % be unfair with a probability of heads set by the user. The game ends
    % when the player has no money or meets or exceeds the maximum amount
    % of money. This function will only output to the standard out the
    % result of the game
    fprintf("Conservative Policy\n------------------------\n")

    funds = start_money;
    times_bet = 0;

    % Given that this is a super aggresive policy, we should expect to win the
    % game right away 90 percent of the time or lose right away 10 percent of
    % the time. 

    while (0 < funds) && (funds < max_money)

        % Increment the number of times this game is played
        times_bet = times_bet + 1;

        % Choose how much money to bet
        bet = 1;

        % Flip the coin
        if rand(1) < heads_probability
            % Coin lands heads
            funds = funds + bet;
        else
            % Coin lands tails
            funds = funds - bet;
        end
    end

    fprintf("Times played: %d\n", times_bet)

    if funds >= max_money
        fprintf("Game won!\n\n")
    else
        fprintf("Game lost :(\n\n")
    end
end

function random_policy(start_money, max_money, heads_probability)
    % This function takes a certain starting money and plays a game where
    % it bets only $1 on the outcome of a coin flip. The coin can
    % be unfair with a probability of heads set by the user. The game ends
    % when the player has no money or meets or exceeds the maximum amount
    % of money. This function will only output to the standard out the
    % result of the game
    fprintf("Random Policy\n------------------------\n")

    funds = start_money;
    times_bet = 0;

    % Given that this is a super aggresive policy, we should expect to win the
    % game right away 90 percent of the time or lose right away 10 percent of
    % the time. 

    while (0 < funds) && (funds < max_money)

        % Increment the number of times this game is played
        times_bet = times_bet + 1;

        % Choose how much money to bet
        bet = randi([1,funds], 1);

        % Flip the coin
        if rand(1) < heads_probability
            % Coin lands heads
            funds = funds + bet;
        else
            % Coin lands tails
            funds = funds - bet;
        end
    end

    fprintf("Times played: %d\n", times_bet)

    if funds >= max_money
        fprintf("Game won!\n\n")
    else
        fprintf("Game lost :(\n\n")
    end
end