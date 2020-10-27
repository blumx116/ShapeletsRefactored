### Small file to run executables on Gun_Point dataset
# To run:  # bash run_example.bat
#
echo Testing executables on Gun Point dataset
#
#
### Training with normalization ###
echo Running Fast Shapelets with normalization
echo -e "\n"
./Execs_Norm/FastShapelet_Normalized Sample_Test_Data/Gun_Point_Train 2 50 150 10 10
echo -e "\n"
echo Shapelet Tree with normalized distances has been successfully created.
#
#
#
### Classifying with normalization ###
./Execs_Norm/Classify_Normalized Sample_Test_Data/Gun_Point_Test 2 150
echo -e "\n"
echo Classification with normalized data complete.
#
#
#
### Training without normalization ###
echo Running Fast Shapelets without normalization
echo -e "\n"
./Execs_UnNorm/FastShapelet_UnNormalized Sample_Test_Data/Gun_Point_Train 2 50 150 10 10
echo -e "\n"
echo Shapelet Tree with non-normalized distances has been successfully created.
#
#
#
### Classifying without normalization ###
./Execs_UnNorm/Classify_UnNormalized Sample_Test_Data/Gun_Point_Test 2 150
echo -e "\n"
echo Classification with non-normalized data complete.
echo Script complete.