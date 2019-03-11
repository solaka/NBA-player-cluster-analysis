# NBA-player-cluster-analysis
### An effort to redefine modern NBA positions using k-means clustering
<img src='https://cdn.nba.net/nba-drupal-prod/styles/landscape_2090w/s3/2018-08/leaguev3.jpeg?itok=ZxI_rM2D'>

It’s no secret that basketball has changed over the last 25 years or so.  Back in the day, teams consisted of five relatively well-defined positions: point guard, shooting guard, small forward, power forward, and center.  Point guards brought the ball up the court and ran the offense, but didn’t necessarily score a ton.  Centers were immobile giants who rarely strayed from the lane.  Etc, etc.

OK, that’s overgeneralizing a little, but there’s little question things have changed.  Now we talk about stretch fours, point forwards, and all manner of other hybrids.  The five standard positions seem less relevant to today’s game than to the one that Isiah Thomas and Larry Bird played.

A popular pastime for data scientists interested in sports has been to “update” basketball positions based on the way the game is played today.  You can find examples [here](https://fastbreakdata.com/classifying-the-modern-nba-player-with-machine-learning-539da03bb824), [here](https://medium.com/hanman/the-evolution-of-nba-player-positions-using-unsupervised-clustering-to-uncover-functional-roles-a1d07089935c), and [here](https://towardsdatascience.com/redefining-basketball-positions-with-unsupervised-learning-34988d03057).  So naturally, I wanted to take a crack at it.
### Data
Like these other analyses, I want to use unsupervised learning to cluster players by type.  However, other analyses tend to want to “throw the kitchen sink” of statistics at the problem.  If the goal is to redefine player positions, I’d argue we should focus on the statistics that are most relevant to the players function/role.

First, I want to – as much as possible – use statistics that relate to the player’s role while on the floor, NOT how well or how often he performs that role.  With the basic statistics like the ones we’re using here, that’s not entirely possible.  A high defensive rebound rate probably indicates that the player stays near the rim on defense, but of course it’s also related to how good he is at collecting rebounds, given the opportunity.  But at least we can avoid using rebounds per game, total rebounds, etc. which are driven as much by playing time as ability or role.

Second, I look to avoid stats that measure a skill unrelated to function.  For example, many analyses include free throw percentage.  If we’re just interested in “similar players”, that’s fine…as would inclusion of height, country of origin, or conference of college attended.  But these things aren’t related to the player’s current role, which is the point of the exercise.

Ultimately, I used these ten statistics:

Metric | Comment
--- | ---
Free throw attempt rate (ftr) | FT attempts per FG attempt
Offensive rebound rate (orrate) | Pct of available offensive rebounds collected by player
Defensive rebound rate (drrate) | Pct of available defensive rebounds collected by player
Assist rate (arate) | Pct of teammate field goals assisted by player
Steal rate (strate) | Pct of opponent possessions ended by steal by player
Block rate (bkrate) | Pct of opponent 2-point FG attempts blocked by player
Turnover rate (torate) | Turnovers committed by player per 100 plays
3pt FGA percent (pct3) | Pct of field goal attempts from 3-point range
3-point shooting percentage (x3pct) | Pct of 3-point field goal attempts made
2-point shooting percentage (x2pct) | Pct of 2-point field goal attempts made

Why these 10?  Here’s my logic:

•	Free throw attempt rate – Guys who spend their time banging down low draw more fouls.  In addition, players who spend time on the exterior but drive to the basket draw more fouls than those who spend their lives outside (e.g. 3-point specialists)

•	Offensive and defensive rebound rates – True, these are strongly correlated, and I think a case could be made to just consider total rebound rate.  It’s a judgment call.

•	Assist rate – This is somewhat of a proxy for how often a player handles the ball per possession, but is also obviously related to what the player tends to do with the ball once it’s in his hands.  (Like just about every other stat, it’s also somewhat teammate-dependent, but that’s just one of the many things that makes analyzing basketball harder than, say, baseball.)

•	Steal rate / Block rate – These speak to the player’s role on defense.  Are they guarding the ballhandler and/or disrupting passing lanes?  Are they in a position to challenge guys trying to post up and/or driving to the rim?

•	Turnover rate – As you might expect, turnover rate is often strongly related to assist rate.  Though as we’ll see, big, physical players who work underneath tend to have relatively high turnover rates despite low assist rates.

•	3pt FGA percentage – This one clearly differentiates between players who can and do shoot from distance and those who can’t / don’t.

•	2-pt FG pct / 3-pt FG pct – I know what you’re thinking: “I thought he said he wasn’t going to use stats that reflected how well a player performed his function”.  I did, but I’m using them based on the premise that they reflect more than just shooting ability.  All else equal, 2pt FG percentages will tend to be highest for those operating exclusively under the basket.  All else equal, 3pt FG percentages will tend to be higher for players getting a lot of open looks on spot up threes, as opposed to those having to create their own shot.

The data I used was pulled using the very handy [ballr](https://cran.r-project.org/web/packages/ballr/index.html) package for R, which provides a convenient way to access data select tables from basketball-reference.com.  I used game results since the 2015-16 season (through 2/13/19), and included only players with at least 1,000 minutes played over that period.

### Model
I experimented with two types of clustering models: k-means and hierarchical.  For the hierarchical models, I also experimented with Mahalanobis distance (which employs the covariance matrix of the feature data) as well as Euclidean distance, and with both complete and average linkages.  The dendrograms indicated that Euclidean-complete offered the best hierarchical option (others often put outliers in their own clusters), but ultimately I wasn’t happy with the way the hierarchical models were clustering players.

Instead, I chose a k-means model with a total of 12 clusters.  The decision was based in part on balancing within-cluster variance with the number of clusters, but also on iteratively inspecting how players were categorized under different numbers of clusters and choosing one that produced the “best” result (subjectively speaking).

