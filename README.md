# HoodsportChum

This project is primarily an exercise for me as I work through the "Exploratory Data Analysis" class on Coursera.

Question to answer: "which weeks have the best Chum salmon returns at Hoodsport, WA?"

Method:
I scraped data from the creel reports on the Washington Department of Fish and Wildlife website. http://wdfw.wa.gov/fishing/creel/puget/
Specifically looking for data that correspond to the Hoodsport location, for returns of Chum salmon.
This data is primarily in individual tables corresponding to different time periods, and the format changed in 2013.

Data was processed for the 10-year period from 2005-2015. Since the number of anglers varied with each creel report, I 
normalized by calculating fish per angler in each report. 

Then I organized the data according to which week of the year it corresponded to, and calculated the mean fish per angler for each week. I removed any data from weeks that had 2 or fewer observations over the 10 year period as outliers.

The result is the mean data of fish per angler by week over a 10 year period.

Next, I used the same data to determine the mean number of anglers per week over the same 10 year period.

The plots may be found in hoodsport.jpg. 


The first "Sweet spot" is the 44th week of the calendar year. Average number of anglers is 35.5 that week, and average fish caught per angler is 1.69.
Fishing goes down slightly on week 45; seeing on average, 1.5 fish caught per angler, with 47.9 anglers trying their luck.
Week 46 has on average only 1.1 fish caught per angler, but there are fewer folks trying with an average of 24.8 folks out there fishing. That's ~ a 48% drop in people from the previous week.
Week 47 is hard fishing, with .87 fish caught per angler, but fewer folks to contend with, 21 people on average.
Week 48 seems to be a second "sweet spot"; barely anyone fishing, only 13 folks on average, but they are doing pretty well, with 1.21 fish per angler.


Next exercise will be to separate the data into even and odd years. Since Pink salmon run only in odd years, we can look at whether
the chum salmon runs tend to be earlier or later on years when the Pink salmon return.


