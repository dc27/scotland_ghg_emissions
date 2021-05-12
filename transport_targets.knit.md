
<!-- rnb-text-begin -->

---
title: "R Notebook"
output: html_notebook
---



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxubGlicmFyeSh0aWR5dmVyc2UpXG5cbmBgYCJ9 -->

```r
library(tidyverse)

```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiUmVnaXN0ZXJlZCBTMyBtZXRob2RzIG92ZXJ3cml0dGVuIGJ5ICdkYnBseXInOlxuICBtZXRob2QgICAgICAgICBmcm9tXG4gIHByaW50LnRibF9sYXp5ICAgICBcbiAgcHJpbnQudGJsX3NxbCAgICAgIFxuLS0gQXR0YWNoaW5nIHBhY2thZ2VzIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tIHRpZHl2ZXJzZSAxLjMuMCAtLVxudiB0aWJibGUgIDMuMS4wICAgICB2IGZvcmNhdHMgMC41LjBcbnYgdGlkeXIgICAxLjEuMiAgICAgXG5wYWNrYWdlIJF0aWJibGWSIHdhcyBidWlsdCB1bmRlciBSIHZlcnNpb24gNC4wLjQtLSBDb25mbGljdHMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0gdGlkeXZlcnNlX2NvbmZsaWN0cygpIC0tXG54IHBsb3RseTo6ZmlsdGVyKCkgbWFza3MgZHBseXI6OmZpbHRlcigpLCBzdGF0czo6ZmlsdGVyKClcbnggZHBseXI6OmxhZygpICAgICBtYXNrcyBzdGF0czo6bGFnKClcbiJ9 -->

```
Registered S3 methods overwritten by 'dbplyr':
  method         from
  print.tbl_lazy     
  print.tbl_sql      
-- Attaching packages -------------------------------------------------------------------------- tidyverse 1.3.0 --
v tibble  3.1.0     v forcats 0.5.0
v tidyr   1.1.2     
package 㤼㸱tibble㤼㸲 was built under R version 4.0.4-- Conflicts ----------------------------------------------------------------------------- tidyverse_conflicts() --
x plotly::filter() masks dplyr::filter(), stats::filter()
x dplyr::lag()     masks stats::lag()
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


|Outcome|	Indicator|	On-Track Assessment (Milestones/ Targets)|
|-|---|---|
|1|	% reduction in car kilometres a	|Progress to target [20% reduction by 2030]|
|2|	% of new car registrations that are ULEV b	|Year-to-year change|
|2|	% of new van registrations that are ULEV b	|Year-to-year change|
|3|	% of new HGV registrations that are ULEV b	|Year-to-year change|
|4|	% of new bus registrations that are ULEV b	|Progress to target [>50% by 2024]|

|5|	% reduction in emissions from scheduled flights within Scotland c	|Year-to-ye
ar change|
|6|	% of ferries that are low emissions d	|Progress to target [30% by 2032]|
|8|	% of single track kilometres electrified e	|Progress to target [70% by 2034]|
|8|	% of trains powered by alternative traction e	|Year-to-year change|


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxudGFyZ2V0cyA8LSB0aWJibGUoXG4gIHRhcmdldCA9IGMoXCJOZXdseSByZWdpc3RlcmVkIHZlaGljbGVzIHJlZ2lzdGVyZWQgdGhhdCBhcmUgVUxFVlwiLCBcIlJlZHVjdGlvbiBpbiBjYXIgS2lsb21ldGVyc1wiKSxcbiAgZ29hbCA9IGMoMTAwLCAwLjgqNTAwKSxcbiAgY3VycmVudF92YWx1ZSA9IGMoMiwgLTEwMClcbilcblxudGFyZ2V0cyAlPiUgXG4gIGdncGxvdCgpICtcbiAgYWVzKHggPSB0YXJnZXQsIHkgPSAoY3VycmVudF92YWx1ZS9nb2FsKSoxMDApICtcbiAgZ2VvbV9jb2woZmlsbCA9IFwiZ3JlZW5cIikgK1xuICBnZW9tX2NvbChhZXMoeCA9IC5kYXRhW1tcInRhcmdldFwiXV0sIHkgPSAxMDApLCBmaWxsID0gXCJ3aGl0ZVwiLCBjb2xvdXIgPSBcImJsYWNrXCIsIGFscGhhID0gMC41KSArXG4gIGNvb3JkX2ZsaXAoKSArXG4gIHlsaW0oMCwxMDApICtcbiAgdGhlbWVfdm9pZCgpICtcbiAgZ2VvbV90ZXh0KGFlcyh4ID0gLmRhdGFbW1widGFyZ2V0XCJdXSwgeSA9IDUwLCBsYWJlbCA9IC5kYXRhW1tcInRhcmdldFwiXV0pLCBzaXplID0gNilcbmBgYCJ9 -->

```r
targets <- tibble(
  target = c("Newly registered vehicles registered that are ULEV", "Reduction in car Kilometers"),
  goal = c(100, 0.8*500),
  current_value = c(2, -100)
)

