# Asana Takehome

The first step before any work or brainstorming can be done was to actually figure out which users are "adopted". [This gnarly nested query](https://github.com/danamkaplan/asana_takehome/blob/master/adopted_users.sql) should label all the user_ids that visited at least 3 times in one 7 day period. 

Created a csv from the query:

``` bash 
mysql -u interview --password=interview --database=interview -P 3306 -h data-challenge-9x.cswh4gchpi8n.us-east-1.rds.amazonaws.com < adopted_users.sql | tr '\t' ',' > adopted_users.csv
```

Then I considered what data came with the user table *(Initial thoughts in italics)*: 

* **name**: the user's name *-Probably not a useful signal.*
* **object_id**: the user's id *-Probably not a useful signal.*
* **email**: email address *-Maybe a useful signal - to perhaps segment work email from personal, but a little too much effort/time in the string filtering for a couple hour project.*
* **creation_source**: how their account was created. This takes on one of 5 values: *-Definitely an obvious categorical variable. Will include.*
 * PERSONAL_PROJECTS: invited to join another user's personal workspace
 * GUEST_INVITE: invited to an organization as a guest (limited permissions)
 * ORG_INVITE: invited to an organization (as a full member)
 * SIGNUP: signed up via asana.com
 * SIGNUP\_GOOGLE_AUTH: signed up using Google Authentication (using a Google email account for their login id)
* **creation_time**: when they created their account *-This variable could be used in many ways, segment by hour timebands, or workday hours, or simply day of week but like email, a little too much time, so I will pick to utilize this for weekend or not variable.*
* **last\_session\_creation_time**: unix timestamp of last login *-Last login doesnt seem to be early enough in the "funnel" timeframe to predict adoption. Going to leave out now.*
* **opted\_in\_to\_mailing\_list**: whether they have opted into receiving marketing emails *-Definitely an obvious categorical variable. Will include.*
* **enabled\_for\_marketing_drip**: whether they are on the regular marketing email drip *-Definitely an obvious categorical variable. Will include.*
* **org_id**: the organization (group of users) they belong to
invited_by_user_id: which user invited them to join (if applicable).
*-Hard to tell anything from the org id itself, but I thought maybe the size of the orginzation when the user joined might be interesting to consider.*

For the size of the org when a user joined, I just decided to do the work in [SQL again](https://github.com/danamkaplan/asana_takehome/blob/master/size_org_joined.sql) and grabbed the csv with:

```bash
mysql -u interview --password=interview --database=interview -P 3306 -h data-challenge-9x.cswh4gchpi8n.us-east-1.rds.amazonaws.com < size_org_joined.sql | tr '\t' ',' > size_org_joined.csv
```

My first inclination was "I am trying to predict a binary outcome (adopted or not). Let's make a logistic regression." Please look at the notebook for it [here](https://github.com/danamkaplan/asana_takehome/blob/master/Asana Users.ipynb). As you can see, the model was fairly week. The only two statistically significant take aways are: 

* Personal Projects as a signup lowers the odds of adoption by a factor of ~32.9% (compared to the base case of organic signup through asana.com) 
* For every unit bigger an org is when a user joins, the base odds will be multiplied/lower by a factor of ~49.7%

The problem I realized with this model (AFTER I did all the regression work of course) is we are using mostly categorical independent variables to predict a categorical outcome. You can see the model is a really bad fit to begin with (Pseudo R-squ. of 0.02423). Regressions are kind of in the language of hypothesis tests: "If I change to a different categorical label from the base case or go up on more unit in a continuous label, how will that predict Y and is it significant?" This question doesn't really have a solid "base case" (or maybe I don't know Asana's product well enough). Basically, I would use this method if we analyzed an experiment ran by Asana. 

The better way I should have started with is some plots and visual interpretation like [I quickly threw together with Tableau.] (https://public.tableau.com/views/Asana/CreationSource?:embed=y&:display_count=yes&:showTabs=y) Quick Points:

* All the plots are the same format
	* Blue Bars are total VOLUME of users who signed up
	* Orange line is total RATE of (adopted/total) users
* Creation Source
	* You can see the MASSIVE dip in the Personal Projects rate that I found with the regression. Sign up through Google and Guest Invites were the highest ratios 
* Enabled for Marketing
	* Only around 14.9% of total users enabled for Marketing and it only bumped up the adoption ratio by 0.07%
* Opted in to Mailing list
	*  ~25% of users opted in and there was still small ratio bump of 0.53% of adoption rate.
* Date
	* Most interestingly, the day of week of signup has relatively similar VOLUME of signups for each bin. (only around 100 user difference between days out of 12000). 
	* Wednesday, Saturday, and Sunday have the highest rates. 
	* (Naively assuming weekend signups are non-business orgs) The two points above illustrate that Asana has both a high amount of users and also potentially adopted users for both business orgs and non traditional teams or personal uses. 
* Size of Org
	* It is kindof fun to show my stat. from earlier (negative correlation with org size) by scrolling right. 
	* As the orange line (adoption rate) descends, you can see the org size (blue bar) increase sporadically. 
* **MAJOR TAKEAWAYS**
	*   Small teams (orgs) that invite users as guests or a user that signs up through google or organically to join a small org. have the highest potential to become adopted users. 
	*   Mailing lists and enabled for marketing while having a positive effect on adoption, it is too small to be significant. 

**Further Consideration** - Based on my points on this data set, if we actually wanted to actually predict adopted, I would use some sort of decision tree model. A lot of the signals are actually catergorical segmentation which lends well to decision trees for both accuracy and observation of the segments. 

This could also be looked at through a cohort lens. If Asana changes its product often, I would look at the adoption rate of cohorts in a reasonable time frame (30 days out from signup or so). For a deeper dive, segmenting those cohorts would by the above categories will also reveal better information about what purposes or intentions users have with the product that would make the adopted. 

