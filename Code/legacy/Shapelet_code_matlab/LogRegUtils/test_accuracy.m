function [accuracy] = test_accuracy(x, y, coefs)
preds = zeros(size(x, 1), 1);

for i = 1:size(preds, 1)
    prediction = LogRegPredict(x(i, :), coefs);
    preds(i) = (prediction < 0) + 1;
end

accuracy = 100 * sum(y == preds) / size(y, 1);
end