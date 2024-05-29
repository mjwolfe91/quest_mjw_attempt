```python
# imports/setup

import s3fs
import boto3
import json
import pandas as pd
from IPython.display import display

s3 = boto3.client('s3')
```


```python
# read data

df_pr = pd.read_csv('s3://mjw-cloudquest-bls-data/pr_data_0_Current', delimiter='\t')
df_pr = df_pr.rename(columns=lambda x: x.strip()) # whitespace in column names!!

pop_raw = s3.get_object(Bucket='mjw-cloudquest-bls-data', Key='pop_data/2024-05-29T00-35-33Z/data.json')
pop_data = json.loads(pop_raw['Body'].read().decode('utf-8'))
df_pop = pd.DataFrame(pop_data['data'])
```

    /home/ec2-user/anaconda3/envs/python3/lib/python3.10/site-packages/fsspec/registry.py:275: UserWarning: Your installed version of s3fs is very old and known to cause
    severe performance issues, see also https://github.com/dask/dask/issues/10276
    
    To fix, you should specify a lower version bound on s3fs, or
    update the current installation.
    
      warnings.warn(s3_msg)



```python
# Using the dataframe from the population data API (Part 2), generate the mean 
# and the standard deviation of the annual US population across the years [2013, 2018] inclusive.
df_pop_filtered = df_pop[df_pop['ID Year'] < 2019]
print(f"The mean of the populations from 2013 to 2018 is {df_pop_filtered['Population'].mean()}")
print(f"The standard deviation of the populations from 2013 to 2018 is {df_pop_filtered['Population'].std()}")
```

    The mean of the populations from 2013 to 2018 is 317437383.0
    The standard deviation of the populations from 2013 to 2018 is 4257089.5415293295



```python
#Using the dataframe from the time-series (Part 1), 
#For every series_id, find the best year: the year with the max/largest sum of "value" 
#for all quarters in that year. Generate a report with each series id, the best year for that series, 
#and the summed value for that year.
grouped = df_pr.groupby(['series_id', 'year', 'period'])['value'].sum().reset_index()

# Group by series id and year again, and find the year with the maximum sum for each series
best_years = grouped.groupby(['series_id', 'year'])['value'].sum().reset_index()
best_years = best_years.loc[best_years.groupby('series_id')['value'].idxmax()]

best_years[['series_id', 'year', 'value']]
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>series_id</th>
      <th>year</th>
      <th>value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>27</th>
      <td>PRS30006011</td>
      <td>2022</td>
      <td>20.500</td>
    </tr>
    <tr>
      <th>57</th>
      <td>PRS30006012</td>
      <td>2022</td>
      <td>17.100</td>
    </tr>
    <tr>
      <th>63</th>
      <td>PRS30006013</td>
      <td>1998</td>
      <td>704.125</td>
    </tr>
    <tr>
      <th>105</th>
      <td>PRS30006021</td>
      <td>2010</td>
      <td>17.600</td>
    </tr>
    <tr>
      <th>135</th>
      <td>PRS30006022</td>
      <td>2010</td>
      <td>12.500</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>8130</th>
      <td>PRS88003192</td>
      <td>2002</td>
      <td>282.800</td>
    </tr>
    <tr>
      <th>8180</th>
      <td>PRS88003193</td>
      <td>2023</td>
      <td>766.310</td>
    </tr>
    <tr>
      <th>8208</th>
      <td>PRS88003201</td>
      <td>2022</td>
      <td>36.100</td>
    </tr>
    <tr>
      <th>8237</th>
      <td>PRS88003202</td>
      <td>2022</td>
      <td>28.900</td>
    </tr>
    <tr>
      <th>8267</th>
      <td>PRS88003203</td>
      <td>2023</td>
      <td>582.496</td>
    </tr>
  </tbody>
</table>
<p>282 rows × 3 columns</p>
</div>




```python
#Using both dataframes from Part 1 and Part 2, generate a report 
#that will provide the value for series_id = PRS30006032 and period = Q01 
#and the population for that given year (if available in the population dataset)
df_pr_filtered = df_pr[df_pr['series_id'].str.strip() == 'PRS30006032']
df_pr_filtered = df_pr_filtered[df_pr_filtered['period'].str.strip() == 'Q01']
df_join = pd.merge(df_pr_filtered, df_pop, left_on='year', right_on='ID Year')
df_join[['series_id', 'year', 'period', 'value', 'Population']]
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>series_id</th>
      <th>year</th>
      <th>period</th>
      <th>value</th>
      <th>Population</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>PRS30006032</td>
      <td>2013</td>
      <td>Q01</td>
      <td>0.8</td>
      <td>311536594</td>
    </tr>
    <tr>
      <th>1</th>
      <td>PRS30006032</td>
      <td>2014</td>
      <td>Q01</td>
      <td>-0.1</td>
      <td>314107084</td>
    </tr>
    <tr>
      <th>2</th>
      <td>PRS30006032</td>
      <td>2015</td>
      <td>Q01</td>
      <td>-1.6</td>
      <td>316515021</td>
    </tr>
    <tr>
      <th>3</th>
      <td>PRS30006032</td>
      <td>2016</td>
      <td>Q01</td>
      <td>-1.4</td>
      <td>318558162</td>
    </tr>
    <tr>
      <th>4</th>
      <td>PRS30006032</td>
      <td>2017</td>
      <td>Q01</td>
      <td>0.7</td>
      <td>321004407</td>
    </tr>
    <tr>
      <th>5</th>
      <td>PRS30006032</td>
      <td>2018</td>
      <td>Q01</td>
      <td>0.4</td>
      <td>322903030</td>
    </tr>
    <tr>
      <th>6</th>
      <td>PRS30006032</td>
      <td>2019</td>
      <td>Q01</td>
      <td>-1.6</td>
      <td>324697795</td>
    </tr>
    <tr>
      <th>7</th>
      <td>PRS30006032</td>
      <td>2020</td>
      <td>Q01</td>
      <td>-6.7</td>
      <td>326569308</td>
    </tr>
    <tr>
      <th>8</th>
      <td>PRS30006032</td>
      <td>2021</td>
      <td>Q01</td>
      <td>1.2</td>
      <td>329725481</td>
    </tr>
    <tr>
      <th>9</th>
      <td>PRS30006032</td>
      <td>2022</td>
      <td>Q01</td>
      <td>5.6</td>
      <td>331097593</td>
    </tr>
  </tbody>
</table>
</div>




```python

```
