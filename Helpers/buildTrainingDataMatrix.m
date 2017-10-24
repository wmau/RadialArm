function [trainingData,trainingResponses,testDataTrials,errorTrials,pairID] = ...
    buildTrainingDataMatrix(events,spikes,armID,varargin)
%
%
%
%%
    %Uncomment this line if you want to exlude interneurons. 
%     nSpikes = cellfun('length',spikes);
%     interneurons = nSpikes > 20000;
    interneurons = zeros(length(spikes),1); 
    
    p = inputParser;
    p.addRequired('events',@(x) iscell(x)); 
    p.addRequired('spikes',@(x) iscell(x)); 
    p.addRequired('armID',@(x) isnumeric(x)); 
    p.addParameter('neurons',find(~interneurons),@(x) isnumeric(x)); 
    p.addParameter('pTrainingTrials',0.5,@(x) isnumeric(x));
    p.addParameter('useDecisionEpoch',false,@(x) islogical(x)); 
    p.addParameter('tMinusEvent',2,@(x) isnumeric(x)); 
    
    p.parse(events,spikes,armID,varargin{:});
    neurons = p.Results.neurons; 
        if size(neurons,1) > size(neurons,2), neurons = neurons'; end; 
    pTrainingTrials = p.Results.pTrainingTrials; 
    useDecisionEpoch = p.Results.useDecisionEpoch;
    tMinusEvent = p.Results.tMinusEvent;

%%
    %Get basic variables. 
    start = events{9}; stop = events{10};
    
    %If using decision point, instead taking the tMinusEvent seconds before
    %entering the arm instead. 
    if useDecisionEpoch
        stop = start; 
        start = start - tMinusEvent;
    end
    
    nNeurons = length(neurons);
    nTrials = size(start,1);    
    goodArms = [1 3 6 8 10 11]; 
    pairID = getPairIdentity(armID);
    
    %Check that trial start and end are the same length. 
    assert(nTrials==size(stop,1),...
        'Trials in event start and event end do not match!');
    
    %Get correct/incorrect trials. 
    correct = judgeTrials(armID); 
    correctTrials = find(correct)';          %Trial numbers.
    errorTrials = find(~correct)'; 
    
    %Pick out trials for training data. As default, we want half of the
    %trials for each arm. 
    trainingDataTrials = [];
    for arm = goodArms
        %Get trials where rat was on this arm. 
        theseTrials = (ismember(armID,arm) & correct)';
        nTrialsOnThisArm = sum(theseTrials);
        
        %Randomly sample a subset of trials for each arm. 
        trainingDataTrials = [trainingDataTrials, ...
            randsample(find(theseTrials),ceil(nTrialsOnThisArm*pTrainingTrials))];
    end
    nTestDataTrials = length(trainingDataTrials); 
    
    %Get test data trials, the correct trials that weren't included in
    %training data.
    testDataTrials = setdiff(correctTrials,trainingDataTrials);
    
%%
    %Preallocate then build training data matrix. 
    trainingData = zeros(nTestDataTrials,nNeurons); 
    
    %For each trial, get number of spikes in between the two event
    %timestamps then divide by time. 
    t = 1;
    for trial = trainingDataTrials
        timeSpentOnArm = stop(trial) - start(trial); 
        trainingData(t,:) = ...
            cellfun(@(x) sum(x > start(trial) & x < stop(trial)),...
            spikes(neurons))./timeSpentOnArm;
    
        t = t+1; 
    end
    
    %Eliminate cells that didn't fire on the arm. 
%     didNotFire = find(sum(trainingData)==0); 
%     trainingData(:,didNotFire) = []; 
%     neurons(didNotFire) = [];
    
    %Response variable. 
    trainingResponses = pairID(trainingDataTrials); 
    

end
        