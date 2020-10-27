function [train_accuracy_res, test_accuracy_res] = pca_trial(...
    train_x, train_y, ...
    test_x, test_y)

coefs = mnrfit(train_x, train_y);

train_accuracy_res = test_accuracy(train_x, train_y, coefs);
test_accuracy_res = test_accuracy(test_x, test_y, coefs);
end