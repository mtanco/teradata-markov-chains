# Building First Order Markov Chains - Using nPath in Teradata 16.20

nPath, a path and pattern analytic function, now runs natively in Teradata 16.20. In addition to looking for common paths to and from key pages, we can use nPath to build first order markov chains in a sigle pass of the data. Markov chains allow us to understand the probability of moving from one event to another; we can take the product of probabilities for a given series of event to say "how likely" it was to occur in the model. We can also build multiple models for different segments of the data to say which segment a new series is most like, and which event we are most likely to see next. 

## Getting Started

This repo includes code and a small sample set for doing exploritory path analysis,  building markov chains off of time series data, and applying these models to some common use cases.

### Prerequisites

* nPath runs natively in Teradata 16.20, this database version is necessary to run this code
* The code in this repo can be modified to run on any time series data which has at least the following 3 columns: session identifier, event, order of events in the session. [This](sample_data.csv) small sample set will allow the repo code to run as-is. 

## Authors

* [Michelle Tanco](https://github.com/mtanco) - *Initial work* - michelle.tanco@teradata.com

## Acknowledgments

* Props to [Russell Ratshin](https://www.linkedin.com/in/rratshin) for the data set 


