USE ipl;

SELECT * FROM ipl_bidder_details limit 5;
SELECT * FROM ipl_bidder_points limit 5;
SELECT * FROM ipl_bidding_details limit 5;
SELECT * FROM ipl_match limit 5;
SELECT * FROM ipl_match_schedule limit 5;
SELECT * FROM ipl_player limit 5;
SELECT * FROM ipl_stadium limit 5;
SELECT * FROM ipl_team limit 5;
SELECT * FROM ipl_team_players limit 5;
SELECT * FROM ipl_team_standings limit 5;
SELECT * FROM ipl_tournament limit 5;
SELECT * FROM ipl_user limit 5;


#1
SELECT bd.bidder_id,brd.bidder_name,bd.No_of_wins,bp.no_of_bids, ((bd.No_of_wins/bp.no_of_bids) * 100) AS Per_of_Wins
FROM ipl_bidder_points bp
INNER JOIN 
(SELECT bidder_id,count(bid_status) AS No_of_wins
FROM ipl_bidding_details 
WHERE bid_status='Won'
GROUP BY bidder_id) bd
ON bd.bidder_id=bp.bidder_id
INNER JOIN ipl_bidder_details brd
ON brd.bidder_id=bp.bidder_id
ORDER BY Per_of_Wins DESC;


#2
SELECT t.team_id, t.team_name,count(bd.bid_team) AS No_of_bid_for_Team 
FROM ipl_bidding_details bd
INNER JOIN ipl_team t
ON t.team_id = bd.bid_team
GROUP BY t.team_id, t.team_name 
HAVING No_of_bid_for_Team = 
(SELECT count(*) AS Team_bids 
FROM ipl_bidding_details 
GROUP BY bid_team
ORDER BY Team_bids DESC limit 1)
OR No_of_bid_for_Team =
(SELECT count(*) AS Team_bids
FROM ipl_bidding_details 
GROUP BY bid_team
ORDER BY Team_bids limit 1)
ORDER BY No_of_bid_for_Team DESC;

#3
SELECT a.stadium_id,a.No_of_Matches_in_Stadium,b.Toss_and_win_matches,
((b.Toss_and_win_matches/a.No_of_Matches_in_Stadium)*100) AS Percentage_of_Wins
FROM
(SELECT ms.stadium_id,count(*) AS No_of_Matches_in_Stadium
FROM ipl_match_schedule ms
INNER JOIN ipl_match m
ON ms.match_id=m.match_id
AND ms.STATUS ='Completed'
GROUP BY ms.stadium_id) a
INNER JOIN 
(SELECT ms.stadium_id,count(m.match_id) AS Toss_and_win_matches
FROM ipl_match_schedule ms
INNER JOIN ipl_match m
ON ms.match_id=m.match_id
AND ms.STATUS ='Completed'
WHERE toss_winner = match_winner
GROUP BY ms.stadium_id) b
ON a.stadium_id = b.stadium_id
ORDER BY b.stadium_id;


#4
SELECT b.bid_team,a.team_name,b.No_of_Team_Bids
FROM ipl_team a
INNER JOIN
(
SELECT bid_team,COUNT(*) AS No_of_Team_Bids
FROM ipl_bidding_details 
WHERE Bid_team=
(
SELECT Team_id FROM ipl_team_standings
GROUP BY team_id
HAVING sum(matches_won)=
(SELECT sum(matches_won)
FROM ipl_team_standings
GROUP BY Team_id
ORDER by sum(matches_won) DESC LIMIT 1))
GROUP BY bid_team
) b
ON a.team_id=b.bid_team;

#5
SELECT t1.team_id,t1.team_name,t2.jump_in_runs, t2.Percentage_jump_in_runs
FROM ipl_team t1
INNER JOIN 
(
SELECT a.team_id,(b.total_points-a.total_points) AS jump_in_runs,
((b.total_points-a.total_points)/a.total_points * 100) AS Percentage_jump_in_runs
FROM
(SELECT team_id,tournmt_id,total_points 
FROM ipl_team_standings
WHERE tournmt_id='2017')a
INNER JOIN 
(SELECT team_id,tournmt_id,total_points 
FROM ipl_team_standings
WHERE tournmt_id='2018')b
ON a.team_id=b.team_id
ORDER BY Percentage_jump_in_runs DESC LIMIT 1
) t2
ON t1.team_id=t2.team_id;
