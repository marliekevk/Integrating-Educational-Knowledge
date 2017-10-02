# Integrating-Educational-Knowledge
Code related to the paper "Integrating educational knowledge: Reactivation of prior knowledge during educational learning enhances memory integration" by van Kesteren, Krabbendam &amp; Meeter, 2017

In this GitHub repository you will find the code used in this experiment. There are two folders, one for each experiment. The code used in Experiment 1 is adapted for Experiment 2 so there is a lot of overlap. Basically, there are three types of code:

- Pre-experimental: randomize.m (pseudo)randomizes the stimuli and their congruency-association for each participant seperately (Matlab 2015b code).
- Experimental: encoding.sce, math.sce and recall.sce are the Presentation (version 19.0) scripts used in this experiment. The .exp files are not read by GitHub but can be obtained upon request and we did not use .sdf files.
- Post-experimental: all files starting with analyze... are analysis files, written in Matlab 2015b. For experiment 1, there are seperate files for the congruency and timing analyses, which were done seperately (see paper), and for experiment 2 there are only congruency analyses since this was the only condition (see paper). The files that include _ass are for the associative recall test, as these had to be analyzed by hand because of the free typing nature.
- Graphs: the graphs_schema_education files contains iPython (Jupyter) code to make the graphs that are used in the paper.

All code is commented, but it could still be that things are unclear. In this case, please email me at marlieke.van.kesteren - at - vu.nl so I can explain further. Code cannot be run without the logfiles and excel files, I just posted them online for people to have a look at, but if you want to do this, you can contact me as well.
