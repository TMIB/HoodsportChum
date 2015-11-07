
##Check for installed packages. Citation for this code:
##http://stackoverflow.com/questions/4090169/elegant-way-to-check-for-missing-packages-and-install-them

list.of.packages <- c("dplyr", "XML", "ggplot2", "grid")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)>0) {install.packages(new.packages)} 
require(dplyr)
require(XML)
require(ggplot2)
require(grid)

#create the empty data frame with correct data types
hoodsportdata<-data.frame(Date=as.Date(character()),
                          Anglers=numeric(),
                          Chum=numeric(),
                          stringsAsFactors = FALSE)

for (reportyear in 2005:2012)
{
     url<-paste0("http://wdfw.wa.gov/fishing/creel/puget/",reportyear,"/")
     reportyear <- reportyear + 1
     #get the page for that year
     html <- htmlTreeParse(url, useInternalNodes=T)
     #find all href links
     test<-xpathApply(html, "//a[@href]", xmlGetAttr, 'href')
     #make a logical vector of just the "south" links
     filterlogic<-grepl("south.htm", test)
     #filter by the logical vector
     test<-test[filterlogic]
     #make a data frame of the URLS
     links<-data.frame(paste0(url, test))
     names(links)<-make.names("URL")
     

     #run through all the links on the host page
     for (i in 1:nrow(links))
     {
       #use a tryCatch here, as some of the URLs are broken.
          thistable<- tryCatch(readHTMLTable(as.character(links[i,]), stringsAsFactors = FALSE), error = function(e) e)
          
          if(inherits(thistable, "error")) next
          thistable<-data.frame(thistable)
          namevec<-vector()
          for (i in 1:ncol(thistable)) {namevec[i]<-paste0("Column", i)}
          names(thistable)<-make.names(namevec)
          rm(namevec)
          filteredtable<-select(thistable, Column1, Column2, Column4, Column7)
          names(filteredtable) <- make.names(c("Date", "Site", "Anglers", "Chum"))
          #filter the table for only Hoodsport shore data
          filteredtable<-filter(filteredtable, Site == "Hoodsport Shore")
          
          hoodsportdata<-rbind(hoodsportdata, filteredtable)
          i <- i + 1
     }
}
hoodsportdata <-mutate(hoodsportdata, chumperangler = as.numeric(Chum)/as.numeric(Anglers))
hoodsportdata <-filter(hoodsportdata, chumperangler >0)
hoodsportdata<-mutate(hoodsportdata, Date = mdy(Date))
hoodsportdata<-hoodsportdata[,c("Date", "Anglers", "Chum", "chumperangler")]


#now we have data from 2005-2012. Let's get 2013 and 2014 (different format)

url<-"http://wdfw.wa.gov/fishing/creel/puget/site.php?LoCode=1508"
tables = readHTMLTable(url, stringsAsFactors = FALSE)
df<- tables[[10]] #this one looks good

df<-df[14:120,] #get only rows 14:120

names(df)<-make.names(df[1,]) #name the columns
df<-filter(df, Sample.Date != "Sample Date") #filter out all the extra header rows

#convert date column to POSIXct compatible data type
df<-mutate(df, Sample.Date = mdy(Sample.Date))
df<-mutate(df, chumperangler = as.numeric(Chum)/as.numeric(Anglers))

chumreturn<-df[,c("Sample.Date", "Anglers", "Chum", "chumperangler")]

names(chumreturn)[names(chumreturn)=='Sample.Date']<- "Date"

hoodsportdata<-rbind(chumreturn,hoodsportdata)

#remove any week that has had 2 or fewer observations in 10 years.
for (i in 42:51)
{
  countofobservations<- sum(week(hoodsportdata$Date) == i)
  if (countofobservations <= 2)
  {
    hoodsportdata<-filter(hoodsportdata, week(hoodsportdata$Date) != i)
  }
  
 
}

weekofyear<-as.numeric()
for (i in 42:51){weekofyear<-c(weekofyear,i)}

meandata<-as.numeric()

for (i in 42:51)
{
     meandata<-c(meandata,mean(hoodsportdata$chumperangler[week(hoodsportdata$Date)==i]) )
}

anglerdata<-as.numeric()

for (i in 42:51)
{
  anglerdata<-c(anglerdata,mean(as.numeric(hoodsportdata$Anglers[week(hoodsportdata$Date)==i])) )
}

catchrollup<-data.frame(weekofyear,meandata)
anglerrollup<-data.frame(weekofyear,anglerdata)



#multiplot function from the R cookbook
#(http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_%28ggplot2%29/)
multiplot <- function(..., plotlist=NULL, cols) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # Make the panel
  plotCols = cols                       # Number of columns of plots
  plotRows = ceiling(numPlots/plotCols) # Number of rows needed, calculated from # of cols
  
  # Set up the page
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(plotRows, plotCols)))
  vplayout <- function(x, y)
    viewport(layout.pos.row = x, layout.pos.col = y)
  
  # Make each plot, in the correct location
  for (i in 1:numPlots) {
    curRow = ceiling(i/plotCols)
    curCol = (i-1) %% plotCols + 1
    print(plots[[i]], vp = vplayout(curRow, curCol ))
  }
  
}


catchplot<-ggplot(catchrollup, aes(catchrollup$weekofyear, catchrollup$meandata))+ geom_bar(stat="identity")+
     scale_x_continuous(breaks=42:51, minor_breaks=NULL)+
     ylab("Mean fish per angler")+xlab("Week of Year")+
     ggtitle("Hoodsport Chum 2005-2015")

anglerplot<-ggplot(anglerrollup, aes(anglerrollup$weekofyear, anglerrollup$anglerdata))+ geom_bar(stat="identity")+
  scale_x_continuous(breaks=42:51, minor_breaks=NULL)+
  ylab("Mean number of anglers")+xlab("Week of Year")+
  ggtitle("Hoodsport Chum 2005-2015")

jpeg(filename = "hoodsport.jpg", width=1024, pointsize =12, quality = 200, bg = "white", res = NA, restoreConsole = TRUE)
multiplot(catchplot, anglerplot, cols=1)
dev.off()