targets %>% 
  ggplot() +
  aes(x = target, y = (current_value/goal)*100) +
  geom_col(fill = "green") +
  geom_col(aes(x = .data[["target"]], y = 100), fill = "white", colour = "black", alpha = 0.5) +
  coord_flip() +
  ylim(0,100) +
  theme_void() +
  geom_text(aes(x = .data[["target"]], y = 50, label = .data[["target"]]), size = 6)
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJoZWlnaHQiOjQzMi42MzI5LCJ3aWR0aCI6NzAwLCJzaXplX2JlaGF2aW9yIjowLCJjb25kaXRpb25zIjpbWzEsIlJlbW92ZWQgMSByb3dzIGNvbnRhaW5pbmcgbWlzc2luZyB2YWx1ZXMgKHBvc2l0aW9uX3N0YWNrKS4iXV19 -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->




<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxudHJhbnNwb3J0X3RhcmdldHMgPC0gdGliYmxlKCkgXG5cbm91dGNvbWVfaWQgPC0gMTo4XG5cbm91dGNvbWUgPC0gYyhcIlRvIGFkZHJlc3Mgb3VyIG92ZXJyZWxpYW5jZSBvbiBjYXJzLCB3ZSB3aWxsIHJlZHVjZSBjYXIga2lsb21ldHJlcyBieSAyMCUgYnkgMjAzMC5cIixcbiAgICAgICAgICAgICBcIldlIHdpbGwgcGhhc2Ugb3V0IHRoZSBuZWVkIGZvciBuZXcgcGV0cm9sIGFuZCBkaWVzZWwgY2FycyBhbmQgdmFucyBieSAyMDMwXCIsXG4gICAgICAgICAgICAgXCJUbyByZWR1Y2UgZW1pc3Npb25zIGluIHRoZSBmcmVpZ2h0IHNlY3Rvciwgd2Ugd2lsbCB3b3JrIHdpdGggdGhlIGluZHVzdHJ5IHRvIHVuZGVyc3RhbmQgdGhlIG1vc3QgZWZmaWNpZW50IG1ldGhvZHMgYW5kIHJlbW92ZSB0aGUgbmVlZCBmb3IgbmV3IHBldHJvbCBhbmQgZGllc2VsIGhlYXZ5IHZlaGljbGVzIGJ5IDIwMzUuXCIsXG4gICAgICAgICAgICAgXCJXZSB3aWxsIHdvcmsgd2l0aCB0aGUgbmV3bHkgZm9ybWVkIEJ1cyBEZWNhcmJvbmlzYXRpb24gVGFza2ZvcmNlLCBjb21wcmlzZWQgb2YgbGVhZGVycyBmcm9tIHRoZSBidXMsIGVuZXJneSBhbmQgZmluYW5jZSBzZWN0b3JzLCB0byBlbnN1cmUgdGhhdCB0aGUgbWFqb3JpdHkgb2YgbmV3IGJ1c2VzIHB1cmNoYXNlZCBmcm9tIDIwMjQgYXJlIHplcm8tZW1pc3Npb24sIGFuZCB0byBicmluZyB0aGlzIGRhdGUgZm9yd2FyZCBpZiBwb3NzaWJsZS5cIixcbiAgICAgICAgICAgICBcIldlIHdpbGwgd29yayB0byBkZWNhcmJvbmlzZSBzY2hlZHVsZWQgZmxpZ2h0cyB3aXRoaW4gU2NvdGxhbmQgYnkgMjA0MC5cIixcbiAgICAgICAgICAgICBcIlByb3BvcnRpb24gb2YgZmVycmllcyBpbiBTY290dGlzaCBHb3Zlcm5tZW50IG93bmVyc2hpcCB3aGljaCBhcmUgbG93IGVtaXNzaW9uIGhhcyBpbmNyZWFzZWQgdG8gMzAlIGJ5IDIwMzIuXCIsXG4gICAgICAgICAgICAgXCJCeSAyMDMyIGxvdyBlbWlzc2lvbiBzb2x1dGlvbnMgaGF2ZSBiZWVuIHdpZGVseSBhZG9wdGVkIGF0IFNjb3R0aXNoIHBvcnRzXCIsXG4gICAgICAgICAgICAgXCJTY290bGFuZOKAmXMgcGFzc2VuZ2VyIHJhaWwgc2VydmljZXMgd2lsbCBiZSBkZWNhcmJvbmlzZWQgYnkgMjAzNS5cIilcblxudHJhbnNwb3J0IDwtIHRpYmJsZShcbiAgb3V0Y29tZV9pZCxcbiAgb3V0Y29tZVxuKVxuXG50cmFuc3BvcnRcbmBgYCJ9 -->

