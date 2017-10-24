clear; 
clc; 

cd('U:\Sheehan radial arm project'); 
files = ls('*FINAL.mat'); 

B = 50;

nSessions = size(files,1); 
[accuracy,errorAccuracy] = deal(nan(nSessions,1)); 
allSessionShuffleAccuracy = [];
for session = 1:nSessions
    load(files(session,:),'events','spikes','armIDtrial');
    
    %Get training and test data for correct and error trials. 
    [trainingData,trainingResponses,testDataTrials,errorTrials,pairID] = ...
        buildTrainingDataMatrix(events,spikes,armIDtrial);
        
    %Train the classifier.  
    Mdl = fitcnb(trainingData,trainingResponses,'distributionnames','kernel');
    
    % Get the rest of the correct trials that weren't used to train classifier. 
    [testData,testResponses] = buildTestDataMatrix(events,spikes,...
        pairID,testDataTrials);
    
    %Get the error trials. 
    [errorData,errorResponses] = buildTestDataMatrix(events,spikes,...
        pairID,errorTrials); 
    nTestTrials = size(testResponses,1); 
    
    shuffleResponses = nan(nTestTrials,B);
    shuffleAccuracy = nan(B,1); 
    for i=1:B
        shuffleResponses(:,i) = testResponses(randperm(nTestTrials));
        [~,shuffleAccuracy(i)] = armPairDecoderAccuracy(Mdl,testData,...
            shuffleResponses(:,i));
    end
    allSessionShuffleAccuracy = [allSessionShuffleAccuracy; shuffleAccuracy];
    
    %Get accuracy for the other correct trials.
    [~,accuracy(session)] = armPairDecoderAccuracy(Mdl,testData,testResponses);
    
    %Get accuracy for error trials. 
    [~,errorAccuracy(session)] = armPairDecoderAccuracy(Mdl,errorData,errorResponses);
end

x = [accuracy; errorAccuracy; allSessionShuffleAccuracy];
grps = [zeros(size(accuracy)); ones(size(errorAccuracy)); 2*ones(size(allSessionShuffleAccuracy))];

scatterBox(x,grps,'xLabels',{'Correct','Error','Shuffle'},'yLabel',...
    'Decoder accuracy (% trials correctly decoded)','boxColor',[0 0 1; 1 0 0; 0 0 0]);