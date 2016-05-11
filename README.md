# Adaptation-Dispersal
test scripts to run on the university cluster
The main function is "RunSimu.m". It takes each line of the "InputArguments.csv" as arguments, and passes them to the main function "DispersalSimulation".
********Now it runs sequentially. I would like them to run in parallel. *********
There are a few supporting function files as well, such as "myID_parent.m", "myDistance.m", etc.
The output will be several .csv files. Sample output file are uploaded as well.

The first argument is the maximum steps each simulation should run. In the sample Input file, I set it to 5.
When running the program, it prints the current step to the standard output.
So the expected output to the screen will be:
li$ octave RunSimu.m 
t =  1
t =  2
t =  3
t =  4
t =  5
t =  1
t =  2
t =  3
t =  4
t =  5
And the output files will be 6 ".csv" files.
The files with names end with "CoordinatesHabitat-1/2.csv" should have dimension 2 x 5 (steps), with real number values, most likely within (0,1).
The files with names end with numbers (....InitDispProb-0.35.csv and ....InitDispProb-0.65.csv) should have dimension 6 x 5 (steps). The first row should be the population size (1000), second row is the number of habitats that have individuals (2 or 1). The last 4 rows are probabilities, in (0,1).


