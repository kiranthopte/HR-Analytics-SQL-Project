USE mavenfuzzyfactory;
select user_id, COUNT(*)  from website_sessions where is_repeat_session=1 group by user_id having count(*)>=3 order by 2 desc ;
select distinct(is_repeat_session) from website_sessions;
desc mavenfuzzyfactory.website_sessions;
desc mavenfuzzyfactory.products_info;
desc mavenfuzzyfactory.orders;
desc mavenfuzzyfactory.order_items;
desc mavenfuzzyfactory.order_item_refunds;
select count(*) from products_info where product_name like "%The%";
select * from website_sessions where website_session_id=1059;
select * from website_pageviews where website_session_id=1059;
select * from orders where website_session_id=1059;
select distinct utm_source, utm_campaign from website_sessions where COALESCE(utm_source," ")<>"gsearch";
select distinct utm_source, utm_campaign from website_sessions where utm_source<>"gsearch";
select utm_source, device_type,utm_campaign, COUNT(*) from website_sessions group by utm_source, device_type,utm_campaign order by 4 desc;
select utm_source,utm_campaign,utm_content, count(DISTINCT(website_session_id)) from website_sessions group by utm_source, utm_campaign, utm_content order by 4 desc;

select COUNT(DISTINCT(order_item_refund_id)) from order_item_refunds;

select 
W.utm_source,W.utm_campaign,W.utm_content, count(DISTINCT(W.website_session_id)),count(DISTINCT(O.order_id)),COUNT(distinct (R.order_id)),
ROUND((count(DISTINCT(O.order_id))-COUNT(distinct (R.order_id)))*100/count(DISTINCT(W.website_session_id)),2) as conversion_percent
from website_sessions as w 
left join orders as O on W.website_session_id=O.website_session_id
left join order_item_refunds as R on O.order_id=R.order_id
group by 1,2,3 order by 4 desc,5 desc ;

select distinct(date(created_at)) , COUNT(distinct(website_session_id)) from website_sessions  where date(created_at)< "2012-04-12" group by 1  order by 1 asc;

select count(DISTINCT(website_session_id))  from website_sessions where created_at<"2012-04-12" ;

select utm_source,utm_campaign,http_referer, count(DISTINCT(website_session_id)) from website_sessions where created_at <"2012-04-12"
group by utm_source, utm_campaign, http_referer order by 4 desc;


select date(created_at), utm_content, device_type, count(DISTINCT(website_session_id)) from website_sessions 
where created_at<"2012-04-12" and utm_source="gsearch" and utm_campaign="nonbrand" and http_referer="https://www.gsearch.com"
group by 1,2,3;


desc website_sessions;
desc orders;
desc order_items;


select W.device_type,COUNT(distinct(W.website_session_id)) as total_sessions,COUNT(distinct(O.order_id)) as total_orders,
ROUND(COUNT(distinct(O.order_id))*100/COUNT(distinct(W.website_session_id)),2) as conversion_rate
 from website_sessions as W
left join orders as O on W.website_session_id=O.website_session_id where date(W.created_at)<"2012-05-11" and W.utm_source="gsearch" and W.utm_campaign="nonbrand"
group by 1 order by 4 desc,3 desc;


select W.device_type,count(distinct(W.website_session_id)) from website_sessions as W where date(W.created_at)<"2012-05-11" and utm_source="gsearch" and utm_campaign="nonbrand"
group by 1 order by 2 desc;


select W.device_type, count(DISTINCT(order_id)) from orders as O 
left join website_sessions as W on O.website_session_id=W.website_session_id 
where date(W.created_at)<"2012-05-11" and W.utm_source="gsearch" and W.utm_campaign="nonbrand"
GROUP By 1;


