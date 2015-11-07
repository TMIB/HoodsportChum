
##Check for installed packages. Citation for this code:
##http://stackoverflow.com/questions/4090169/elegant-way-to-check-for-missing-packages-and-install-them

list.of.packages <- c("dplyr", "XML", "ggplot2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)>0) {install.packages(new.packages)} 
require(dplyr)
require(XML)
require(ggplot2)

#create the empty data frame with correct data types
HoodsportData<-data.frame(Date=as.Date(character()),
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
          
          HoodsportData<-rbind(HoodsportData, filteredtable)
          i <- i + 1
     }
}
HoodsportData <-mutate(HoodsportData, chumperangler = as.numeric(Chum)/as.numeric(Anglers))
HoodsportData <-filter(HoodsportData, chumperangler >0)
HoodsportData<-mutate(HoodsportData, Date = mdy(Date))
HoodsportData<-HoodsportData[,c("Date", "Anglers", "Chum", "chumperangler")]


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

#remove the rows with no data
chumreturn<-filter(chumreturn, chumperangler >0)

names(chumreturn)[names(chumreturn)=='Sample.Date']<- "Date"

HoodsportData<-rbind(chumreturn,HoodsportData)

WeekOfYear<-as.numeric()
for (i in 42:51){WeekOfYear<-c(WeekOfYear,i)}

MeanData<-as.numeric()

for (i in 42:51)
{
     MeanData<-c(MeanData,mean(HoodsportData$chumperangler[week(HoodsportData$Date)==i]) )
}

rollup<-data.frame(WeekOfYear,MeanData)
MyPlot<-ggplot(rollup, aes(rollup$WeekOfYear, rollup$MeanData))+ geom_bar(stat="identity")+
     scale_x_continuous(breaks=42:51, minor_breaks=NULL)+
     ylab("Mean fish per angler")+xlab("Week of Year")+
     ggtitle("Hoodsport Chum 2005-2015")


jpeg(filename = "Myplot.jpg", width=1024, pointsize =12, quality = 200, bg = "white", res = NA, restoreConsole = TRUE)
MyPlot
dev.off()

