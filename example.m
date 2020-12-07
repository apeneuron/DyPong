%% Setting Hyperparameter
% MAX: The training epochs
% predf: The difficulty level within range of [0,1].
% thrMAX: The uncertainty level by additive random angle after reflection.
% it: frame counter

MAX = 1E5;
predf = 0.1;
thrMAX = 10;
it = 0;

%% Setting RL Agent
% In here, I will set a random agent.

agt = 'RANDOM';

%% Setting RL Environment
% The parameters class "pongboard" inputs are following.
% thrMAX: The uncertainty level
% predf: The difficulty level from 0 (hardest) to 1 (easiest)
% 1: The sample index for distinguishing repetitive experiments
% "EXAMPLE": The string in the command window for visualizing the progress

env = pongboard(thrMAX,predf,1,"EXAMPLE");

%% Training Loop
% At each frame, the environment conducts the following procedures.
% 1. Move the ball based on its current coordinate and velocity vector.
% 2. Receive the action the agent decide.
% 3. Move the pad based on the choice a agent made.

while it<MAX
    it = it+1;
    [P,Vb,PAD] = env.goball();
    
    if (agt=='RANDOM')
        action = randi([-1 1]);
    end
    
    % The vector "info" contains the following.
    % 1st element: Whether the agent encounters the approaching ball.
    % -1 for "miss a ball", 0 for "no", and 1 for "successful return".
    % 2nd element: The vertical coordinate the agent faces the ball.
    % 3rd element: The logical flag indicates that the entire match is over.
    
    info = env.gopad(action);
end

%% Result - Scoreboard
% The matrix "scoreboard" contains the entire results of individual 
% matches during the training. Each row is a vector consists of 3 numbers,
% the sample index, timestamp, and the final score. The final score is the
% subtraction of the score of opponent from the score of agent.

scoreboard = env.board;
