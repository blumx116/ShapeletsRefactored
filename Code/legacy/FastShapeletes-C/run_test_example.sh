optsdists=( euclidean correlation );
optsnorms=(0 1);
optscid=(0 1);

for dist in "${optsdists[@]}"; do
    for norm in "${optsnorms[@]}"; do
        for cid in "${optscid[@]}"; do
            # echo -e $dist $norm $cid
            if [ $cid -eq 1 ]
            then
                cidswitch="ON";
            else
                cidswitch="OFF";
            fi

            if [ $norm -eq 1 ]
            then
                normswitch="ON";
            else
                normswitch="OFF";
            fi

            echo -e Running Fast Shapelets with $dist distance metric
            echo -e Normalization is $normswitch and CID correction is $cidswitch
            ./Execs/FastShapelet Sample_Test_Data/Gun_Point_TRAIN 2 50 75 1 2 10  $dist $cid $norm
            if [ $? -eq 0 ]
            then
                echo -e Shapelet Tree has been successfully created.
                ./Execs/Classify Sample_Test_Data/Gun_Point_TEST 2 150 $dist $cid $norm

                if [ $? -eq 0 ]
                then
                    echo -e Classification complete!
                else
                    echo -e Classification failed!
                fi
            else
                echo -e Shapelet Tree construction failed!
            fi
            echo -e ""
        done
    done
done
echo -e Test examples complete
