use HospitalityDb;


/*1st Dashboard all queries */
 
 --REVENUE REALISED;
 SELECT SUM(revenue_realized) as Total_Revenue_Realiazed
 from fact_bookings;
 --Total Revenue Genrated 
 select sum(revenue_generated) as Total_Revenue_generated 
 from fact_bookings;

 --ADR (avg daily revenue ) 
 select Round(sum(revenue_realized)*1.0/count(booking_id),2)as avg_daily_revenue_ADR
 from fact_bookings;
 
 -- RVPAR revenue per room  
 select  ROUND(SUM(fb.revenue_generated) * 1.0 / SUM(fab.capacity), 2)  AS RevPAR  
 from fact_aggregated_bookings fab inner join fact_bookings fb
ON fb.property_id = fab.property_id 
	 AND fb.room_category = fab.room_category 
  AND fb.check_in_date = fab.check_in_date
; 





--revenue by hotel/city 
select sum(fb.revenue_realized) as total_revenue,dh.city,dh.property_name
from fact_bookings fb inner join dim_hotels dh
on fb.property_id=dh.property_id
where fb.booking_status = 'Checked Out'
group by dh.city,dh.property_name;

--revenue by plathform
SELECT booking_platform, SUM(revenue_realized) AS total_revenue
FROM fact_bookings
WHERE booking_status = 'Checked Out'
GROUP BY booking_platform
ORDER BY total_revenue DESC;

--roomclass 
SELECT r.room_class, SUM(b.revenue_realized) AS total_revenue
FROM fact_bookings b
JOIN dim_rooms r ON b.room_category = r.room_id
WHERE b.booking_status = 'Checked Out'
GROUP BY r.room_class;

-- revenue week trend
SELECT d.mmm_yy as month, SUM(b.revenue_realized) AS monthly_revenue
FROM fact_bookings b
JOIN dim_date d ON b.booking_date = d.date
WHERE b.booking_status = 'Checked Out'
GROUP BY d.mmm_yy
ORDER BY MIN(d.date);

--ACCORDING WEEK 
SELECT 
  d.day_type,               -- Weekend / Weekday
  SUM(b.revenue_realized) AS total_revenue
FROM fact_bookings b
JOIN dim_date d 
  ON b.check_in_date = d.date
WHERE b.booking_status = 'Checked Out'
GROUP BY d.day_type;


 
/* Dashboard 2 Queries */
select count(booking_id) as Total_bookings
from fact_bookings;

select count(booking_id) cancelled_bookings
from fact_bookings
where booking_status='cancelled';

/* checked out / cancelled out / no show% */
SELECT booking_status,COUNT(*) AS total_bookings,
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings), 2) AS percentage
FROM fact_bookings
GROUP BY booking_status;


/*occupancy rate */
select CAST(SUM(SUCCESSFUL_BOOKINGS)*100 AS float)/NULLIF(SUM(capacity),0) AS OCCUPANCY_RATE
from fact_aggregated_bookings;

/*ROOM NIGHT BOOKED*/

SELECT SUM(DATEDIFF(DAY,CHECK_IN_DATE,CHECKOUT_DATE)) DBRN_ROOM_NIGHT_BOOKED
FROM FACT_BOOKINGS
WHERE booking_status='CHECKED OUT';

/*AVG STAY DURATION DURN*/
SELECT AVG(DATEDIFF(DAY,CHECK_IN_DATE,CHECKOUT_DATE)) DURN_AVG_STAY_DURATION
FROM FACT_BOOKINGS
WHERE booking_status='CHECKED OUT';

/*AVG_GUESTS_PER_BOOKING*/
SELECT AVG(no_guests) AS avg_guests_per_booking
FROM fact_bookings
WHERE booking_status = 'Checked Out';


/* TOTAL ROOM BOOKINGS PER ROOM Class*/
SELECT room_class, COUNT(booking_id) AS total_bookings_per_room
FROM fact_bookings 
INNER JOIN dim_rooms 
ON room_category = room_id
GROUP BY room_class;

/*BOOKING BY PLATFORM*/
SELECT COUNT(booking_id)AS BOOKING_ID,booking_platform
FROM fact_bookings
GROUP BY booking_platform
ORDER BY BOOKING_ID DESC;

/*BOOKING TREND  OVER TIME */
--ACCORDING WEEK 
SELECT COUNT(BOOKING_ID) AS BOOKING_TREND,WEEK_NO
FROM fact_bookings INNER JOIN dim_date ON booking_date = date 
GROUP BY WEEK_NO;
-- ACCORDING TO MONTH 
SELECT 
  d.mmm_yy AS month,
  COUNT(b.booking_id) AS total_bookings
FROM fact_bookings b
INNER JOIN dim_date d ON b.booking_date = d.date
GROUP BY d.mmm_yy
ORDER BY MIN(d.date);
