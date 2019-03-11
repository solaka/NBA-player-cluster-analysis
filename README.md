# NBA-player-cluster-analysis
An effort to redefine modern NBA positions using k-means clustering
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
