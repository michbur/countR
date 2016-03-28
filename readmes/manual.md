---
output: 
  html_document: 
    self_contained: no
    theme: cerulean
---

# Overdispersion

One of the important features of the Poisson distribution is the equality of variance and expected value. Although count data should be Poisson-distributed, we often encounter overdispersed datasets, when the variance is bigger than the mean. Three distributions included in countR: Zero-Inflated Poisson (ZIP), Negative Binomial (NB) and Zero-negative Binomial (ZINB) model overdispersed counts. 

Overdispersion may be caused by the increased variability of counts, for example when a counting algorithm under- and overcounts. In such situation the data might have the NB distribution. The other cause of overdispersion is called zero-inflation and occurs in datasets, where some factor introduced faulty zeros. That means that some counts, regardless of their real state, are treated as zeros. In this case, data has the ZIP distribution.

# Overdispersed count data distributions

Parameters:

* $\lambda$ - Poisson parameter (average number of foci per cell).  
* $r$ - zero inflation (fraction of cells treated by system as having no foci regardless of their real state).  
* $\theta$ - dispersion parameter.
  
Usually the NB distribution is parameterized using $\mu$ and $\theta$, but to make comparison clearer, we use $\lambda$ instead of $\mu$. In this parameterization, NB and ZINB are treated as the mixture of Poisson and Gamma ($\Gamma$) distributions.  

Distribution name  | pmf 
-------------------|-------------
Poisson            |$$P\{X = k\} = \frac{\lambda^k \exp^{-\lambda}}{k!} $$
ZIP                |$$P\{X = k\} = \begin{cases} r + ( 1- r) \exp^{-\lambda},\text{if } k = 0\\ r \frac{\lambda^k \exp^{-\lambda}}{k!},\text{if } k = 1, 2, \ldots \end{cases} $$
NB                 |$$P\{X = k\} = \frac{\Gamma (\theta + k)}{\Gamma(\theta) k!}  \left(\left( \frac{\theta}{\theta + \lambda} \right)^\theta \left( \frac{\lambda}{\theta + \lambda} \right) \right)^k$$
ZINB               |$$P\{X = k\} = \begin{cases}r + (1 - r) \left( \frac{\theta}{\theta + \lambda} \right)^\theta,\text{if } k = 0\\(1 - r) \frac{\Gamma (\theta + k)}{\Gamma(\theta) k!}  \left(\left( \frac{\theta}{\theta + \lambda} \right)^\theta \left( \frac{\lambda}{\theta + \lambda} \right) \right)^k,\text{if } k = 1, 2, \ldots\end{cases}$$

Poisson and Negative Binomial distributions have the same expected value. In case of ZIP and ZINB, the expected value is smaller than the real average number of foci per cell.

Distribution name  | Expected value
-------------------|-------------
Poisson            |$$E(X) = \lambda $$
ZIP                |$$E(X) = (1 - r) \lambda $$
NB                 |$$E(X) = \lambda $$
ZINB               |$$E(X) = (1 - r)  \lambda $$  <!-- keep it here, because otherwise table parse oddly  -->

Depending on the value of $r$ the variance of ZIP and ZINB may be smaller or bigger than the variance of Poisson distribution. In case of the NB distribution, the variance is always bigger than for the Poisson distribution, although the difference becomes negligible, when the $\theta$ is much bigger than $\lambda^2$.

Distribution name  | Variance
-------------------|-------------
Poisson            |$$\textrm{var}(X) = \lambda $$
ZIP                |$$\textrm{var}(X) = \lambda (1 - r)(1 + \lambda r)$$
NB                 |$$\textrm{var}(X) = \lambda + \frac{\lambda^2}{\theta} $$
ZINB               |$$\textrm{var}(X) = (1 - r) \lambda \left( 1 + r\lambda  + \frac{1}{\theta} \right)$$

 