select --year(created_at) as year, --week(created_at) as no_of_week, 
min(date(created_at)) as week_start_date,
max(date(created_at)) as week_end_date,
count(DISTINCT(case when device_type="desktop" then website_session_id else null end)) as desktop_sessions,
count(DISTINCT(case when device_type="mobile" then website_session_id else null end)) as mobile_sessions,
COUNT(DISTINCT(website_session_id)) as total_sessions,
ROUND(count(DISTINCT(case when device_type="desktop" then website_session_id else null end))*100/COUNT(DISTINCT(website_session_id)),2) as percent_desktop_sessions
from website_sessions 
where date(created_at) <"2012-06-09" and date(created_at) > "2012-04-15" and utm_source="gsearch" and utm_campaign="nonbrand"
GROUP by year(created_at), week(created_at) order by 1 asc;

select COUNT(distinct(website_session_id)) as total_sessions
from website_sessions
where date(created_at) <"2012-06-09" and date(created_at) > "2012-04-15" and utm_source="gsearch" and utm_campaign="nonbrand";

select date(created_at), COUNT(distinct(website_session_id)) as total_sessions
from website_sessions
where created_at <"2012-03-30" and created_at>"2012-03-22"
GROUP by date(created_at);

select min(date(created_at)) as week_start_date,
max(date(created_at)) as week_end_date, 
count(DISTINCT(case when COALESCE(utm_campaign," ")<>"brand" then website_session_id else null END)) as count_non_brand,
count(DISTINCT(case when utm_campaign="brand" then website_session_id else null END)) as count_brand,
count(DISTINCT(website_session_id)) as count_sessions
from website_sessions
group by year(created_at),quarter(created_at),MONTH(created_at),week(created_at)
ORDER BY 5 DESC
LIMIT 10,2;
           
select distinct(order_id), count(distinct(website_session_id)) from orders
where order_id between 15000 and 40000
group by 1 
having count(distinct(website_session_id))<> 1
order by 2 desc
;      
desc order_item_refunds;
select DISTINCT(user_id) , count(DISTINCT website_session_id)
from website_sessions 
group by user_id;

select order_id , SUM(refund_amount_usd) from order_item_refunds
group by order_id
having SUM(refund_amount_usd) = AVG(refund_amount_usd);

desc orders;
desc website_pageviews;
select distinct(pageview_url) from website_pageviews;

--Calculate bounce rate for home page

create TEMPORARY table min_views_id
select website_session_id, min(website_pageview_id) as min_pageview_id from website_pageviews where created_at <"2012-06-14" and pageview_url="/home"
group by 1 ;     
select * from min_views_id;
drop table min_views_id;

create TEMPORARY TABLE WEB_SESSIONS
select min_views_id.website_session_id from min_views_id
left join website_pageviews on min_views_id.min_pageview_id=website_pageviews.website_pageview_id;

create TEMPORARY table count_pageviews
select WEB_SESSIONS.website_session_id as sessions_id, count(website_pageviews.website_pageview_id) from WEB_SESSIONS 
left join website_pageviews on website_pageviews.website_session_id=WEB_SESSIONS.website_session_id 
group by 1
having count(website_pageviews.website_pageview_id)=1;
drop table bounde_rate;

create TEMPORARY table cent_bounce_rate
select COUNT(DISTINCT(WEB_SESSIONS.website_session_id)) as sessions, count(DISTINCT(count_pageviews.sessions_id)) as bounced_sessions, 
count(DISTINCT(count_pageviews.sessions_id))/COUNT(DISTINCT(WEB_SESSIONS.website_session_id)) as bounce_rate
from WEB_SESSIONS left join count_pageviews on count_pageviews.sessions_id=WEB_SESSIONS.website_session_id
;

select * from cent_bounce_rate;

--most viewed website pages
select DISTINCT(pageview_url), count(DISTINCT(website_pageview_id)) from website_pageviews where created_at <"2012-06-09" 
group by 1 order by 2 desc;
use hr_operations;
show tables;
select * from countries;
select * from departments;
select * from dependents;
select * from employees;
select * from jobs;
select * from locations;
select * from regions;
desc countries;
