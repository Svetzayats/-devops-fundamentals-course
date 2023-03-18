#!/bin/bash

project_folder=~/Projects/shop-angular-cloudfront

# e2e falls with Cannot find module 'jasmine-spec-reporter'
# npm test runs headless chrome and nothing happens - 0 from 0 success 
cd $project_folder && npm run lint && npm run e2e && npm audit