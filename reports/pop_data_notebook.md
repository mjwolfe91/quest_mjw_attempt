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
df_pr
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


