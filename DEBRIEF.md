### Part 1

This part cost me the largest amount of time, mostly due to up-front automation cost and how messy the HTML was. Once I abandoned getting the timestamps from the HTML and instead got it from the requests, it went much smoother. All the data can be found at: https://us-west-2.console.aws.amazon.com/s3/buckets/mjw-cloudquest-bls-data

As far as what I would do differently - the lambda logic for acquiring the files is a bit too reliant on the HTML and metadata, and changes to the front end could cause some churn or duplicate files. More logic to resolve issues like changed filenames or patterns, as well as more unit tests, might help.

### Part 2

Fairly straightforward, no issues. Could use some additional data cleansing logic but that might be too heavy-handed for a lambda.

### Part 3

Initially I wanted to do this with PySpark on EMR, but since I wanted to stick with free tier I went with Sagemaker. PySpark struggled to get running, and after I couldn't connect to S3 I gave up and switched to Pandas. As the FAQ mentioned, lots of data quality issues, but once I cleared those it was pretty simple. Notebook and rendered Markdown is available at the reports directory.

### Part 4

I am still working through this as of late 5/28 evening, but overall a few notes about the prescribed process: a Lambda is not an ideal setting for running these reports, as the size limit prevents loading Pandas and/or PySpark into the environment. I am planning to just do question 1 (population metrics) using numpy by passing in the new JSON file into the Lambda event. I also do not recommend (from painful personal experience) using SQS to manage data pipelines/triggers, due to messy permissions settings, messages disappearing with little to no warning, and poor duplication handling. I will finish 5/29 if given time.

### Overall takeaways

-Very fun!

-Clearly I am not using "terraform validate" enough

-Github Actions are cool

-Upfront automation/IaC is costly but so so helpful
