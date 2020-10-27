% Compute the geometric median from a discrete set of d-dimensional 
% data points.

% Figure out data points

% my_classification = Classify_with_DT_func(TRAINING_DATA, ...
%                       1:size(TRAINING_DATA,1), ...
%                       SHAPELET_IDS, ...
%                       SHAPELETS,...
%                       TREE_NODES, ...
%                       1, ...
%                       zeros(size(TRAINING_DATA,1),1));

% Temp code....
my_class1_sample_indexes = find(TRAINING_DATA(:,1) == 1);
my_class1_samples = aligned_subsequences{1}(my_class1_sample_indexes,:);
POINT_SET = my_class1_samples(:,2:end);

geo_median = Compute_Geometric_Median_func(POINT_SET, 20);

% Rows are the individual points, columns are the dimensions
%POINT_SET = aligned_subsequences{1}(:,2:end);
% NUM_POINTS = size(POINT_SET,1);
% NUM_DIMENSIONS = size(POINT_SET,2);
% 
% y_old = zeros(1,NUM_DIMENSIONS);
% y_new = zeros(1,NUM_DIMENSIONS);
% 
% NUM_ITERATIONS = 20;
% y_iteration = zeros(NUM_ITERATIONS,NUM_DIMENSIONS);
% 
% for i = 1:NUM_ITERATIONS
%    % Call algorithm 
%    dist_sums = 0;
%    for j = 1:NUM_POINTS
%        dist = norm(y_old - POINT_SET(j,:));
%        y_new = y_new + POINT_SET(j,:)/dist;
%        dist_sums = dist_sums + (1 / dist);
%    end
%    y_new = y_new / dist_sums;
%    y_iteration(i,:) = y_new;
%    
%    y_old = y_new;
%    y_new = zeros(1,NUM_DIMENSIONS);
% end

for i = 1:NUM_POINTS
   final_dist(i) = norm(geo_median - POINT_SET(i,:)); 
end

figure;
hold on;

for i = 1:NUM_POINTS
   plot(1:NUM_DIMENSIONS, POINT_SET(i,:), 'b')
end
plot(1:NUM_DIMENSIONS, geo_median, 'r', 'LineWidth', 2)

hold off



% C# code from internet post:
% static void Main()
% {
%     double [][] pointset = new double[][]{
%         new double[] {10,0.45},
%         new double[] {3.091,12.9},
%         new double[] {8.12,13.01},
%         new double[] {6.23,8.731},
%         new double[] {12.12,2.568},
%         new double[] {9.51,5.89},
%         new double[] {7.67,11.901}
%     };
%     double[] y = { 0, 0 };
%     for (int i = 0; i < 20; i++) {
%         y = algorithm(pointset, y);
%         Console.WriteLine("({0:0.000},{1:0.000})",y[0],y[1]);
%     }
%     Console.ReadKey();
%     }
% 
% static double[] algorithm(double[][] pointset, double[] y)
% {
%     double[] s1 = {0,0};
%     double s2 = 0;
%     foreach (double[] point in pointset) {
%         double norm = Eucnorm(new double[] { point[0] - y[0], point[1] - y[1] });
%         s1[0] += point[0] / norm;
%         s1[1] += point[1] / norm;
%         s2 += 1 / norm;
%     }
%     return new double[] {s1[0]/s2, s1[1]/s2};
% }
% 
% static double Eucnorm(double[] v)
% {
%     return Math.Sqrt((v[0] * v[0] + v[1] * v[1]));
% }

