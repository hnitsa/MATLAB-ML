load('training_dataset.mat')   % contains X and Y

% Remove only almost-zero boring samples
idx = abs(Y) > 0.02;

X2 = X(idx,:);
Y2 = Y(idx);

% Prepare for neural network
inputs = X2';
targets = Y2';

% Train bigger network
net = fitnet([20 10]);

net.divideParam.trainRatio = 0.70;
net.divideParam.valRatio   = 0.15;
net.divideParam.testRatio  = 0.15;

[net,tr] = train(net, inputs, targets);

% Predictions
predicted = net(inputs);

% Error
mseError = mse(targets - predicted);
disp(mseError)

% Plot first 500 samples
figure
plot(targets(1:500),'b')
hold on
plot(predicted(1:500),'r')
legend('Real Steering','Predicted Steering')
xlabel('Sample')
ylabel('Steering Direction')
title('Neural Network Prediction vs Real Output')
grid on

% Save model
save('trained_navigation_network.mat','net','tr','mseError')