```r
transport_targets <- tibble() 

outcome_id <- 1:8

outcome <- c("To address our overreliance on cars, we will reduce car kilometres by 20% by 2030.",
             "We will phase out the need for new petrol and diesel cars and vans by 2030",
             "To reduce emissions in the freight sector, we will work with the industry to understand the most efficient methods and remove the need for new petrol and diesel heavy vehicles by 2035.",
             "We will work with the newly formed Bus Decarbonisation Taskforce, comprised of leaders from the bus, energy and finance sectors, to ensure that the majority of new buses purchased from 2024 are zero-emission, and to bring this date forward if possible.",
             "We will work to decarbonise scheduled flights within Scotland by 2040.",
             "Proportion of ferries in Scottish Government ownership which are low emission has increased to 30% by 2032.",
             "By 2032 low emission solutions have been widely adopted at Scottish ports",
             "Scotland’s passenger rail services will be decarbonised by 2035.")

transport <- tibble(
  outcome_id,
  outcome
)

transport
```

<!-- rnb-source-end -->

<!-- rnb-frame-begin eyJtZXRhZGF0YSI6eyJjbGFzc2VzIjpbInRibF9kZiIsInRibCIsImRhdGEuZnJhbWUiXSwibnJvdyI6OCwibmNvbCI6Mn0sInJkZiI6Ikg0c0lBQUFBQUFBQUJvMVVUVzhUTVJEZHBsOFFDWVRVUHpBWGJtMVVFaXB4cktBQ3dha0NwSEpEem5vMmErSzFJOXViSlp6NERmd2FmaG9IMVBMczlhYTA0c0RCaVQzMnZIbnZqZGZ2THo3TnhwL0dSVkhzRm5zWXUvdVlGZ2V2THA5Tno2WkZzVGZDYWdjN0QrUC9WNXc2d2lRR0gyRThTSnY5ZWhkakR5UG1IMkFjNXYwbjZiOEhlUC9Sa3BEU3NmZGtXMGQyemM2eFZzS1VUTlpRS1p3L3BvNnBVMXFUWTlraWppQXRsYllOQnlUU2ZFUFQwNmY5Myt4MGtwSGZYZVdrVlMwOHNOcEFvV1l5ekpJcTZ6RHBhQVVBcTBrWVNWS3haNTNxcGZWYUdEOUFac1NmNEpvWmNLTzhWeFpIbEVtd2xXTzFxQU41TG9OMXQ0dzc2NWFZaFRxZFVrYTJQcmdOQlV1dGtleDhpTFhpVm1OOUlLNHFWU28yZ1NDdHRyS240cmlCTGYvRHZtYXgzdENhYTFYcXdaaloyZURJNzZ0L2tnS1Uza1RRQnRndlcwOFhEQmZtMWlndkFqVFNSK0dYMkM3NW1FcmJySnp5T0dncjBpeWlCR2kzVFVLYXQrZ1ZHM2FMVFdKVktaUDYySnVDUGNobTQxc1h4WWkrSDQzNFlwMEttd2dZUlFFRHpGZXRLMlBiWkE4K1BaMCtKNEcwYit6c3lXRCtjU29DekxsVFpnRTA1VW1Ld0ZGTEo1d2tWZEhLNHVoYzgrREI2enNlSUZkdXhZSm5XYU85T2xiVnNacyttWVFPZnlodDBMRlljdlQ1OW80dEw1MWRXWmRjQXY4S2R4ZU5vSndSbEsvcFRielJwb2s5dFIyczhiVmFVWWNHMVVtUXR0MzJNaEVVSTdkMG5KU0QzR3g3cmFkRHliY3YrL1hkVEc5MUc5SjlyQVd1eXB6WmdMdGtORlpJdXdxQWc5OWJVcEd6TDRyekNIZytpUHNCMjRYM2JCYnN5QW1sMFRlM1ZpWDczckU1LzIyV3ZMMWRkNStFZlNNYTl2a3pIK1hnR0o4ZjdnNS9WakpIRG5Qa1h2WkRaN3ZKZ0JBZmxORjMvTnpjM1B5Nlg2YlVJSnZMRE1FeDJpOG1sUk1SdDdpK2wzSUlJNkpIQUQzS3o5TGZ5VHZ1WHVCSmF5SVRlVkxXclZtZXpGN0VDdmw5S3pLOW5meW1EZk5SWDNOMGs3SDJNOVlCYkZXR0IvSmF6Rm5ueFdOSVRvb24rTFJNR0tRZzZpZkJCakdjRzVkV0Q1RWtycmorQXdOMlEyT3JCUUFBIn0= -->

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["outcome_id"],"name":[1],"type":["int"],"align":["right"]},{"label":["outcome"],"name":[2],"type":["chr"],"align":["left"]}],"data":[{"1":"1","2":"To address our overreliance on cars, we will reduce car kilometres by 20% by 2030."},{"1":"2","2":"We will phase out the need for new petrol and diesel cars and vans by 2030"},{"1":"3","2":"To reduce emissions in the freight sector, we will work with the industry to understand the most efficient methods and remove the need for new petrol and diesel heavy vehicles by 2035."},{"1":"4","2":"We will work with the newly formed Bus Decarbonisation Taskforce, comprised of leaders from the bus, energy and finance sectors, to ensure that the majority of new buses purchased from 2024 are zero-emission, and to bring this date forward if possible."},{"1":"5","2":"We will work to decarbonise scheduled flights within Scotland by 2040."},{"1":"6","2":"Proportion of ferries in Scottish Government ownership which are low emission has increased to 30% by 2032."},{"1":"7","2":"By 2032 low emission solutions have been widely adopted at Scottish ports"},{"1":"8","2":"Scotland’s passenger rail services will be decarbonised by 2035."}],"options":{"columns":{"min":{},"max":[10],"total":[2]},"rows":{"min":[10],"max":[10],"total":[8]},"pages":{}}}
  </script>
</div>

<!-- rnb-frame-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



reduce car kms by 20% - 2030
reduce new petrol and diesel cars by - 2030
reduce new petrol and diesel heavy vehicles - 2035
51% new buses purchased from 2024 are zero emissions
decarbonise scottish flights - 2040
SG owned ferries which are low emission = 30% - 2032

<!-- rnb-text-end -->

