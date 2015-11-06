# HoodsportChum

This project is primarily an exercise for me as I work through the "Exploratory Data Analysis" class on Coursera.

Question to answer: "which weeks have the best Chum salmon returns at Hoodsport, WA?"

Method:
I scraped data from the creel reports on the Washington Department of Fish and Wildlife website. http://wdfw.wa.gov/fishing/creel/puget/
Specifically looking for data that correspond to the Hoodsport location, for returns of Chum salmon.
This data is primarily in individual tables corresponding to different time periods, and the format changed in 2013.

Data was processed for the 10-year period from 2005-2015. Since the number of anglers varied with each creel report, I 
normalized by calculating fish per angler in each report. 

Then I organized the data according to which week of the year it corresponded to, and calculated the mean fish per angler for
each week. 

The result is the mean data of fish per angler by week over a 10 year period.

Next exercise will be to separate the data into even and odd years. Since Pink salmon run only in odd years, we can look at whether
the chum salmon runs tend to be earlier or later on years when the Pink salmon return.


