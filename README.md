DegreeCalculator
================

[![GitHub CI](https://github.com/eskil/DegreeCalculator/actions/workflows/xcode-unit-tests.yml/badge.svg)](https://github.com/eskil/DegreeCalculator/actions/workflows/xcode-unit-tests.yml)
[![Last Updated](https://img.shields.io/github/last-commit/eskil/DegreeCalculator.svg)](https://github.com/eskil/DegreeCalculator/commits/master)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A simple degree-minutes(fractions) add/subtract calculator.

This is written for celestial navigation using tables. The features are

* support degrees in degree and minutes, with minutes as a fraction, eg. 30°02'3
* support time as hours-minutes-seconds, eg. 10h20m03
* add/subtract 
* division by integer for averaging observations

It was also for me to experiment with and try learning some Swift and SwiftUI.

![screenshot showing app in basic use](Screenshot-v2-base.png?raw=true "screenshot showing app" in basic use)
![screenshot showing app doing division](Screenshot-v2-div.png?raw=true "screenshot showing app doing division")
![screenshot showing app in hours-minutes-seconds](Screenshot-v2-hms.png?raw=true "screenshot showing app in hours-minutes-seconds")

Todo

- [x] unit tests for DegreeCore
- [x] unit tests for ModelData's functions
- [x] treat op without input as ANS

Bugs
- [ ] disallow > 3 ints for degrees when typing
- [x] if entering 600'0, it displays 0d00'0 instead of 10d00'0
