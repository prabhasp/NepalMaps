<link href="http://kevinburke.bitbucket.org/markdowncss/markdown.css" rel="stylesheet"></link>

Poverty by District in Nepal, mapped
---

Chandan Sapkota, who one of my friend Bigyan calls the "Ezra Klein of Nepal", produces amazing analysis about Nepal, taking data sources from the obscure reports of government institutions and writing them up in accessible blog posts. When he posted about ["Poverty by District in Nepal"](http://sapkotac.blogspot.com/2013/07/poverty-by-district-in-nepal.html), I thought that I'd map the poverty, since it is hard for me to place all the districts in Nepal, and I wanted to see what the visual spread of poverty was. This html is generated automatically using R markdown; see the [git repository](https://github.com/prabhasp/NepalMaps/tree/gh-pages/Poverty) to see the data and to get the rmd file. The git repository also contains a library in the making, NepalMapUtils, which has some convenience functions for making choropleth maps (of Nepal).

## 0. Data preparation

Lets load up the data and the "NepalMapUtils" library. This works fine if you do a [setwd](http://www.statmethods.net/interface/workspace.html) to inside the `Poverty` folder within the [NepalMaps](http://github.com/prabhasp/NepalMaps) repository.


```r
# setwd(...) here
poverty11 <- read.csv("PovertyEstimates2011.csv")
source("../NepalMapUtils.R")
```


We will do one tranformation before proceeding, which is to rename our columns. In the dataset, "FGT(0)" (which loads in R as `FGT.0.` because R doesn't like parentheses) is the _poverty incidence_ metric, defined as proportion of individuals living in that area who are in households with an average per capita expenditure below the poverty line. FGT(1) is the _poverty gap_, which is the average distance below the poverty line, being zero for those individuals above the line, and FGT(2) is _poverty severity_, the squared distance for those below hte line, which gives more weight to the very poor. [(See 2006 report for definitions)](http://cbs.gov.np/wp-content/uploads/2012/Others/SAE%20of%20Poverty,%20Caloric%20Intake%20and%20Malnutrition%20in%20Nepal.pdf).

So lets go ahead and rename our columns to these understandable names:

```r
names(poverty11)
```

```
## [1] "District"   "Population" "FGT.0."     "S.E.FGT.0." "FGT.1."    
## [6] "S.E.FGT.1." "FGT.2."     "S.E.FGT.2."
```

```r
names(poverty11) <- c("District", "Population", "PovertyIncidence", "S.E-P.I.", 
    "PovertyGap", "S.E-P.G.", "PovertySeverity", "S.E-P.S.")
```


And now we will also load the 2001 data, which has been modified to have the exact same column names already:


```r
poverty2001 <- read.csv("PovertyEstimates2001.csv")
```


## 1. Poverty Incidence (2011)

 Lets make a quick map of it (note that I haven't paid attention to map projections: these are sketches).

```r
npchoropleth(poverty11, "District", "PovertyIncidence")
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.png) 


A second map, coloring those that are above the mean (weighted by population) as blue and those below as red:

```r
meanpoverty <- weighted.mean(poverty11$PovertyIncidence, poverty11$Population)
npchoropleth(poverty11, "District", "PovertyIncidence") + scale_fill_gradient2(low = muted("blue"), 
    midpoint = meanpoverty, mid = "white", high = muted("red"))
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 


In the second map, you can really see how (1) the far west and the western moutains are really hurting and (2) prosperity is pretty spatial: swaths of prosperity in the Kathmandu valley, the Pokhara-Chitwan area (and larger Gandaki / Lumbini zones), in the very east, and in Sarlahi / Mahottari (wonder why... these districts house neither Birgunj nor Janakpur).

## 2. Absolute poor (2011)

The next thing to look at, as Chandan did, is the number of absolute poor, which is easily calculable given that population is nicely included in this dataset. Lets have a look:

```r
poverty11$AbsolutePoor <- poverty11$Population * poverty11$PovertyIncidence
npchoropleth(poverty11, "District", "AbsolutePoor")
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 

The absolute poor are concentrated in swatches of the Tarai, and you see quite a bit of absolute poor in the far west, even though populations are smaller, because of such a high concentration of the poor there. Note that the Kathmandu valley doesn't fare all that well, even though there is relative prosperity there; it just has a LOT of people living there.

For reference, a population sketch to remind us where people live in Nepal:

```r
npchoropleth(poverty11, "District", "Population")
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 


3. Comparisons with 2001
===

Now, lets us compare the data to the 2001 small area povery estimates. We will first create a new dataframe containing data from both years, then take the difference and map it (while remembering to flip the color scheme, a decrease is poverty incidence is good!):


```r
poverty <- merge(poverty11, poverty2001, by = "District", suffixes = c("_2011", 
    "_2001"))
poverty$PovertyTenYrChange <- poverty$PovertyIncidence_2011 - poverty$PovertyIncidence_2001
npchoropleth(poverty, "District", "PovertyTenYrChange") + scale_fill_gradient2(low = muted("blue"), 
    high = muted("red"))
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 


The units here are in difference of percentage points; bigger negative numbers are better. The message here seems to be that most of the country has become less poor, with an exception of an increase in poverty in: Mustang / Manang, the Far Western Mountains, and in the central-eastern Terai (Parsa/Bara/Rautahat and Siraha/Saptari).
