# This is a makefile created for FastShapelet.cpp code
#
# Authors:
# --- Thanawin Rakthanmanon (original FastShapelet code)
# --- Mark Valovage (Makefile and code modifications)
# --- Ben Sorenson (Code modifications)

CC = g++
OPTFLAGS = -O3 -fno-strict-aliasing -D_GNU_SOURCE -std=c++11
COPTIONS = -DLINUX -D_FILE_OFFSET_BITS=64 -Wall\
           -Wno-unused-function -Wno-unused-label -Wno-unused-variable\
           -Wno-parentheses -Wsequence-point

#Standard Libraries
STDLIBS = -lm

CFLAGS = $(COPTIONS)  $(OPTFLAGS)
LIBS = $(STDLIBS)

# Source code for creating shapelets and classifying with shapelets
FS_SOURCE = FastShapelet.cpp utils/ClassShapelet.cpp utils/NN_ED.cpp utils/Utils.cpp
FS_EXE = Execs/FastShapelet

CLASSIFY_SOURCE = Classify.cpp utils/ClassShapelet.cpp utils/NN_ED.cpp utils/Utils.cpp
CLASSIFY_EXE = Execs/Classify

default:
	# Make directories for executables
	rm -rf Execs
	mkdir Execs

	# Compile code using normalization
	$(CC) $(CFLAGS) $(FS_SOURCE) $(LIBS) -o $(FS_EXE)
	$(CC) $(CFLAGS) $(CLASSIFY_SOURCE) $(LIBS) -o $(CLASSIFY_EXE)

clean:
	rm -f Execs/FastShapelet
	rm -f Execs/Classify
	rmdir Execs
