#!/bin/bash

project_folder=~/Projects/shop-angular-cloudfront
build_folder=dist
output_path=$project_folder/$build_folder
client_build=$output_path/client-app.zip

ENV_CONFIGURATION=

if [ -z "$1" ] 
then
    echo "no env variable, development"
    true
else 
    echo "no env variable, production"
    ENV_CONFIGURATION=$1
fi 

echo "check client build"

if [ -e "$client_build" ]
then 
    echo "remove client build"
    rm $client_build
fi

echo "install project"

cd $project_folder && npm i && ng build --output-path="$build_folder" --configuration="$ENV_CONFIGURATION" 

echo "zip build"

7z a -tzip $client_build $output_path/*
