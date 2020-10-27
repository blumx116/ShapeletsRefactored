This repository contains Fast Shapelet code original created by Thanawin Rakthanmanon and modified by Mark Valovage and Ben Sorenson.  If used for research purposes, please cite the authors as follows:

* Include Rakthanmanon’s citation here *
* Include our citation here *

## Modifications

This repository contains the original code with some small working modifications:

  - Original code (Thanawin Rakthanmanon)
  - Addition of a makefile (Mark Valovage and Ben Sorenson)
  - Removal of small errors and warnings (Mark Valovage)
  - Reorganization of files into /utils folder
  - Addition of CID correction factor, normalization, and distance metric arguments (Ben Sorenson)

## Compiling

  - Makefile is included for linux compilation.
  - Run ‘make clean’ followed by ‘make’.
  - Code will compile into executables

## Usage

In addition to the parameters described below both FastShapelet(.exe) and Classify(.exe), 3 optional arguemnts have been added.

  1. distance metric name
  2. boolean normalization flag
  3. boolean CID correction flag

### FastShapelet(.exe)

Optional parameters are now

  - **`R`**:number_of_random iterations (default `10`)
  - **`distance metric`**: name of distance metric used (currently `euclidean`, `correlation`, and `manhattan` are supported, and `euclidean` is the default)
  - **`CID` flag**: (default `0`)
  - **`Normalization` flag**: (default `1`)
  - **`K`**: size of candidates (default `10`)
  - **`tree_file`**:  file for keeping the shapelet tree (default `tree.txt`)
  - **`time_file`**:  file for keeping the time (default `time.txt`)


### Classify(.exe)

Optional parameters are now

  - **distance metric**: name of distance metric used (currently `euclidean`, `correlation`, and `manhattan` are supported, and `euclidean` is the default)
  - **`CID` flag**: (default `0`)
  - **`Normalization` flag**: (default `1`)
  - **`input_tree_file`**: file containing the shapelet tree (default `tree.txt`)
  - **`output_acc_file`**: file for writing classification accuracy (default `acc.txt`)

## Adding additional distance metrics

Additional distance metrics can bee added to `Utils.cpp`. A distance metric is  defined by the following `typedef` (found in `Utils.h`) ```typedef double (*distfunc)(double *, double *, int, int);``` So, if you wanted to add a new `my_distance` function, you would

1.  Define the function
```C
double my_distance(double *Q, double *T, int j, int m){
    double dist;
    for(i=0; i<m; i++){
        do something with Q[i] and T[i + j] ...
    }
   return dist;
}
```

2. Modify `get_distance_function` to recognize the name of your new distance metric.

```C
distfunc get_distance_function(char *dist_name) {
  if (strcmp(dist_name, "correlation") == 0) {
    return correlation_distance;
  } else if (strcmp(dist_name, "manhattan") == 0){
    return manhattan_distance;
  } else if (strcmp(dist_name, "my_distance") == 0){
    return my_distance;
  } else {
    return euclidean_distance;
  }
}

```


## ORIGINAL README FROM Thanawin Rakthanmanon
```
 == How to run the code ==

 1. Create the shapelet tree from train data by using command "FastShapelet.exe". The shapelet tree will be written in tree.txt (by default).
 2. Using the tree to classify the test data by using command "Classify.exe".

 For example on Gun/Point dataset, which has 2 classes, 50 train data, 150 test data, minimum length of all time series is 150.
 We can use this command to run:
 C:\> FastShapelet.exe Gun_Point_Train 2 50 150 10 1

 Then test the accuracy with this command:
 C:\> Classify.exe Gun_Point_Test 2 150


 == More Detail ==
 Note that you can type command "FastShapelet.exe" or "Classify.exe" for help.

 Command "FastShapelet.exe" receives 5 necessary parameters which are
   number_of_classes   number_of_train_time_series   maximum_lengh_of_the_final_shapelet    minimum_length_of_the_shapelet   step_for_search
 and also 4 optional parameters which are
   R   K   tree_file   time_file

 -- Necessary parameters --
 	number_of_classes:  number of classes in the dataset. Can be any integer more than 1.
 	number_of_train_time_series: number of train data
 	maximum_lengh_of_the_final_shapelet:  shaplet length is at most the lenght of the shortest input time series
 	minimum_length_of_the_shapelet: usually we set to 10.
 	step_for_search: If you allow to skip some shapelet length, you can set this number larger than 1. If set to 10, mean we may search shapelet of length 10, 20, 30, and so on.

 -- Optional Parameters --
   R: number_of_random_iteration (default 10)
   K: size_of_candidates  (default 10)
   tree_file:  file for keeping the shapelet tree (default tree.txt)
   time_file:  file for keeping the time (default time.txt)
```
