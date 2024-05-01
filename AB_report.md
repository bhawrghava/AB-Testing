# A/B Test Report: Food and Drink Banner
GloBox is primarily known amongst its customer base for boutique fashion items and high-end decor products. To increase the revenue, the company is launched experiment to observe how the customer’s spending behavior with and without the advertisement. 
## Purpose
Extract the user-level aggregated dataset using SQL to enable EDA and hypothesis testing on python.
Analyze the A/B test results using statistical methods such as Z-test and t-test to check for any presence of randomness in the experiment.

## Hypotheses
Null_hypothesis:p1-p2=p0(pooled propotion) (for difference in propotions)
Alternative_hypothesis:p1!=p2

null_hypothesis: u1(mean)-u2(mean)=u0(zero) (for difference in avg spending betweens the group)
alternative hypothesis:u1-u2<>u0

## Methodology
### Test Design
- **Population:** A(group): 24343
                  B(group): 24600.
- **Duration:** Test start:2023-01-25, end dates:2023-02-06
- **Success Metrics:** conversion rate, average money spent.

## Results
### Data Analysis
- **Pre-Processing Steps:** I converted all the null values into zeros in the total spent column and converted the missing information in device, country, gender to not_available to protect loss of data. 

```sql

select id, coalesce(country,'not_available') as country,
coalesce(gender,'not_available') as gender,
coalesce(device,'not_available') as device,
new_ab.group,
total_spent,
whether_converted from
(select id,
u.country,
u.gender,
g.device,
g.group,
sum(coalesce(a.spent,0)) as total_spent,
case when sum(coalesce(a.spent,0))>0 then 1
else
0
end as whether_converted
from users u 
left join groups g
on 
u.id = g.uid
left join activity a
on 
u.id=a.uid
group by u.country,
u.gender,
g.device,
g.group,id
order by id desc) as new_ab;

```
- the second query was for advanced tasks (Novelty effect)

```sql
select sum(dt_ab.total_spent) as per_dt_spent,
dt_ab.join_dt,
dt_ab.group,
sum(dt_ab.count)
from (
select 
g.join_dt,
g.device,
g.group,
count(a.uid),
sum(coalesce(a.spent,0)) as total_spent,
case when sum(coalesce(a.spent,0))>0 then 1
else
0
end as whether_converted
from  activity a
left join groups g
on 
a.uid = g.uid
group by 
g.join_dt,
g.device,
g.group
order by join_dt asc) as dt_ab
group by dt_ab.join_dt,
dt_ab.group;

```

- **Statistical Tests Used:** Z-test for Two Proportions (for difference in propotions), t-test for difference in means.
- **Results Overview:** z-test:(p-value: 0.0001)(A p-value of 0.0001 indicates a very low probability of observing the difference in propotions (or more extreme) under the assumption that the null hypothesis is true. In statistical hypothesis testing, a smaller p-value suggests stronger evidence against the null hypothesis.)

T-test:(P-value: 0.9438497659410876)(A p-value is a statistical measure that helps assess the evidence against a null hypothesis. In our case, the reported p-value is 0.9438497659410876. We do not have enough evidence to reject the null hypothesis, and the data does not provide strong support for the alternative hypothesis.)

### Findings
The rate of conversion in both the groups A and B is higher in USA.
Females have better rate of conversion than males suggesting established female fanbase.
Nearly 70% of the conversion comes from the continent USA alone.
There is a 3% difference in revenue generated between the groups(only males), suggesting that males responded positively to the advertisement.
As expected most of the revenue is also generated from one continent America.
- **Outcome of the Test(s):** z-test : Z-statistic: -3.84
P-value: 0.0001
Two-tailed p-value: 0.0001
Reject the null hypothesis: There is a significant difference in proportions.

T-test:t-test for difference in means: T-statistic: -0.07
P-value: 0.94
Fail to reject the null hypothesis: There is no significant difference in mean total spent.

- **Confidence Level:** (95% confidence level)

## confidence intervals:
Confidence Interval(difference in propotions): (0.0034860511629807036, 0.010653593996359593)
Confidence Interval(difference in means): (-0.43866128111980474, 0.4713582370336893)

## Conclusions
- **Key Takeaways:** confidence interval (CI) includes zero, it generally suggests that the observed effect or difference is not statistically significant.

- **Limitations/Considerations:** Huge percentage of data comes from continent America.
The given dataset has unavailable data which is a contraint for accurate analysis.
The sample is not big enough to observe minimum detectable difference in metric choosen(difference in conversion rate, difference in mean total spent between the groups)(evident from power analysis) and also to avoid novelty effect.


## Recommendations
- **Next Steps:** Dont launch the campaign. 
- **Further Analysis:** Conduct this experiment only in continent America to get better results and also to avoid outliers (the other countries are not contributing significantly in terms of revenue).
conduct this experiments with a bigger sample observe accurate and minimum detectable differences in metrics.

