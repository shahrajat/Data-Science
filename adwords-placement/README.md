# Adwords-placement
AdWords Placement Problem via Online Bipartite Graph Matching<br/>
<br/>
<p>Problem: Given a set of advertisers each of whom has a daily budget B_{i}. When a user performs a query, an ad request is placed online and a group of advertisers can then bid for that advertisement slot. The bid of advertiser 'i' for an ad request 'q' is denoted as b_{iq}. We assume that the bids are small with respect to the daily budgets of the advertisers (i.e., for each
'i' and 'q', b_{iq} much less than B_{i}). Moreover, each advertisement slot can be allocated to at most one advertiser and the advertiser is charged his bid from his/her budget. The objective is to maximize the amount of money received from the advertisers.</p>
<br/>
For this project, we make the following simplifying assumptions:<br/>
1. For the optimal matching (used for calculating the competitive ratio), we will assume everyone's budget is completely used.<br/>
2. The bid values are fixed (unlike in the real world where advertisers normally compete by incrementing their bid by 1 cent).<br/>
3. Each ad request has just one advertisement slot to display.<br/>

Three different algorithms have been applied to decide how to allot the ad slot to the advertisers for each incoming query.<br/>
1. Greedy algorithm<br/>
2. Balance algorithm<br/>
3. MSVV algorithm<br/>

Acknowledgement: <br/>
The project definition and the datasets have been provided by Dr. Nagiza Samatova.
