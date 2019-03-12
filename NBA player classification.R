
library(car)
library(ballr)
library(tidyverse)
library(rgl)

### load and prep basketball-reference data via ballr
NBA2016.1 = NBAPerGameStatistics(season = 2016)
NBA2016.2 = NBAPerGameAdvStatistics(season = 2016)
merge_fields = names(NBA2016.2)[!names(NBA2016.2) %in% names(NBA2016.1)]
NBA2016 = left_join(NBA2016.1, 
                    NBA2016.2[,c("player", "tm", merge_fields, "mp")],   # mp.x = min per game, mp.y = total min
                    by = c("player", "tm"))


NBA2017.1 = NBAPerGameStatistics(season = 2017)
NBA2017.2 = NBAPerGameAdvStatistics(season = 2017)
NBA2017 = left_join(NBA2017.1, 
                    NBA2017.2[,c("player", "tm", merge_fields, "mp")],
                    by = c("player", "tm"))
colnames(NBA2017)[30] = "pts"

NBA2018.1 = NBAPerGameStatistics(season = 2018)
NBA2018.2 = NBAPerGameAdvStatistics(season = 2018)
NBA2018 = left_join(NBA2018.1, 
                    NBA2018.2[,c("player", "tm", merge_fields, "mp")],
                    by = c("player", "tm"))

NBA2019.1 = NBAPerGameStatistics(season = 2019)
NBA2019.2 = NBAPerGameAdvStatistics(season = 2019)
NBA2019 = left_join(NBA2019.1, 
                    NBA2019.2[,c("player", "tm", merge_fields, "mp")],
                    by = c("player", "tm"))


### bind seasons for classification and roll up stats by player
by.season = rbind(NBA2016, NBA2017, NBA2018, NBA2019)
by.season$totfga = by.season$fga * by.season$g
by.season$att3pt = by.season$x3pa * by.season$g
by.season$att2pt = by.season$x2pa * by.season$g

all.seasons = by.season %>%
                group_by(player) %>%
                summarize(ftr = weighted.mean(ftr, totfga),           
                          orrate = weighted.mean(orbpercent, mp.y),
                          drrate = weighted.mean(drbpercent, mp.y),
                          arate = weighted.mean(astpercent, mp.y),
                          strate = weighted.mean(stlpercent, mp.y),
                          bkrate = weighted.mean(blkpercent, mp.y),
                          torate = weighted.mean(tovpercent, mp.y), 
                          pct3 = weighted.mean(x3par, totfga),
                          x3pct = weighted.mean(x3ppercent, att3pt),
                          x2pct = weighted.mean(x2ppercent, att2pt),
                          mp.y = sum(mp.y)
                          )
head(all.seasons)
all.seasons[is.na(all.seasons)] = 0    # NAs result where minutes played for a given season are very limited and no stats were accrued

mp.min = 1000

all.seasons.qual = all.seasons %>% filter(mp.y >= mp.min)

cluster.data = all.seasons.qual %>% 
  select(-player, -mp.y) %>%
  scale()

### PCA ###
pr.out = prcomp(cluster.data)
pr.var = pr.out$sdev^2
plot(cumsum(pr.var) / sum(pr.var))

##################
### clustering ###
##################

# k means #
num.seeds = 10
max.clusters = 15
withinss = matrix(NA, nrow=num.seeds, ncol=max.clusters)
betwss = matrix(NA, nrow=num.seeds, ncol=max.clusters)

for (s in 1:num.seeds){
  for (i in 1:max.clusters){
    set.seed(s)
    km.mod = kmeans(cluster.data, centers=i, iter.max=50)
    withinss[s, i] = km.mod$tot.withinss
  }
}

mean.within = colMeans(withinss) / km.mod$totss
mean.within
plot(mean.within)

set.seed(5)
num.clusters = 12
km.mod = kmeans(cluster.data, centers=num.clusters, iter.max=50)
km.mod

################
### results ####
################
class.players = cbind(all.seasons.qual, pr.out$x)
class.players$km.cluster = km.mod$cluster
class.players$h.cluster = h.clusters

class.players %>%
  select(-player, -mp.y) %>%
  group_by(km.cluster) %>%
  summarise_all(mean)

class.players %>%
  select(-player, -mp.y) %>%
  group_by(h.cluster) %>%
  summarise_all(mean)

class.players %>% filter(km.cluster == 8)

my.cols = c('black', 'blue', 'yellow', 'lightgreen', 'cadetblue2', 'darkorange', 'forestgreen', 'darkorchid', 'goldenrod', 'red', 'green2', 'lightpink3')

palette(my.cols)

plot(PC2 ~ PC1, data=class.players, col=km.cluster, pch=16, main = "Player clusters by first two principal components")
pt.labels = ifelse(class.players$mp.y > 7000, class.players$player, "")
text(class.players$PC1, class.players$PC2, pt.labels, pos=2, cex=0.5)
cluster.labels = c('1: banger',
                   '2: exterior distributor',
                   '3: defensive stopper',
                   '4: offensive hub',
                   '5: size and distance',
                   '6: under the basket',
                   '7: stretch big',
                   '8: attacking shooter',
                   '9: inside / outside',
                   '10: 3-point specialist',
                   '11: attacking distributor',
                   '12: exterior shooter')
legend(5.4, -1.2, legend=cluster.labels, col=my.cols, pch=16, cex=0.6)

plot3d(x=class.players$PC1, y=class.players$PC2, z=class.players$PC3, col=class.players$km.cluster,
          xlab="PC1: 'size/physicality'", ylab="PC2: 'quickness/ballhandling'", zlab="PC3: 'pickpockets'")
text3d(x=class.players$PC1, y=class.players$PC2, z=class.players$PC3, text=pt.labels, pos=2, cex=0.65)
legend3d("topright", legend=cluster.labels, col=1:num.clusters, pch=16, cex=0.45)

palette("default")