disp('Running classifier on data while rat is on arm...');
[trainingData,trainingResponses,testDataTrials,errorTrials,pairID] = ...
    buildTrainingDataMatrix(events,spikes,armIDtrial);

% Get the rest of the correct trials that weren't used to train classifier. 
[testData,testResponses] = buildTestDataMatrix(events,spikes,...
    pairID,testDataTrials); 

% Get error trials. 
[errorData,errorResponses] = buildTestDataMatrix(events,spikes,...
    pairID,errorTrials); 
    
Mdl = fitcnb(trainingData,trainingResponses,'distributionnames','kernel');

[~,accuracy] = armPairDecoderAccuracy(Mdl,testData,testResponses);
disp(['Accuracy: ',num2str(accuracy),'%']); 

[~,accuracy] = armPairDecoderAccuracy(Mdl,errorData,errorResponses);
disp(['Accuracy on error trials: ',num2str(accuracy),'%']); 

disp(' '); 
% 
% t = 1;
% disp(['Running classifier on data ',num2str(t),' seconds before rat enters arm...']); 
% [trainingData,trainingResponses,testData,...
%     testResponses,errorData,errorResponses] = ...
%     buildTrainingDataMatrix(events,spikes,armIDtrial,'useDecisionEpoch',true);
% Mdl = fitcnb(trainingData,trainingResponses,'distributionnames','kernel');
% 
% [predictions] = predict(Mdl,testData);
% percentCorrect = (sum((testResponses - predictions)==0)/length(predictions))*100;
% disp(['Accuracy: ',num2str(percentCorrect),'%']); 
% 
% [predictions] = predict(Mdl,errorData);
% percentCorrect = (sum((errorResponses - predictions)==0)/length(predictions))*100;
% disp(['Accuracy on error trials: ',num2str(percentCorrect),'%']); 
% 
