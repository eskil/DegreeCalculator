DegreeCalculator
================

[![GitHub CI](https://github.com/eskil/DegreeCalculator/actions/workflows/xcode-unit-tests.yml/badge.svg)](https://github.com/eskil/DegreeCalculator/actions/workflows/xcode-unit-tests.yml)
[![Last Updated](https://img.shields.io/github/last-commit/eskil/DegreeCalculator.svg)](https://github.com/eskil/DegreeCalculator/commits/master)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A simple degree/minutes(fractions) add/subtract calculator.

This is written for celestial navigation using tables, so the requirements are
* only add/subtract 
* minutes as fractions

It was also for me to experiment with and try learning some Swift and SwiftUI.

![screenshot showing app in use](Screenshot.png?raw=true "screenshot showing app")

Todo

- [x] unit tests for DegreeCore
- [ ] unit tests for ModelData's functions
- [x] treat op without input as ANS

Bugs
- [ ] disallow > 3 ints for degrees when typing
- [ ] if entering 600'0, it displays 0d00'0 instead of 10d00'0
